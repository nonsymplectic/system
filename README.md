# System Configuration Spec

This repository defines a **host-agnostic, reproducible system and user environment** built with NixOS and Home Manager.

The design emphasizes:

* **dendritic feature modules** – self-contained, composable features
* **flake-parts** – automatic module composition without manual wiring
* **host files as overrides only** – thin, declarative host configuration
* **direct UI token access** – `config.my.ui` available everywhere
* **single, synced home environment** across machines
* secrets managed **exclusively via agenix**
* minimal baselines composed into richer profiles

This document defines the **normative architecture**.
Code must be adapted to match it, not the other way around.

---

## High-level architecture

The system is built on three conceptual layers:

1. **Hosts** – hardware + feature configuration + overrides
2. **Profiles** – role-based feature composition
3. **Features** – self-contained modules with explicit enable options

Each layer has a clearly defined responsibility and must not leak concerns upward or downward.

---

## Flake infrastructure

The flake uses **flake-parts** for automatic module composition:

```
flake.nix                 # flake-parts entry point
flake-modules/
  ├── baseline.nix        # Flake-wide config (nix features, stateVersion)
  └── nixos.nix           # Defines nixosConfigurations
```

Benefits:
* No manual `specialArgs` wiring (except `pkgsUnstable`)
* Automatic module composition
* Clean, declarative structure

---

## Features: self-contained modules

Features are **dendritic modules** that encapsulate both NixOS and Home Manager configuration in a single file.

Directory structure:

```
features/
  ├── core/              # Auto-imported baseline
  │   ├── default.nix    # Auto-imports all core/*.nix
  │   ├── ui-options.nix # UI tokens (my.ui.*)
  │   ├── nix.nix        # Nix settings
  │   ├── primary-user.nix
  │   ├── network.nix
  │   └── packages.nix
  │
  ├── desktop/           # Desktop environment
  │   ├── sway.nix       # WM (NixOS + HM)
  │   ├── waybar.nix     # Status bar (HM)
  │   ├── foot.nix       # Terminal (HM)
  │   └── wofi.nix       # Launcher (HM)
  │
  ├── system/            # System-level features
  │   ├── fonts.nix
  │   ├── unfree-packages.nix
  │   ├── ly-dm.nix
  │   └── agenix.nix
  │
  ├── home/              # Home Manager core
  │   ├── shell.nix
  │   ├── git.nix
  │   ├── ssh.nix
  │   └── theme.nix
  │
  ├── hardware/          # Hardware features
  │   ├── nvidia.nix
  │   └── bluetooth.nix
  │
  └── apps/              # Application bundles
      └── browsers.nix
```

### Feature anatomy

Each feature:

1. **Declares options** under `features.<name>.*`
2. **Self-gates** on `features.<name>.enable`
3. **Accesses UI tokens** directly via `config.my.ui`
4. **Contains both NixOS and HM config** when needed
5. **Has no hidden dependencies** on other features

Example feature structure:

```nix
# features/desktop/foot.nix
{ config, lib, ... }:
let
  cfg = config.features.foot;
  ui = config.my.ui;  # Direct access!
in {
  options.features.foot = {
    enable = lib.mkEnableOption "Foot terminal";
    extraSettings = lib.mkOption { /* ... */ };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration
    home-manager.sharedModules = [{
      programs.foot = {
        enable = true;
        settings.main.font = "${ui.monoFont.family}:size=${toString ui.monoFont.size}";
        # ... uses ui.terminal.palette, ui.colors, etc.
      };
    }];
  };
}
```

---

## Hosts: thin overrides only

`hosts/<name>/default.nix` files must be **thin**.

They are allowed to:

* import hardware configuration
* select profiles
* override UI tokens (`my.ui.*`)
* enable/configure features (`features.*`)
* toggle host-specific feature options

They must **not**:

* define users
* install packages directly
* define services wholesale
* contain implementation details

