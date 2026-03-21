# BorgBackup with Backblaze B2 - Setup Guide

## Overview

This system implements automated backups using BorgBackup with Backblaze B2 cloud storage. The architecture uses a two-stage approach:

1. **Local backup**: BorgBackup creates encrypted, deduplicated backups to `/var/lib/borgbackup/backup`
2. **Cloud sync**: Rclone periodically syncs the local repository to Backblaze B2

Both machines (home-pc and laptop) share the same repository, enabling cross-machine deduplication and restoration.

## Prerequisites

1. **Backblaze B2 Account**:
   - Sign up at https://www.backblaze.com/b2/
   - Create a new bucket (e.g., "my-borgbackup-bucket")
   - Generate application credentials (Account ID + Application Key)

2. **Age Keys**:
   - Ensure you have age keys at `/etc/agenix/host.agekey` on both machines
   - These are needed to encrypt/decrypt secrets

## Initial Setup

### Step 1: Create Backblaze B2 Bucket

1. Log into Backblaze B2 console
2. Create a new bucket (Private, with encryption enabled)
3. Note the bucket name for configuration
4. Generate Application Key:
   - Go to "App Keys" → "Add a New Application Key"
   - Name: "borgbackup-sync"
   - Access: Full Access to specific bucket
   - Copy the **Account ID** and **Application Key** (shown only once!)

### Step 2: Encrypt Secrets with Agenix

You need to create three encrypted secret files:

#### 2.1 BorgBackup Passphrase

```bash
# Create a strong passphrase
agenix -e secrets/borgbackup_passphrase.age
```

Content (single line):
```
your-very-strong-passphrase-here-use-a-password-manager
```

**Important**: This passphrase MUST be the same on both machines! The repository is encrypted with this key.

#### 2.2 Backblaze B2 Credentials

```bash
agenix -e secrets/borgbackup_b2_env.age
```

Content:
```bash
B2_ACCOUNT_ID=your_account_id_here
B2_APPLICATION_KEY=your_application_key_here
```

#### 2.3 Rclone Configuration

```bash
agenix -e secrets/rclone_conf.age
```

Content:
```ini
[b2-backup]
type = b2
account = your_account_id_here
key = your_application_key_here
```

**Note**: Replace `your_account_id_here` and `your_application_key_here` with your actual B2 credentials.

### Step 3: Update Host Configuration

Edit both `hosts/home-pc/default.nix` and `hosts/laptop/default.nix`:

```nix
features.borgbackup = {
  enable = true;
  jobName = "backup";

  directories = [
    "Documents"
    "Pictures"
    "scripts"
    "uni"
  ];

  schedule = "daily";

  b2 = {
    bucket = "my-borgbackup-bucket";  # ← Replace with your actual bucket name
    syncSchedule = "*:0/30";  # Sync every 30 minutes
  };

  prune.keep = {
    daily = 7;
    weekly = 4;
    monthly = 6;
    yearly = 2;
  };
};
```

### Step 4: Rebuild System

On the **first machine** (e.g., home-pc):

```bash
# Build and switch to new configuration
system-rebuild

# Verify services are configured
systemctl list-timers | grep borg
systemctl status borgbackup-job-backup
systemctl status borgbackup-b2-sync
```

### Step 5: Run Initial Backup

```bash
# Trigger first backup (will initialize repository)
sudo systemctl start borgbackup-job-backup

# Follow logs
sudo journalctl -u borgbackup-job-backup -f
```

This will:
- Create the repository at `/var/lib/borgbackup/backup`
- Create first archive: `home-pc-backup-YYYY-MM-DDTHH:MM:SS`
- Trigger B2 sync to upload to cloud

### Step 6: Verify B2 Sync

```bash
# Check sync logs
sudo journalctl -u borgbackup-b2-sync -f

# Or view log file
sudo tail -f /var/log/borgbackup-b2-sync.log
```

You can also verify via Backblaze B2 web console that files are being uploaded to your bucket.

### Step 7: Setup Second Machine

On the **second machine** (e.g., laptop):

1. Copy the same secrets (passphrase must match!):
   ```bash
   agenix -e secrets/borgbackup_passphrase.age
   agenix -e secrets/borgbackup_b2_env.age
   agenix -e secrets/rclone_conf.age
   ```

2. Download existing repository from B2:
   ```bash
   # This happens automatically on first backup, or manually:
   sudo systemctl start borgbackup-b2-sync
   ```

