# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### System Rebuild
```bash
# Rebuild current host (applies changes immediately)
system-rebuild

# Equivalent to:
nixos-rebuild switch --flake ".#$(hostname)"

# Build a specific host
nixos-rebuild switch --flake ".#home-pc"
nixos-rebuild switch --flake ".#laptop"

# Build without switching (for testing)
nixos-rebuild build --flake ".#home-pc"

# Test without permanent changes (reboots into new config)
nixos-rebuild test --flake ".#home-pc"
```

### Flake Commands
```bash
# Check for syntax/evaluation errors
nix flake check

# Show flake outputs
nix flake show

# Update lock file (updates all inputs)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Code Formatting
```bash
# Format Nix files with alejandra
alejandra .

# Format Python files with black
black .
```

### Secrets Management (agenix)
```bash
# Edit/encrypt a secret (requires age key at /etc/agenix/host.agekey)
agenix -e secrets/github_id_ed25519_github.age

# Re-key all secrets (when adding new hosts or keys)
agenix -r
```

## High-Level Architecture

This is a **host-agnostic, reproducible NixOS system** with strict separation of concerns. The README.md is **normative**—code must adapt to match it.

### Four Conceptual Layers

1. **Hosts** (`hosts/<name>/`) – Hardware + thin overrides only
2. **Profiles** (`profiles/`) – Role-based composition (`minimal`, `workstation`)
3. **Modules** (`modules/nixos/`, `modules/home/`) – Implementation details
4. **Options** (`options/`) – Shared declarative interfaces

### Key Architectural Principles

- **Hosts must be thin**: Only hardware config, profile selection, and policy overrides
- **No user definitions in hosts**: Primary user defined in `modules/nixos/core/primary-user.nix`
- **Secrets via agenix only**: No plaintext secrets, services consume via file paths
- **Single home environment**: Same config synced across all machines

## Critical Files and Their Roles

### Entry Points
- `flake.nix`: Defines inputs (nixpkgs, home-manager, agenix, catppuccin) and hosts
- `lib/mkHost.nix`: System builder that wires together all inputs and modules

### Profiles
- `profiles/minimal.nix`: Baseline (10 core packages, SSH, no UI) for all systems
- `profiles/workstation.nix`: Extends minimal + Home Manager + desktop system

### NixOS Modules (System Layer)
- `modules/nixos/core/primary-user.nix`: Declares `my.primaryUser` option
- `modules/nixos/core/agenix.nix`: Secret management setup
- `modules/nixos/services/ly.nix`: Display/login manager
- `modules/nixos/ui/fonts.nix`: System fonts
- `modules/nixos/ui/wm-setup.nix`: DM session registration + swaylock PAM

### Home Manager Modules (User Layer)
- `modules/home/packages.nix`: User packages (browsers, editors, CLI tools)
- `modules/home/core/`: Shell, git, SSH configuration
- `modules/home/desktop/interface.nix`: **Master orchestrator** for desktop system

### Options (Shared Interfaces)
- `options/ui.nix`: UI tokens (`my.ui.*`) - fonts, colors, scale
- `options/desktop.nix`: Desktop policy (`my.desktop.*`) - WM, bar, launcher, terminal

## Desktop Plugin System

The desktop environment is a **policy-driven plugin system** at the Home Manager layer.

### How It Works

1. **Policy Declaration** (Host level):
```nix
my.desktop = {
  enable = true;
  wm = "sway";
  terminal = "foot";
  launcher = "wofi";
  bar = { enable = true; backend = "waybar"; position = "bottom"; };
};
```

2. **Normalization** (`lib/desktop/normalize.nix`):
   - Converts policy → normalized wiring payload
   - Resolves component commands (e.g., `terminal.command = "foot"`)
   - Single-pass evaluation with invariant checking

3. **Plugin Self-Gating** (`modules/home/desktop/*/`):
   - Each plugin checks: `desktop.enable && desktop.wm.name == "sway"`
   - Reads normalized commands from `desktop` payload
   - Reads immutable UI tokens from `ui` (fonts, colors, scale)
   - No cross-plugin dependencies

### Desktop Plugins

- `wms/sway.nix`: Sway window manager
- `bars/waybar.nix`: Waybar status bar
- `launchers/wofi.nix`: Wofi app launcher
- `terminals/foot.nix`: Foot terminal
- `theme.nix`: Catppuccin GTK/Qt theming

### Adding a New Desktop Plugin

1. Create `modules/home/desktop/newcomponent/plugin.nix`
2. Self-gate on relevant `desktop` field
3. Import in `modules/home/desktop/interface.nix`
4. Declare policy options in `options/desktop.nix` if needed

**Key Constraint**: Plugins must NOT read `config.my.desktop.*` directly—only use the normalized `desktop` and `ui` arguments injected by the interface module.

## Policy vs Implementation Separation

### UI Tokens (`my.ui.*`)
- **Set at**: System level (hosts)
- **Consumed by**: Home Manager modules
- **Purpose**: Host-specific display properties (fonts, colors, scaling)
- **Rule**: Never mutated or derived within Home Manager

### Desktop Policy (`my.desktop.*`)
- **Set at**: System level (hosts)
- **Normalized in**: `modules/home/desktop/interface.nix`
- **Consumed by**: Desktop plugins
- **Rule**: Single interpretation, normalized exactly once

## Secrets Management

All secrets managed via **agenix**:

- Encrypted files: `secrets/*.age`
- Declared in: `modules/nixos/core/agenix.nix`
- Identity path: `/etc/agenix/host.agekey`
- Services consume via: `age.secrets.<name>.path`

**Never** use string-typed secret options or plaintext in Nix code.

## Typical Workflows

### Adding a New Host
1. Create `hosts/newhost/default.nix` (import hardware + select profile)
2. Generate `hardware-configuration.nix`: `nixos-generate-config`
3. Create `users.nix` (set `my.primaryUser`, enable Home Manager)
4. Add to `flake.nix` under `nixosConfigurations`
5. Test: `nixos-rebuild build --flake ".#newhost"`

### Changing Desktop Configuration
- Edit host's `my.desktop.*` settings in `default.nix`
- Plugins automatically activate/deactivate based on policy
- Run `system-rebuild` to apply

### Adding User Packages
- Edit `modules/home/packages.nix`
- Use `pkgs` for stable, `pkgsUnstable` for bleeding-edge
- Run `system-rebuild` to apply

### Modifying Core System Behavior
- Minimal baseline: `profiles/minimal.nix`
- Workstation additions: `profiles/workstation.nix`
- Host-specific: Only in `hosts/<name>/` (hardware, overrides)

## Important Constraints

1. **Hosts are boring**: If two hosts should behave the same, logic belongs in profiles/modules
2. **One user identity**: Primary user defined centrally, never in hosts
3. **No plaintext secrets**: Use agenix exclusively
4. **Immutable tokens**: UI and desktop policy flow one-way: system → Home Manager
5. **No plugin coupling**: All coordination through normalized payload
6. **NixOS vs Home Manager**: System handles hardware/services/login; Home Manager handles user programs/dotfiles/desktop

## Current Hosts

- `home-pc`: Desktop workstation
- `laptop`: Laptop configuration

Both use `workstation` profile with Sway + Waybar + Wofi + Foot.