**Rule:**
If two hosts should behave the same by default, the logic must not live in `hosts/`.

Example host:

```nix
# hosts/home-pc/default.nix
{...}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix
    ../../profiles/workstation.nix
  ];

  networking.hostName = "home-pc";
  time.timeZone = "Europe/Zurich";

  # UI token overrides (optional)
  # my.ui.font.size = 15;

  # Feature configuration
  features.nvidia.enable = true;
  features.bluetooth.enable = true;
  features.sway.extraFlags = ["--unsupported-gpu"];
  features.waybar.position = "bottom";
}
```

---

## Profiles: role composition

Profiles define **roles**, not machines.

### `profiles/minimal.nix`

The minimal baseline shared by all interactive systems.

Characteristics:

* imports `features/core` (auto-imported baseline)
* ~10 core packages
* SSH client enabled
* basic shell/editor/tooling
* no Home Manager
* no graphical stack
* no login manager

This profile is intentionally boring and stable.

### `profiles/workstation.nix`

Extends `minimal` and adds a desktop environment.

Characteristics:

* imports `minimal`
* enables Home Manager
* imports desktop features explicitly
* enables a login manager
* imports system/hardware/app features

Example:

```nix
# profiles/workstation.nix
{...}: {
  imports = [
    ../profiles/minimal.nix

    # System features
    ../features/system/fonts.nix
    ../features/system/ly-dm.nix
    ../features/system/agenix.nix

    # Desktop features
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/foot.nix
    ../features/desktop/wofi.nix

    # Hardware features (enabled per-host)
    ../features/hardware/nvidia.nix
    ../features/hardware/bluetooth.nix

    # App features
    ../features/apps/browsers.nix
  ];

  # Enable features
  features.sway.enable = true;
  features.waybar.enable = true;
  features.foot.enable = true;
  features.wofi.enable = true;
  features.browsers.enable = true;
}
```

All graphical/UI behavior starts here or below — never in `minimal`.

---

## Users: defined once

The **primary user** is defined in a shared core feature.

* User identity declared in `features/core/primary-user.nix`
* User configuration in `hosts/<name>/users.nix`
* Hosts must not redefine the primary user
* Hosts may add extra users only when explicitly required

This guarantees a consistent `$HOME` identity across machines.

---

## Secrets: agenix only

All secrets are managed via **agenix**.

Rules:

* no plaintext secrets in Nix
* no string-typed secret options
* services consume secrets via file paths only
* encrypted material lives under `secrets/*.age`

Features declare:

```nix
age.secrets.<name>.path
```

Consumers reference the path. Nothing else is allowed.

---

## UI tokens (`my.ui.*`)

UI tokens represent **host-specific display properties**, such as:

* font families and sizes
* colors
* scaling
* terminal palettes

Properties:

* declared in `features/core/ui-options.nix`
* set at the system level (optionally overridden in hosts)
* accessible everywhere via `config.my.ui`
* consumed by features directly
* never mutated or derived from within modules

UI tokens are **inputs**, not configuration.

Example usage in features:

```nix
# Direct access - no specialArgs needed!
let
  ui = config.my.ui;
in {
  programs.waybar.style = ''
    * {
      font-family: "${ui.monoFont.family}";
      font-size: ${toString ui.monoFont.sizePx}px;
    }
    window#waybar {
      background: ${ui.colors.background};
      color: ${ui.colors.foreground};
    }
  '';
}
```

---

## Desktop system

The desktop environment is implemented as **dendritic features**.

Each desktop component (WM, bar, launcher, terminal) is a self-contained feature that:

* self-gates on `features.<name>.enable`
* contains both NixOS and Home Manager config when needed
* directly accesses UI tokens via `config.my.ui`
* provides host-level override options

### Desktop features

* **sway.nix** – Window manager + swaylock + mako + session setup
  - Options: `enable`, `extraFlags`, `extraConfig`, `keybindings`
  - Includes: PAM setup, XDG portal, session packages

