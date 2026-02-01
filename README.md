# System Configuration Spec

This repository defines a **host-agnostic, reproducible system and user environment** built with NixOS and Home Manager.

The design emphasizes:

* strict separation of **policy vs implementation**
* **host files as overrides only**
* a **plugin-based desktop system**
* a **single, synced home environment** across machines
* secrets managed **exclusively via agenix**
* minimal baselines composed into richer profiles

This document defines the intended architecture and coding standards.

---

## High-level architecture

The system is split into four conceptual layers:

1. **Hosts** – hardware + overrides only
2. **Profiles** – role-based composition
3. **Modules** – implementation (NixOS + Home Manager)
4. **Options / tokens** – shared declarative interfaces

Each layer has a clearly defined responsibility and must not leak concerns upward or downward.

---

## Hosts: overrides only

`hosts/<name>/default.nix` files must be **thin**.

They are allowed to:

* import hardware configuration
* select profiles
* override UI tokens
* override desktop selection tokens
* toggle host-specific capability flags

They must **not**:

* define users
* install packages directly
* define services wholesale
* contain Home Manager configuration
* contain implementation details

**Rule:**
If two hosts should behave the same by default, the logic must not live in `hosts/`.

---

## Profiles: role composition

Profiles define **roles**, not machines.

### `profiles/minimal.nix`

The minimal baseline shared by all interactive systems.

Characteristics:

* ~10 core packages
* SSH client enabled (`programs.ssh.enable = true`)
* basic shell/editor/tooling
* no Home Manager
* no graphical stack
* no login manager

This profile is intentionally boring and stable.

---

### `profiles/workstation.nix`

Extends `minimal` and adds a desktop environment.

Characteristics:

* imports `minimal`
* enables Home Manager
* enables the desktop plugin system
* enables a login manager (e.g. `ly`)
* enables workstation-only services

All graphical/UI behavior starts here or below — never in `minimal`.

---

## Users: defined once

The **primary user** is defined in a shared system module.

* User definitions live under `modules/nixos/core/users.nix`
* Hosts must not redefine the primary user
* Hosts may add *extra* users only when explicitly required

This ensures a consistent `$HOME` identity across machines.

---

## Secrets: agenix only

All secrets are managed via **agenix**.

Rules:

* no plaintext secrets in Nix
* no string-typed secret options
* services consume secrets via file paths only
* encrypted material lives under `secrets/*.age`

System modules declare:

```nix
age.secrets.<name>.path
```

Consumers reference the path. Nothing else is allowed.

---

## Options and tokens

### Shared option declarations

Pure option declarations live at the **project root** under:

```
options/
```

They define **interfaces**, not behavior.

Examples:

* `options/ui.nix`
* `options/desktop.nix`

These files are imported by both NixOS and Home Manager module graphs to ensure a single source of truth.

---

### UI tokens (`my.ui.*`)

UI tokens represent **host-specific display properties**, such as:

* font family
* font size (pt)
* font size (px)
* colors
* scaling
* ANSI terminal colors

They are:

* set at the system level
* forwarded into Home Manager
* consumed by user-level modules
* never mutated by implementations

UI tokens are *inputs*, not configuration.

---

## Desktop plugin system (Home Manager)

The desktop environment is implemented as a **plugin system** at the Home Manager layer.

This system is:

* window-manager agnostic
* bar agnostic
* launcher agnostic
* terminal agnostic

It provides a stable interface while allowing new components to be added with minimal churn.

---

### Host-facing interface (`my.desktop.*`)

Hosts select desktop components via declarative policy options:

* `my.desktop.enable`
* `my.desktop.wm`
* `my.desktop.bar.enable`
* `my.desktop.bar.backend`
* `my.desktop.bar.position`
* `my.desktop.launcher`
* `my.desktop.terminal`
* ...
* `my.desktop.extraFlags`.<COMPONENT> = [ ... ]
These options express **what** the desktop should be, never **how** it is implemented, host-specifc flag overrides (compatibility, e.g. wm needs special gpu flag) allowed.

---

### Interface module

`modules/home/desktop/interface.nix` is the entry point.

Responsibilities:

* import all desktop plugins unconditionally
* define internal plugin slots
* enforce invariants via assertions
* provide shared wiring (e.g. portals)

It contains **no backend-specific logic**.

---

### Plugin modules

Plugins live under:

```
modules/home/desktop/
  backends/
  bars/
  launchers/
  terminals/
```

Each plugin:

* self-gates on `config.my.desktop.*`
* installs its own packages
* writes its own Home Manager program config
* may publish internal outputs

Plugins must not depend on each other directly.

---

### Internal plugin outputs (“registry slots”)

Some components must publish implementation results that other components consume.

This is handled via **internal registry slots**:

```
my.desktop._resolved.*
```

Example:

* `my.desktop._resolved.barCommand`

Rules:

* `_resolved.*` is internal plumbing
* hosts must never set these
* only plugins may write to them
* interface module enforces correctness

This allows adding new plugins without touching existing backends.

---

### Invariants

The interface module enforces invariants such as:

* if a bar is enabled, exactly one bar plugin must publish a command
* if the desktop is enabled, exactly one WM backend must be active

Violations fail fast at evaluation time.

---

## Home Manager: package vs configuration split

Home Manager modules are split explicitly:

### `modules/home/packages.nix`

* declares **generic user packages**
* no configuration
* no coupling to desktop or services

This file answers the question:
**“What tools do I always want in my `$HOME`?”**

---

### `modules/home/desktop/`

Contains all **desktop-related configuration** and nothing else.

This file answers the question:
**“How does my desktop behave?”**

---

## System vs Home Manager responsibilities

**NixOS modules** handle:

* hardware
* login managers
* session glue (Wayland env, seat, portals)
* services
* secrets

**Home Manager modules** handle:

* user programs
* desktop configuration
* dotfiles
* runtime behavior

No module may cross this boundary.

---

## Directory structure (canonical)

```
.
├── hosts/            # overrides only
├── profiles/         # role composition
├── modules/
│   ├── nixos/        # system implementation
│   └── home/
│       ├── packages.nix
│       └── desktop/  # plugin system
├── options/          # shared interfaces
├── secrets/          # agenix-encrypted only
├── lib/
└── pkgs/
```

This structure is part of the spec.

---

## Design goals (explicit)

This system is designed so that:

* hosts remain boring and declarative
* Home Manager config is identical across machines by default
* adding a new desktop component requires minimal changes
* implementation complexity is hidden behind stable interfaces
* secrets are never mishandled
* the system is readable months later without archeology

---

### Status

This document is **normative**.
Code must be adapted to match it, not the other way around.