3. Rebuild system:
   ```bash
   system-rebuild
   ```

4. Run first backup:
   ```bash
   sudo systemctl start borgbackup-job-backup
   ```

The second machine will detect the existing repository and add its archives alongside the first machine's archives.

## Daily Usage

### Automatic Backups

The system runs automatically:
- **Backups**: Daily (or as configured in `schedule`)
- **B2 Sync**: Every 30 minutes (or as configured in `b2.syncSchedule`)

No manual intervention needed!

### User Helper Commands

All commands are available in your PATH:

#### List All Archives

```bash
borg-list
```

Output:
```
home-pc-backup-2026-03-21T00:00:00    Mon, 2026-03-21 00:00:00
laptop-backup-2026-03-21T00:00:00     Mon, 2026-03-21 00:00:00
home-pc-backup-2026-03-20T00:00:00    Sun, 2026-03-20 00:00:00
...
```

#### Mount an Archive for Browsing

```bash
borg-mount home-pc-backup-2026-03-21T00:00:00 /tmp/backup-browse
ls /tmp/backup-browse/home/michal/Documents
fusermount -u /tmp/backup-browse  # Unmount when done
```

#### Extract Specific Files

```bash
# Extract single file
borg-extract home-pc-backup-2026-03-21T00:00:00 Documents/important.txt

# Extract directory
borg-extract home-pc-backup-2026-03-21T00:00:00 Documents/project
```

Files are extracted to current directory.

#### Repository Info

```bash
# Overall repository info
borg-info

# Specific archive info
borg-info home-pc-backup-2026-03-21T00:00:00
```

#### Verify Repository Integrity

```bash
borg-check
```

#### Manual Backup Trigger

```bash
borg-backup-now
```

#### Manual B2 Sync Trigger

```bash
borg-sync-now
```

### Cross-Machine Restoration

You can restore files from any machine's backup on any other machine:

```bash
# On home-pc, restore files from laptop
borg-list | grep laptop  # Find laptop archives
borg-mount laptop-backup-2026-03-21T00:00:00 /tmp/laptop-files
cp /tmp/laptop-files/home/michal/Documents/notes.txt ~/Documents/
fusermount -u /tmp/laptop-files
```

## Monitoring and Logs

### Check Backup Status

```bash
# View backup service status
systemctl status borgbackup-job-backup

# View recent backup logs
sudo journalctl -u borgbackup-job-backup -n 50

# Follow live backup logs
sudo journalctl -u borgbackup-job-backup -f
```

### Check B2 Sync Status

```bash
# View sync service status
systemctl status borgbackup-b2-sync

# View recent sync logs
sudo journalctl -u borgbackup-b2-sync -n 50

# View sync log file
sudo tail -f /var/log/borgbackup-b2-sync.log
```

### Check Timers

```bash
# List all systemd timers including borg
systemctl list-timers

# Check when next backup/sync will run
systemctl list-timers | grep borg
```

## Configuration Options

All options are in `hosts/<hostname>/default.nix`:

```nix
features.borgbackup = {
  enable = true;              # Toggle feature on/off
  jobName = "backup";         # Backup job name

  directories = [             # Directories to backup (relative to ~)
    "Documents"
    "Pictures"
  ];

  schedule = "daily";         # When to backup (systemd timer format)
                              # Examples: "daily", "weekly", "03:00", "Mon 03:00"

  compression = "auto,zstd";  # Compression algorithm
                              # Options: "auto,zstd", "auto,lz4", "none"

  exclude = [                 # Patterns to exclude
    "*.tmp"
    "*/.cache"
  ];

  prune.keep = {              # Retention policy
    daily = 7;                # Keep 7 daily backups
    weekly = 4;               # Keep 4 weekly backups
    monthly = 6;              # Keep 6 monthly backups
    yearly = 2;               # Keep 2 yearly backups
  };

  b2.bucket = "my-bucket";    # B2 bucket name
  b2.remote = "b2-backup";    # Rclone remote name
  b2.syncSchedule = "*:0/30"; # Sync every 30 min
};
```

## How It Works

### Backup Flow

1. **Systemd timer** triggers at scheduled time (default: daily)
2. **BorgBackup** creates incremental backup:
   - Reads directories from user home
   - Deduplicates data (only stores changes)
   - Encrypts with passphrase
   - Creates archive: `{hostname}-backup-{timestamp}`
   - Stores in `/var/lib/borgbackup/backup`