* **waybar.nix** – Status bar
  - Options: `enable`, `position`, `extraSettings`

* **foot.nix** – Terminal emulator
  - Options: `enable`, `extraSettings`

* **wofi.nix** – Application launcher
  - Options: `enable`, `extraSettings`

### Adding a new desktop component

1. Create `features/desktop/newcomponent.nix`
2. Add `options.features.newcomponent.enable`
3. Self-gate on that option
4. Access UI tokens via `config.my.ui`
5. Import in `profiles/workstation.nix`
6. Enable in workstation profile

No cross-feature dependencies. No normalization layer. No magic.

---

## System vs Home Manager responsibilities

**NixOS modules** handle:

* hardware
* login managers
* session setup
* system services
* secrets

**Home Manager modules** handle:

* user programs
* desktop configuration
* dotfiles
* user services

Features may contain **both** when the component requires system-level setup (e.g., Sway needs PAM for swaylock, session packages for the display manager).

---

## Directory structure (canonical)

```
.
├── flake.nix                 # flake-parts entry point
├── flake-modules/
│   ├── baseline.nix          # Flake-wide baseline
│   └── nixos.nix             # Host configurations
│
├── features/                 # Self-contained features
│   ├── core/                 # Auto-imported baseline
│   ├── desktop/              # Desktop environment
│   ├── system/               # System-level features
│   ├── home/                 # Home Manager core
│   ├── hardware/             # Hardware features
│   └── apps/                 # Application bundles
│
├── profiles/                 # Role composition
│   ├── minimal.nix
│   └── workstation.nix
│
├── hosts/                    # Host-specific overrides
│   ├── home-pc/
│   └── laptop/
│
├── modules/                  # Remaining non-feature modules
│   ├── nixos/
│   └── home/
│
├── secrets/                  # agenix-encrypted only
├── lib/
└── pkgs/
```

This structure is part of the spec.

---

## Design goals (explicit)

This system is designed so that:

* features are self-contained and composable
* hosts remain boring and declarative
* profiles explicitly list features (no auto-discovery)
* adding a new feature requires minimal changes
* UI tokens flow naturally without specialArgs
* no hidden dependencies or magic compilation
* Home Manager config is identical across machines by default
* secrets are never mishandled
* the system is readable months later without archeology

---

## Feature patterns

### Pattern 1: Home Manager only

```nix
{ config, lib, ... }:
let
  cfg = config.features.myfeature;
  ui = config.my.ui;
in {
  options.features.myfeature.enable = lib.mkEnableOption "My feature";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [{
      programs.myprogram = {
        enable = true;
        # Use ui.* directly
      };
    }];
  };
}
```

### Pattern 2: NixOS + Home Manager

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.features.myfeature;
  ui = config.my.ui;
in {
  options.features.myfeature.enable = lib.mkEnableOption "My feature";

  config = lib.mkIf cfg.enable {
    # NixOS system-level config
    services.mysystem.enable = true;
    security.pam.services.myservice = {};

    # Home Manager user-level config
    home-manager.sharedModules = [{
      programs.myprogram.enable = true;
    }];
  };
}
```

### Pattern 3: Optional hardware

```nix
{ config, lib, ... }:
let cfg = config.features.hardware-feature;
in {
  options.features.hardware-feature = {
    enable = lib.mkEnableOption "Hardware feature";
    optionA = lib.mkOption { /* ... */ };
  };

  config = lib.mkIf cfg.enable {
    hardware.something.enable = true;
    # ... hardware-specific config
  };
}
```

---

## Status

This document is **normative**.

The implementation has been refactored to match this specification through 8 phases:
1. ✅ Flake-parts infrastructure
2. ✅ Core features structure
3. ✅ First dendritic feature
4. ✅ Desktop features conversion
5. ✅ Workstation profile update
6. ✅ Host configuration update
7. ✅ Cleanup of old files
8. ✅ Remaining features organization
