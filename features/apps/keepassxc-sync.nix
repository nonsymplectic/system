{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.keepassxc-sync;
  primaryUser = config.my.primaryUser;
in {
  options.features.keepassxc-sync = {
    enable = lib.mkEnableOption "KeePassXC with automatic S3 sync";

    databasePath = lib.mkOption {
      type = lib.types.str;
      default = "/home/${primaryUser}/KeepassXC/db.kdbx";
      description = "Path to the KeePassXC database file";
    };

    remotePath = lib.mkOption {
      type = lib.types.str;
      description = "Remote path in rclone format (e.g., 'b2-backup:bucket/path/db.kdbx')";
      example = "b2-backup:my-bucket/keepassxc/db.kdbx";
    };

    rcloneRemote = lib.mkOption {
      type = lib.types.str;
      default = "b2-backup";
      description = "Rclone remote name (must be configured in rclone.conf)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure rclone and libnotify are available
    environment.systemPackages = with pkgs; [
      rclone
      libnotify
    ];

    # Make rclone config accessible to the user
    # (reuses the same agenix secret from borgbackup feature)
    age.secrets.rclone_conf_user = {
      file = ../../secrets/rclone_conf.age;
      path = "/home/${primaryUser}/.config/rclone/rclone.conf";
      mode = "0600";
      owner = primaryUser;
      group = config.users.users.${primaryUser}.group;
    };

    # Home Manager configuration for the primary user
    home-manager.users.${primaryUser} = {pkgs, ...}: let
      # Wrapper script that handles sync before/after KeePassXC
      keepassxc-sync-wrapper = pkgs.writeShellScriptBin "keepassxc-sync" ''
        set -e

        DB_PATH="${cfg.databasePath}"
        REMOTE_PATH="${cfg.remotePath}"
        DB_DIR="$(dirname "$DB_PATH")"
        DB_FILE="$(basename "$DB_PATH")"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        RCLONE_CONFIG="/home/${primaryUser}/.config/rclone/rclone.conf"

        # Ensure database directory exists
        mkdir -p "$DB_DIR"

        # Function to show notifications
        notify() {
          local urgency="$1"
          local summary="$2"
          local body="$3"
          local timeout="''${4:-5000}"  # Default 5 seconds, can be overridden
          ${pkgs.libnotify}/bin/notify-send -t "$timeout" -u "$urgency" -a "KeePassXC Sync" "$summary" "$body"
        }

        # Function to check if remote file exists and get its modtime
        get_remote_modtime() {
          ${pkgs.rclone}/bin/rclone lsl "$REMOTE_PATH" --config "$RCLONE_CONFIG" 2>/dev/null | awk '{print $2, $3}' || echo ""
        }

        # Function to get local file modtime
        get_local_modtime() {
          if [ -f "$DB_PATH" ]; then
            stat -c "%Y" "$DB_PATH"
          else
            echo "0"
          fi
        }

        # Pre-sync: Download from remote before opening
        pre_sync() {
          notify normal "KeePassXC Sync" "Syncing database from cloud..." 3000

          # Check if remote exists (check if output is non-empty, not just exit code)
          REMOTE_CHECK=$(${pkgs.rclone}/bin/rclone lsl "$REMOTE_PATH" --config "$RCLONE_CONFIG" 2>/dev/null)
          if [ -z "$REMOTE_CHECK" ]; then
            if [ -f "$DB_PATH" ]; then
              notify normal "KeePassXC Sync" "No remote database found. Will upload after closing."
            else
              notify critical "KeePassXC Sync" "No database found locally or remotely!"
              exit 1
            fi
            return
          fi

          # If local doesn't exist, just download
          if [ ! -f "$DB_PATH" ]; then
            if ! ${pkgs.rclone}/bin/rclone copyto "$REMOTE_PATH" "$DB_PATH" --config "$RCLONE_CONFIG" 2>/dev/null; then
              notify critical "KeePassXC Sync" "Failed to download database from remote. Check remote path: $REMOTE_PATH"
              exit 1
            fi
            notify normal "KeePassXC Sync" "Database downloaded from cloud."
            return
          fi

          # Both exist - check for conflicts
          LOCAL_TIME=$(get_local_modtime)

          # Download to temp location for comparison
          TEMP_DB="$DB_DIR/.db.kdbx.tmp"
          if ! ${pkgs.rclone}/bin/rclone copyto "$REMOTE_PATH" "$TEMP_DB" --config "$RCLONE_CONFIG" 2>/dev/null; then
            notify critical "KeePassXC Sync" "Failed to download remote database. Check remote path and rclone config."
            exit 1
          fi

          # Verify the file was actually created
          if [ ! -f "$TEMP_DB" ]; then
            notify critical "KeePassXC Sync" "Download completed but file not found. Check remote path: $REMOTE_PATH"
            exit 1
          fi

          REMOTE_TIME=$(stat -c "%Y" "$TEMP_DB")

          # Compare checksums
          LOCAL_HASH=$(sha256sum "$DB_PATH" | awk '{print $1}')
          REMOTE_HASH=$(sha256sum "$TEMP_DB" | awk '{print $1}')

          if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
            # Files are identical
            rm "$TEMP_DB"
            notify low "KeePassXC Sync" "Database is up to date."
          elif [ "$REMOTE_TIME" -gt "$LOCAL_TIME" ]; then
            # Remote is newer - use it
            mv "$TEMP_DB" "$DB_PATH"
            notify normal "KeePassXC Sync" "Database updated from cloud."
          else
            # Local is newer or both changed - CONFLICT
            CONFLICT_FILE="$DB_DIR/db.kdbx.conflict.$TIMESTAMP"
            cp "$DB_PATH" "$CONFLICT_FILE"
            mv "$TEMP_DB" "$DB_PATH"
            notify critical "KeePassXC Sync - CONFLICT" "Local changes backed up to:\n$CONFLICT_FILE\n\nUsing remote version."
          fi
        }

        # Post-sync: Upload to remote after closing
        post_sync() {
          if [ ! -f "$DB_PATH" ]; then
            notify normal "KeePassXC Sync" "No database to sync."
            return
          fi

          # Check if remote exists and is newer (check if output is non-empty)
          REMOTE_CHECK=$(${pkgs.rclone}/bin/rclone lsl "$REMOTE_PATH" --config "$RCLONE_CONFIG" 2>/dev/null)
          if [ -n "$REMOTE_CHECK" ]; then
            # Download remote to temp for comparison
            TEMP_DB="$DB_DIR/.db.kdbx.tmp"
            if ! ${pkgs.rclone}/bin/rclone copyto "$REMOTE_PATH" "$TEMP_DB" --config "$RCLONE_CONFIG" 2>/dev/null; then
              notify critical "KeePassXC Sync" "Failed to download remote for comparison during upload."
              return
            fi

            # Verify the file was actually created
            if [ ! -f "$TEMP_DB" ]; then
              notify critical "KeePassXC Sync" "Download completed but file not found during upload check."
              return
            fi

            LOCAL_HASH=$(sha256sum "$DB_PATH" | awk '{print $1}')
            REMOTE_HASH=$(sha256sum "$TEMP_DB" | awk '{print $1}')
            REMOTE_TIME=$(stat -c "%Y" "$TEMP_DB")
            LOCAL_TIME=$(stat -c "%Y" "$DB_PATH")

            if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
              # No changes
              rm "$TEMP_DB"
              notify low "KeePassXC Sync" "No changes to upload."
              return
            elif [ "$REMOTE_TIME" -gt "$LOCAL_TIME" ]; then
              # Remote was modified while we were editing - CONFLICT
              CONFLICT_FILE="$DB_DIR/db.kdbx.conflict.$TIMESTAMP"
              mv "$TEMP_DB" "$CONFLICT_FILE"
              notify critical "KeePassXC Sync - CONFLICT" "Remote was modified during session!\nRemote version saved to:\n$CONFLICT_FILE\n\nNOT uploading local changes."
              return
            else
              rm "$TEMP_DB"
            fi
          fi

          # Upload local to remote
          notify normal "KeePassXC Sync" "Uploading database to cloud..." 3000
          ${pkgs.rclone}/bin/rclone copyto "$DB_PATH" "$REMOTE_PATH" --config "$RCLONE_CONFIG"
          notify normal "KeePassXC Sync" "Database uploaded to cloud successfully." 5000
        }

        # Main execution
        pre_sync

        # Launch KeePassXC with the database
        ${pkgs.keepassxc}/bin/keepassxc "$DB_PATH" "$@"

        # After KeePassXC closes, sync back
        post_sync
      '';
    in {
      # Install KeePassXC and wrapper
      home.packages = [
        pkgs.keepassxc
        pkgs.libnotify
        keepassxc-sync-wrapper
      ];

      # Create separate desktop entry for syncing version
      xdg.desktopEntries.keepassxc-sync = {
        name = "KeePassXC-Sync";
        genericName = "Password Manager (with S3 sync)";
        comment = "KeePassXC with automatic cloud sync before/after opening";
        exec = "keepassxc-sync %f";
        icon = "keepassxc";
        terminal = false;
        type = "Application";
        categories = [
          "Utility"
          "Security"
          "Qt"
        ];
        mimeType = ["application/x-keepass2"];
        startupNotify = true;
      };
    };
  };
}
