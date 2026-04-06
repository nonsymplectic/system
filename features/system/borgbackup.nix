{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.borgbackup;
  primaryUser = config.my.primaryUser;
in {
  options.features.borgbackup = {
    enable = lib.mkEnableOption "BorgBackup with Backblaze B2 sync";

    jobName = lib.mkOption {
      type = lib.types.str;
      default = "backup";
      description = "Name of the backup job (used for repository path and archive prefix)";
    };

    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "Documents"
        "HowTo"
        "Pictures"
        "Spass"
        "TODO"
        "Videos"
        "Job"
        "MSc"
        "Scripts"
        "Uni"
      ];
      description = "List of directories to backup (relative to user home)";
      example = [
        "Documents"
        "Pictures"
        "scripts"
      ];
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Systemd timer schedule for backups";
      example = "daily";
    };

    compression = lib.mkOption {
      type = lib.types.str;
      default = "auto,zstd";
      description = "Borg compression algorithm";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "*.tmp"
        "*.cache"
        "*/.cache"
        "*/Cache"
        "*/.local/share/Trash"
        "*/node_modules"
        "*/.npm"
        "*/.cargo/registry"
        "*/.cargo/git"
      ];
      description = "Patterns to exclude from backup";
    };

    prune.keep = lib.mkOption {
      type = lib.types.attrs;
      default = {
        daily = 7;
        weekly = 4;
        monthly = 6;
        yearly = 2;
      };
      description = "Retention policy for pruning old archives";
    };

    b2.bucket = lib.mkOption {
      type = lib.types.str;
      description = "Backblaze B2 bucket name";
      example = "my-borgbackup-bucket";
    };

    b2.remote = lib.mkOption {
      type = lib.types.str;
      default = "b2-backup";
      description = "Rclone remote name for Backblaze B2";
    };

    b2.syncSchedule = lib.mkOption {
      type = lib.types.str;
      default = "*:0/30";
      description = "Systemd timer schedule for B2 sync (OnCalendar format)";
      example = "*:0/30";
    };
  };

  config = lib.mkIf cfg.enable {
    # Agenix secrets
    age.secrets = {
      borgbackup_passphrase = {
        file = ../../secrets/borgbackup_passphrase.age;
        mode = "0400";
        owner = "root";
        group = "root";
      };

      borgbackup_b2_env = {
        file = ../../secrets/borgbackup_b2_env.age;
        mode = "0400";
        owner = "root";
        group = "root";
      };

      rclone_conf = {
        file = ../../secrets/rclone_conf.age;
        path = "/root/.config/rclone/rclone.conf";
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };

    # BorgBackup configuration
    services.borgbackup.jobs.${cfg.jobName} = {
      # Local repository
      repo = "/var/lib/borgbackup/${cfg.jobName}";

      # Convert relative paths to absolute paths
      paths = map (dir: "/home/${primaryUser}/${dir}") cfg.directories;

      # Encryption
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borgbackup_passphrase.path}";
      };

      # Compression
      compression = cfg.compression;

      # Timing
      startAt = cfg.schedule;

      # Archive naming with hostname prefix
      archiveBaseName = "${config.networking.hostName}-${cfg.jobName}";

      # Exclude patterns
      exclude = cfg.exclude;

      # Pruning with hostname prefix filter
      prune = {
        keep = cfg.prune.keep;
        prefix = "${config.networking.hostName}-${cfg.jobName}";
      };

      # Auto-initialize repository
      doInit = true;

      # Post-backup hook to trigger B2 sync
      postHook = ''
        echo "Backup completed, triggering B2 sync..."
        systemctl start borgbackup-b2-sync.service || echo "Failed to trigger B2 sync"
      '';

      # Pre-backup hook
      preHook = ''
        echo "Starting backup of ${config.networking.hostName} at $(date)"
      '';
    };

    # B2 sync service
    systemd.services.borgbackup-b2-sync = {
      description = "Sync BorgBackup repository to Backblaze B2";

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";

        # Load B2 credentials
        EnvironmentFile = config.age.secrets.borgbackup_b2_env.path;

        # Rclone sync command
        ExecStart = pkgs.writeShellScript "borgbackup-b2-sync" ''
          set -e

          REPO_PATH="/var/lib/borgbackup/${cfg.jobName}"
          B2_PATH="${cfg.b2.remote}:${cfg.b2.bucket}/borgbackup/${config.networking.hostName}"
          LOG_FILE="/var/log/borgbackup-b2-sync.log"

          echo "[$(date)] Starting sync to B2..." | tee -a "$LOG_FILE"

          # Sync local repository to B2
          ${pkgs.rclone}/bin/rclone sync \
            "$REPO_PATH" \
            "$B2_PATH" \
            --config /root/.config/rclone/rclone.conf \
            --progress \
            --transfers 4 \
            --checkers 8 \
            --log-file "$LOG_FILE" \
            --log-level INFO

          echo "[$(date)] Sync completed successfully" | tee -a "$LOG_FILE"
        '';
      };

      # Require network
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };

    # B2 sync timer (independent periodic sync)
    systemd.timers.borgbackup-b2-sync = {
      description = "Periodic sync of BorgBackup to B2";

      wantedBy = ["timers.target"];

      timerConfig = {
        OnCalendar = cfg.b2.syncSchedule;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "f /var/log/borgbackup-b2-sync.log 0644 root root -"
    ];

    # System packages
    environment.systemPackages = with pkgs; [
      borgbackup
      rclone
    ];

    # Home Manager configuration for user tools
    home-manager.users.${primaryUser} = {pkgs, ...}: {
      home.packages = with pkgs; [
        borgbackup

        # Helper script: List all archives
        # Usage: borg-list [-r <hostname>]
        (pkgs.writeShellScriptBin "borg-list" ''
          REPO="/var/lib/borgbackup/${cfg.jobName}"
          if [ "''${1:-}" = "-r" ]; then
            REPO="/var/lib/borgbackup/remote/''${2:?hostname required}"
          fi
          export BORG_PASSCOMMAND="sudo cat ${config.age.secrets.borgbackup_passphrase.path}"

          echo "Listing archives in repository: $REPO"
          echo ""
          sudo ${pkgs.borgbackup}/bin/borg list "$REPO"
        '')

        # Helper script: Mount an archive
        # Usage: borg-mount [-r <hostname>] <archive-name> [mount-point]
        (pkgs.writeShellScriptBin "borg-mount" ''
          REPO="/var/lib/borgbackup/${cfg.jobName}"
          if [ "''${1:-}" = "-r" ]; then
            REPO="/var/lib/borgbackup/remote/''${2:?hostname required}"
            shift 2
          fi

          if [ $# -lt 1 ]; then
            echo "Usage: borg-mount [-r <hostname>] <archive-name> [mount-point]"
            echo ""
            echo "Available archives:"
            borg-list
            exit 1
          fi

          ARCHIVE="$1"
          MOUNT_POINT="''${2:-/tmp/borg-mount}"
          export BORG_PASSCOMMAND="sudo cat ${config.age.secrets.borgbackup_passphrase.path}"

          mkdir -p "$MOUNT_POINT"

          echo "Mounting archive '$ARCHIVE' to $MOUNT_POINT"
          sudo ${pkgs.borgbackup}/bin/borg mount "$REPO::$ARCHIVE" "$MOUNT_POINT"

          echo ""
          echo "Archive mounted. Browse at: $MOUNT_POINT"
          echo "Unmount with: fusermount -u $MOUNT_POINT"
        '')

        # Helper script: Extract files from archive
        # Usage: borg-extract [-r <hostname>] <archive-name> <path>
        (pkgs.writeShellScriptBin "borg-extract" ''
          REPO="/var/lib/borgbackup/${cfg.jobName}"
          if [ "''${1:-}" = "-r" ]; then
            REPO="/var/lib/borgbackup/remote/''${2:?hostname required}"
            shift 2
          fi

          if [ $# -lt 2 ]; then
            echo "Usage: borg-extract [-r <hostname>] <archive-name> <path>"
            echo ""
            echo "Available archives:"
            borg-list
            exit 1
          fi

          ARCHIVE="$1"
          EXTRACT_PATH="$2"
          export BORG_PASSCOMMAND="sudo cat ${config.age.secrets.borgbackup_passphrase.path}"

          echo "Extracting '$EXTRACT_PATH' from archive '$ARCHIVE'"
          sudo ${pkgs.borgbackup}/bin/borg extract "$REPO::$ARCHIVE" "$EXTRACT_PATH"

          echo "Extraction complete"
        '')

        # Helper script: Check repository integrity
        # Usage: borg-check [-r <hostname>]
        (pkgs.writeShellScriptBin "borg-check" ''
          REPO="/var/lib/borgbackup/${cfg.jobName}"
          if [ "''${1:-}" = "-r" ]; then
            REPO="/var/lib/borgbackup/remote/''${2:?hostname required}"
          fi
          export BORG_PASSCOMMAND="sudo cat ${config.age.secrets.borgbackup_passphrase.path}"

          echo "Checking repository integrity: $REPO"
          echo ""
          sudo ${pkgs.borgbackup}/bin/borg check --progress "$REPO"

          echo ""
          echo "Repository check complete"
        '')

        # Helper script: Show repository info
        # Usage: borg-info [-r <hostname>] [archive-name]
        (pkgs.writeShellScriptBin "borg-info" ''
          REPO="/var/lib/borgbackup/${cfg.jobName}"
          if [ "''${1:-}" = "-r" ]; then
            REPO="/var/lib/borgbackup/remote/''${2:?hostname required}"
            shift 2
          fi
          export BORG_PASSCOMMAND="sudo cat ${config.age.secrets.borgbackup_passphrase.path}"

          if [ $# -eq 0 ]; then
            echo "Repository information:"
            echo ""
            sudo ${pkgs.borgbackup}/bin/borg info "$REPO"
          else
            echo "Archive information: $1"
            echo ""
            sudo ${pkgs.borgbackup}/bin/borg info "$REPO::$1"
          fi
        '')

        # Helper script: Manual backup trigger
        (pkgs.writeShellScriptBin "borg-backup-now" ''
          echo "Triggering manual backup..."
          sudo systemctl start borgbackup-job-${cfg.jobName}.service

          echo ""
          echo "Following backup logs (Ctrl+C to exit):"
          sudo journalctl -u borgbackup-job-${cfg.jobName}.service -f
        '')

        # Helper script: Manual B2 sync trigger
        (pkgs.writeShellScriptBin "borg-sync-now" ''
          echo "Triggering manual B2 sync..."
          sudo systemctl start borgbackup-b2-sync.service

          echo ""
          echo "Following sync logs (Ctrl+C to exit):"
          sudo journalctl -u borgbackup-b2-sync.service -f
        '')

        # Helper script: Pull another machine's repo from B2
        # Usage: borg-pull <hostname>
        (pkgs.writeShellScriptBin "borg-pull" ''
          REMOTE_HOST="''${1:?Usage: borg-pull <hostname>}"
          B2_PATH="${cfg.b2.remote}:${cfg.b2.bucket}/borgbackup/$REMOTE_HOST"
          LOCAL_MIRROR="/var/lib/borgbackup/remote/$REMOTE_HOST"

          echo "Pulling repo for '$REMOTE_HOST' from B2..."
          echo "  Source : $B2_PATH"
          echo "  Dest   : $LOCAL_MIRROR"
          echo ""

          sudo mkdir -p "$LOCAL_MIRROR"
          sudo ${pkgs.rclone}/bin/rclone sync \
            "$B2_PATH" \
            "$LOCAL_MIRROR" \
            --config /root/.config/rclone/rclone.conf \
            --progress \
            --transfers 4 \
            --checkers 8

          echo ""
          echo "Pull complete. Browse with:"
          echo "  borg-list -r $REMOTE_HOST"
          echo "  borg-mount -r $REMOTE_HOST <archive> [mount-point]"
          echo "  borg-extract -r $REMOTE_HOST <archive> <path>"
        '')
      ];
    };
  };
}
