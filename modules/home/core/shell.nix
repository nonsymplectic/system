{ ... }:
{
  programs.bash = {
    enable = true;

    # ~/.bashrc content; guard so it only affects interactive shells.
    bashrcExtra = ''
      case $- in
        *i*)
          PS1="\[\033[1;35m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
          ;;
      esac
    '';
  };
}