3. **Pruning** removes old archives per retention policy
4. **Post-hook** triggers B2 sync service
5. **Rclone** syncs repository to B2:
   - Only uploads changed files
   - Preserves repository structure
   - Incremental, efficient transfer

### Multi-Machine Deduplication

Both machines backup to the same repository structure:
- Each creates archives with hostname prefix
- Borg deduplicates data **across all archives**
- If `Documents/report.pdf` exists on both machines, it's stored only once
- Saves massive space in cloud storage

### Security

- **Repository encryption**: repokey-blake2 (strongest Borg mode)
- **Passphrase**: agenix-encrypted, root-only access
- **B2 credentials**: agenix-encrypted environment file
- **Local backups**: `/var/lib/borgbackup/` (root-only permissions)
- **Transport**: Encrypted via Backblaze B2 HTTPS

## Troubleshooting

### Backup Fails

```bash
# Check logs for errors
sudo journalctl -u borgbackup-job-backup -n 100

# Common issues:
# 1. Passphrase incorrect → re-encrypt secret
# 2. Disk full → check /var/lib/borgbackup space
# 3. Lock timeout → another backup running or stale lock
```

### B2 Sync Fails

```bash
# Check logs
sudo journalctl -u borgbackup-b2-sync -n 100
sudo cat /var/log/borgbackup-b2-sync.log

# Common issues:
# 1. Invalid credentials → re-encrypt borgbackup_b2_env.age
# 2. Bucket not found → check bucket name in config
# 3. Network issues → check connectivity
```

### Repository Locked

If you see "Repository locked" error:

```bash
# Check if backup is actually running
systemctl status borgbackup-job-backup

# If not running, break the lock (use with caution!)
sudo borg break-lock /var/lib/borgbackup/backup
```

### Restore From B2 Only (Disaster Recovery)

If local repository is lost:

```bash
# 1. Setup secrets on new machine
# 2. Pull repository from B2
sudo systemctl start borgbackup-b2-sync

# Wait for sync to complete
sudo journalctl -u borgbackup-b2-sync -f

# 3. Verify repository
borg-check

# 4. List and restore
borg-list
borg-mount <archive> /tmp/restore
```

## Advanced Usage

### Exclude Additional Patterns

Edit host config:

```nix
features.borgbackup.exclude = [
  "*.tmp"
  "*/.cache"
  "*/node_modules"
  "Downloads/*"          # Exclude entire Downloads folder
  "Documents/temp/*"     # Exclude specific subdirectory
];
```

### Change Backup Schedule

```nix
features.borgbackup.schedule = "03:00";  # Daily at 3 AM
# Or: "Mon,Wed,Fri 02:00"  # Three times per week
# Or: "*-*-* 00/6:00"      # Every 6 hours
```

### Adjust Retention Policy

```nix
features.borgbackup.prune.keep = {
  hourly = 24;    # Keep 24 hourly backups
  daily = 14;     # Keep 14 daily backups
  weekly = 8;     # Keep 8 weekly backups
  monthly = 12;   # Keep 12 monthly backups
  yearly = 5;     # Keep 5 yearly backups
};
```

### Add More Directories

```nix
features.borgbackup.directories = [
  "Documents"
  "Pictures"
  "scripts"
  "uni"
  "Music"           # Add more directories
  ".config/nvim"    # Include dotfiles
  "projects"        # Any directory in home
];
```

## File Locations

| Item | Location |
|------|----------|
| Feature module | `features/system/borgbackup.nix` |
| Secrets | `secrets/borgbackup_*.age`, `secrets/rclone_conf.age` |
| Local repository | `/var/lib/borgbackup/backup` |
| Rclone config | `/root/.config/rclone/rclone.conf` (decrypted at runtime) |
| Sync logs | `/var/log/borgbackup-b2-sync.log` |
| Service logs | `journalctl -u borgbackup-job-backup` |
| Helper scripts | In PATH: `borg-list`, `borg-mount`, etc. |

## Support

For issues or questions:
- Check logs: `sudo journalctl -u borgbackup-job-backup -n 100`
- Verify configuration: `nix flake check`
- Test secrets: `sudo cat /run/agenix/borgbackup_passphrase`
- BorgBackup docs: https://borgbackup.readthedocs.io/
- Rclone docs: https://rclone.org/b2/
