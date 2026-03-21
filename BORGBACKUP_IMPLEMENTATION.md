# BorgBackup Implementation Summary

## What Was Implemented

A complete BorgBackup + Backblaze B2 sync feature for NixOS, following the planned architecture.

## Files Created

### 1. Feature Module
- **`features/system/borgbackup.nix`** (350+ lines)
  - Full declarative configuration via `features.borgbackup.*` options
  - Agenix secret management integration
  - NixOS systemd services and timers
  - Home Manager user helper scripts
  - Self-gating with `lib.mkIf cfg.enable`

### 2. Placeholder Secrets (Need User Input)
- **`secrets/borgbackup_passphrase.age`** - Repository encryption passphrase
- **`secrets/borgbackup_b2_env.age`** - B2 credentials (Account ID + Application Key)
- **`secrets/rclone_conf.age`** - Rclone configuration for B2

**Important**: These are placeholder files. User MUST encrypt actual secrets using `agenix -e`.

### 3. Documentation
- **`BORGBACKUP_SETUP.md`** - Comprehensive setup and usage guide
- **`BORGBACKUP_IMPLEMENTATION.md`** - This file

## Files Modified

### 1. Profile Integration
- **`profiles/workstation.nix`**:
  - Added import: `../features/system/borgbackup.nix`

### 2. Host Configuration
- **`hosts/home-pc/default.nix`**:
  - Enabled and configured `features.borgbackup`
  - Backup directories: Documents, Pictures, scripts, uni
  - Schedule: daily
  - B2 bucket: `my-borgbackup-bucket` (TODO: update)

- **`hosts/laptop/default.nix`**:
  - Same configuration as home-pc
  - Shares same repository for cross-machine deduplication

## Architecture

### NixOS Layer (System Services)

1. **`services.borgbackup.jobs.backup`**:
   - Local repository: `/var/lib/borgbackup/backup`
   - Encryption: repokey-blake2 with agenix-managed passphrase
   - Archive naming: `{hostname}-backup-{timestamp}`
   - Automatic pruning with retention policy
   - Post-hook triggers B2 sync

2. **`systemd.services.borgbackup-b2-sync`**:
   - Rclone sync: local repository → B2 bucket
   - Environment file: B2 credentials from agenix
   - Logs to `/var/log/borgbackup-b2-sync.log`

3. **`systemd.timers`**:
   - `borgbackup-job-backup.timer`: Daily backups (configurable)
   - `borgbackup-b2-sync.timer`: Every 30 min sync (configurable)

### Home Manager Layer (User Tools)

Helper scripts available in PATH:
- `borg-list` - List all archives
- `borg-mount <archive> [path]` - Mount archive for browsing
- `borg-extract <archive> <path>` - Extract files from archive
- `borg-info [archive]` - Show repository/archive info
- `borg-check` - Verify repository integrity
- `borg-backup-now` - Trigger manual backup
- `borg-sync-now` - Trigger manual B2 sync

## Configuration Options

All options in `features.borgbackup.*`:

```nix
{
  enable = true;                    # Toggle feature
  jobName = "backup";               # Job name
  directories = [ "Documents" ];    # Dirs to backup (relative to ~)
  schedule = "daily";               # Backup schedule
  compression = "auto,zstd";        # Compression algorithm
  exclude = [ "*.tmp" ];            # Exclude patterns

  prune.keep = {                    # Retention policy
    daily = 7;
    weekly = 4;
    monthly = 6;
    yearly = 2;
  };

  b2.bucket = "bucket-name";        # B2 bucket
  b2.remote = "b2-backup";          # Rclone remote name
  b2.syncSchedule = "*:0/30";       # Sync schedule
}
```

## Security Model

- **Encryption**: repokey-blake2 (strongest Borg mode)
- **Secrets**: All via agenix, mode 0400, root-only
  - Repository passphrase
  - B2 credentials
  - Rclone configuration
- **Local repository**: `/var/lib/borgbackup/` (root permissions)
- **Transport**: HTTPS to Backblaze B2

## Multi-Machine Setup

Both machines:
1. Use same `jobName` ("backup")
2. Use same B2 bucket
3. Use **same passphrase** (critical!)
4. Different `archiveBaseName` prefix (hostname-based)

Result:
- Shared repository with archives from both machines
- Cross-machine deduplication
- Can restore laptop files from home-pc and vice versa

## Next Steps for User

### 1. Create Backblaze B2 Bucket
- Sign up at https://www.backblaze.com/b2/
- Create private bucket
- Generate application credentials

### 2. Encrypt Secrets
```bash
# Passphrase (must be same on both machines!)
agenix -e secrets/borgbackup_passphrase.age

# B2 credentials
agenix -e secrets/borgbackup_b2_env.age
# Content:
# B2_ACCOUNT_ID=xxx
# B2_APPLICATION_KEY=yyy

# Rclone config
agenix -e secrets/rclone_conf.age
# Content:
# [b2-backup]
# type = b2
# account = xxx
# key = yyy
```

### 3. Update Bucket Name
Edit `hosts/home-pc/default.nix` and `hosts/laptop/default.nix`:
```nix
features.borgbackup.b2.bucket = "your-actual-bucket-name";
```

### 4. Build and Deploy
```bash
# On first machine
system-rebuild

# Verify services
systemctl list-timers | grep borg

# Run first backup
sudo systemctl start borgbackup-job-backup
sudo journalctl -u borgbackup-job-backup -f

# Verify B2 sync
sudo journalctl -u borgbackup-b2-sync -f
```

### 5. Setup Second Machine
Same steps as first machine. Repository will be synced from B2 automatically.

## Verification Commands

```bash
# List timers
systemctl list-timers | grep borg

# Check service status
systemctl status borgbackup-job-backup
systemctl status borgbackup-b2-sync

# View logs
journalctl -u borgbackup-job-backup -n 50
journalctl -u borgbackup-b2-sync -n 50
tail -f /var/log/borgbackup-b2-sync.log

# List archives
borg-list

# Check repository
borg-check

# Test restore
borg-mount <archive> /tmp/test
ls /tmp/test
fusermount -u /tmp/test
```

## Architecture Compliance

✅ **Feature-based organization**: `features/system/borgbackup.nix`
✅ **Self-gating**: `config = lib.mkIf cfg.enable`
✅ **Primary user pattern**: Uses `config.my.primaryUser`
✅ **Secrets via agenix**: No plaintext credentials
✅ **Mixed layer**: NixOS services + Home Manager tools
✅ **Profile composition**: Enabled in workstation profile
✅ **Host configuration**: Policy set per-host via options
✅ **Declarative**: Everything configured via Nix options

## Key Features

1. **Automatic backups**: Daily (configurable) with systemd timers
2. **Cloud sync**: Independent periodic sync to B2
3. **Multi-machine**: Shared repository across all hosts
4. **Deduplication**: Borg deduplicates data across all archives
5. **Encryption**: End-to-end encryption with passphrase
6. **Retention**: Configurable pruning policy
7. **User-friendly**: Helper scripts for common operations
8. **Cross-restore**: Restore laptop files from home-pc and vice versa

## Testing Status

- ✅ Flake check passes
- ✅ Code formatted with alejandra
- ⏳ Secrets need to be encrypted by user
- ⏳ System rebuild and deployment needed
- ⏳ First backup needs to be run
- ⏳ B2 sync needs verification

## Known TODOs

1. User must create and encrypt secrets with actual credentials
2. User must update B2 bucket name in host configs
3. User must deploy to both machines
4. First backup run will initialize repository
5. Verify B2 sync is working via web console
