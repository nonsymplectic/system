# System Configuration Spec

This repository defines a **host-agnostic, reproducible system and user environment** built with NixOS and Home Manager.

The design emphasizes:

* strict separation of **policy vs implementation**
* **host files as overrides only**
* a **plugin-based desktop system**
* a **single, synced home environment** across machines
* secrets managed **exclusively via agenix**
* minimal baselines composed into richer profiles

This document defines the **normative architecture**.
Code must be adapted to match it, not the other way around.

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
* override desktop policy
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
* SSH client enabled
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
* enables a login manager
* enables workstation-only services

All graphical/UI behavior starts here or below — never in `minimal`.

---

## Users: defined once

The **primary user** is defined in a shared system module.

* User definitions live under `modules/nixos/core/users.nix`
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

These files are imported into **both** the NixOS and Home Manager module graphs to ensure a single source of truth.

---

### UI tokens (`my.ui.*`)

UI tokens represent **host-specific display properties**, such as:

* font families and sizes
* colors
* scaling
* terminal palettes

Properties:

* set at the system level
* forwarded into Home Manager as an **immutable policy**
* consumed by user-level modules
* never mutated or derived from within Home Manager modules

UI tokens are **inputs**, not configuration.

---

## Desktop system (Home Manager)

The desktop environment is implemented entirely at the **Home Manager layer** as a plugin system.

The system is:

* window-manager agnostic
* bar agnostic
* launcher agnostic
* terminal agnostic

It provides a stable policy interface while allowing new components to be added with minimal churn.

---

### Desktop policy (`my.desktop.*`)

Hosts select desktop behavior via declarative **policy options**:

* `my.desktop.enable`
* `my.desktop.wm`
* `my.desktop.bar.enable`
* `my.desktop.bar.backend`
* `my.desktop.bar.position`
* `my.desktop.launcher`
* `my.desktop.terminal`
* `my.desktop.extraFlags.<component> = [ ... ]`

These options express **what** the desktop should be, never **how** it is implemented.

---

### Policy forwarding and normalization

The desktop system uses **single-pass normalization**:

1. `my.desktop` is defined at the system level.
2. It is forwarded into Home Manager as an **immutable argument** (`desktopPolicy`).
3. The Home Manager desktop interface:

   * derives a single **normalized wiring payload** (`desktop`)
   * enforces invariants
   * exposes the normalized payload to all desktop plugins

The normalized payload contains:

* resolved component identifiers
* launch commands (e.g. bar / launcher / terminal)
* component flags
* minimal session wiring (environment variables)

Normalization is **wiring-only**:

* no UI styling
* no backend configuration
* no module-local interpretation

There is exactly **one interpretation** of desktop policy.

---

### Desktop interface module

`modules/home/desktop/interface.nix` is the entry point.

Responsibilities:

* import all desktop plugins unconditionally
* normalize `desktopPolicy → desktop`
* forward immutable UI tokens (`uiPolicy`)
* enforce invariants at evaluation time
* expose `{ desktop, ui }` to all plugins

The interface contains **no backend-specific configuration**.

---

### Desktop plugin modules

Plugins live under:

```
modules/home/desktop/
  backends/
  bars/
  launchers/
  terminals/
```

Each plugin:

* self-gates on the normalized `desktop` payload
* installs its own packages
* configures its own Home Manager programs
* consumes only `{ desktop, ui }`

Plugins must **not**:

* read `config.my.desktop.*`
* mutate policy
* publish internal registry slots
* depend on other plugins directly

All cross-component coordination flows through the normalized payload.

---

## Home Manager: directories

### `modules/home/packages.nix`

Declares **generic user packages**.

* no configuration
* no coupling to desktop or services

### `modules/home/desktop/`

Contains **all desktop behavior**.

### `modules/home/core/`

Contains **core tool configuarion**

* shell
* git, etc.

---

## System vs Home Manager responsibilities

**NixOS modules** handle:

* hardware
* login managers
* session setup
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
* desktop policy has a single interpretation
* adding a new desktop component requires minimal changes
* implementation complexity is hidden behind stable interfaces
* secrets are never mishandled
* the system is readable months later without archeology

---

### Status

This document is **normative**.
