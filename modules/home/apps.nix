{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ungoogled-chromium
    keepassxc
    zed-editor
  ];
}
