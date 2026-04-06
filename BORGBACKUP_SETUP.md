# BorgBackup User Guide

Backups run daily, B2 sync runs every 30 minutes. Everything is automatic.

## Commands

```bash
borg-list                          # list archives on this machine
borg-backup-now                    # trigger backup immediately
borg-sync-now                      # trigger B2 sync immediately

borg-mount <archive> [mountpoint]  # mount archive (default: /tmp/borg-mount)
borg-extract <archive> <path>      # extract a file/dir to current directory
borg-info [archive]                # repo or archive info
borg-check                         # verify repo integrity
```

## Cross-machine sync

```bash
borg-pull <hostname>               # download another machine's repo from B2

# then use -r <hostname> with any command:
borg-list -r laptop
borg-mount -r laptop laptop-backup-2026-04-05T00:00:00 /tmp/laptop
borg-extract -r laptop laptop-backup-2026-04-05T00:00:00 home/michal/Documents/foo.txt
```

Unmount with: `fusermount -u <mountpoint>`

## Logs

```bash
sudo journalctl -u borgbackup-job-backup -f
sudo journalctl -u borgbackup-b2-sync -f
sudo tail -f /var/log/borgbackup-b2-sync.log
```

## Stale lock

```bash
sudo borg break-lock /var/lib/borgbackup/backup
```
