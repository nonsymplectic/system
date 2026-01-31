{ pkgs, ... }:

{
  /* ============================================================
     Development tools (Home Manager layer)
     ------------------------------------------------------------
     Purpose:
       - Core developer-facing CLI tools
       - Available uniformly across all machines
     ============================================================ */


  /* ============================================================
     Code formatters
     ------------------------------------------------------------
     Opinionated, deterministic formatters for languages used
     across the repo(s). Kept in HM to ensure availability
     independent of host role.
     ============================================================ */

  home.packages = with pkgs; [
    # Nix formatter
    nixpkgs-fmt

    # Python formatter
    black
  ];
}
