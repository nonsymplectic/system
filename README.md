# Unified NixOS + Home Manager Flake

This repository contains a **single, unified Nix flake** for declaratively provisioning and maintaining multiple machines. It combines:

- **NixOS** for system configuration
- **Home Manager** for the user environment
- **agenix** for secrets
- Reproducible tools, scripts, and desktop integration

---

## Goals

- One flake for all machines
- Minimal host-specific divergence
- Explicit separation of policy and implementation
- Fully declarative, rollback-safe configuration
- No ad-hoc mutable state

---

## Architectural Layers

### NixOS (System Layer)

The system layer is responsible for:

- Hardware configuration (GPU, sound, power, kernel parameters)
- Filesystems, swap, and btrfs setup
- Long-running services (e.g. restic, syncthing)
- Networking, firewalling, SSH
- System-level secrets injection
- Defining **machine-level UI tokens** (font, size, scale)

It does **not** manage:
- Dotfiles
- Window manager configuration
- User application configuration

---

### Home Manager (User Layer)

The user layer is responsible for:

- Shell, editor, terminal configuration
- Window manager / desktop environment configuration
- Wrapper scripts exposed in `$PATH`
- Desktop entries and icons

Properties:
- Identical across machines by default
- Fully declarative and rollback-safe
- Consumes machine-level UI tokens provided by NixOS

---

### Assets

Assets are static files consumed by Home Manager:

- Raw `.desktop` files
- Icons

They contain no logic and no host-specific branching.

---

## Machines

The flake currently provisions two machines:

### Laptop
- Mobile workstation
- Laptop-specific hardware (power management, backlight, etc.)

### Home PC
- Stationary workstation
- Potentially GPU-heavy configuration

Allowed differences:
- Hardware modules
- Feature flags
- UI token values (e.g. font size or scale)

Disallowed differences:
- Wrapper scripts
- Desktop entries
- Core user environment

---

## Repository Structure

```text
.
├── flake.nix            # Flake entrypoint
├── flake.lock
│
├── lib/                 # Small helpers (e.g. mkHost)
│
├── hosts/               # Host policy only
│   ├── laptop/
│   │   ├── default.nix  # Host policy: profiles, flags, UI tokens
│   │   ├── hardware.nix
│   │   ├── disks.nix    # Reserved for disko
│   │   └── users.nix
│   └── home-pc/
│       └── ...
│
├── modules/
│   ├── common/
│   │   └── ui.nix       # UI token option definitions
│   │
│   ├── nixos/
│   │   ├── core/
│   │   ├── hardware/
│   │   ├── services/
│   │   └── ui/
│   │
│   └── home/
│       ├── core/
│       ├── scripts.nix
│       ├── desktop-entries.nix
│       └── wm.nix       # WM-agnostic interface (Sway as example backend)
│
├── profiles/
│   ├── workstation.nix
│   └── minimal.nix
│
├── pkgs/                # Custom user tools / wrapper scripts
│
├── assets/
│   ├── applications/    # Raw .desktop files
│   └── icons/
│
└── secrets/             # age-encrypted secrets (agenix)
````

---

## Host Configuration Model

Each host is defined by `hosts/<host>/default.nix`.

These files express **policy only**:

* Hostname and timezone
* Imported profiles
* Feature flags
* UI token values (font family, size, scale)

They do **not** contain:

* Long service definitions
* Full UI or WM configuration
* Large inline blocks

---

## Profiles

Profiles are reusable **import bundles** that define system roles.

### Example Profiles

**`workstation`**

* Full UI stack
* Development environment
* Restic backups
* Syncthing
* Wrapper scripts
* Desktop entries
* Window manager configuration

**`minimal`**

* Core NixOS configuration
* SSH access
* Nix tooling only

Profiles are:

* Hardware-agnostic
* Shared across machines
* Composable

---

## UI Tokens 

To avoid host-fragmenting user configuration, the system defines a small set of **UI tokens**:

Examples:

* `my.ui.fontFamily`
* `my.ui.fontSize`
* `my.ui.scale`

Pattern:

1. Options are defined in `modules/common/ui.nix`.
2. Host policy sets the values.
3. NixOS passes the values into Home Manager via `home-manager.extraSpecialArgs`.
4. Home modules (terminal, bar, WM) consume them.

---

## Window Manager Configuration (WM-agnostic)

Window manager configuration is handled through a **single parametric Home Manager module**.

### Interface

Conceptually:

* Enable flag
* Backend selection
* Launcher choice
* Terminal choice
* Optional extra configuration
* Optional keybinding overrides

The module consumes UI tokens for typography and scale.

### Example Backend: Sway

Sway is used as a concrete example:

* Launcher variants: `bemenu`, `wofi`, `fuzzel`
* One `$menu` variable
* Standard keybindings
* Fonts and sizes derived from UI tokens
* Remaining configuration invariant

If another WM is added later, the high-level interface remains unchanged.

---

## Wrapper Scripts

Wrapper scripts are:

* Defined as Nix packages
* Installed via Home Manager
* Exposed in `$PATH`
* Used by both CLI workflows and `.desktop` files

They act as stable entrypoints that abstract host-specific details.

---

## Desktop Entries

Desktop entries are:

* Stored as raw `.desktop` files under `assets/applications/`
* Paired with icons under `assets/icons/`
* Installed declaratively via Home Manager

Rules:

* Identical across all machines
* No host-specific branching
* `Exec=` points to wrapper scripts in `$PATH`

---

## Backups (Example: Restic)

* Tool: **restic**
* Backend: **Backblaze B2 (S3-compatible)**
* Filesystem: **btrfs**

Properties:

* `$HOME` is a btrfs subvolume
* Explicit include paths
* Optional read-only snapshot before backup
* `systemd` timers
* Declarative retention policy

### Secrets

Secrets are managed via **agenix**:

* `RESTIC_PASSWORD`
* S3 credentials

They are encrypted at rest, injected at runtime, and never committed in plaintext.

---

## Sync (Example: Syncthing)

* Enabled declaratively at the NixOS layer
* Used for user data sync
* Device/folder state may initially require manual setup

---

## Disk Management (Future)

* `hosts/<host>/disks.nix` reserved for **disko**
* Not required initially
* Can be added without restructuring the flake
