{pkgs, ...}: let
  greeting = ''
     _      _  ____ _     ____  _       _  ____ _____    _  __ _  _      _____
    / \__/|/ \/   _Y \ /|/  _ \/ \     / \/ ___Y__ __\  / |/ // \/ \  /|/  __/
    | |\/||| ||  / | |_||| / \|| |     | ||    \ / \    |   / | || |\ ||| |  _
    | |  ||| ||  \_| | ||| |-||| |_/\  | |\___ | | |    |   \ | || | \||| |_//
    \_/  \|\_/\____|_/ \|\_/ \|\____/  \_/\____/ \_/    \_|\_\\_/\_/  \|\____\
  '';
in {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway --remember --greeting '${greeting}' --asterisks --asterisks-char '*'";
        user = "greeter";
      };
    };
  };
}
