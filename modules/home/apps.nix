{ pkgs, ... }:
{
  home.packages = with pkgs; [
    chromium
    keepassxc
    zed-editor
  ];
}
