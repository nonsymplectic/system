{pkgs, ...}: let
  greeting = ''
     _      _  ____ _     ____  _       _  ____ _____    _  __ _  _      _____
    / \__/|/ \/   _Y \ /|/  _ \/ \     / \/ ___Y__ __\  / |/ // \/ \  /|/  __/
    | |\/||| ||  / | |_||| / \|| |     | ||    \ / \    |   / | || |\ ||| |  _
    | |  ||| ||  \_| | ||| |-||| |_/\  | |\___ | | |    |   \ | || | \||| |_//
    \_/  \|\_/\____|_/ \|\_/ \|\____/  \_/\____/ \_/    \_|\_\\_/\_/  \|\____\
  '';

  # Create session files
  sessionsDir = pkgs.runCommand "greetd-sessions" {} ''
    mkdir -p $out/share/wayland-sessions

    cat > $out/share/wayland-sessions/sway.desktop << EOF
    [Desktop Entry]
    Name=Sway
    Comment=Sway Wayland compositor
    Exec=sway
    Type=Application
    EOF

    cat > $out/share/wayland-sessions/tty.desktop << EOF
    [Desktop Entry]
    Name=TTY
    Comment=Plain text console
    Exec=${pkgs.bash}/bin/bash --login
    Type=Application
    EOF
  '';
in {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions ${sessionsDir}/share/wayland-sessions --remember --greeting '${greeting}' --asterisks --asterisks-char '*'";
        user = "greeter";
      };
    };
  };
}
