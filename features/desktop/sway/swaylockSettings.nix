# swaylock Settings
{
  alpha,
  ui,
}: {
  indicator = true;
  clock = true;

  inside-color = alpha "cc" ui.colors.background;
  inside-clear-color = alpha "cc" ui.colors.muted;
  inside-caps-lock-color = alpha "cc" ui.colors.muted;
  inside-ver-color = alpha "cc" ui.colors.focus;
  inside-wrong-color = alpha "cc" ui.colors.error;

  ring-color = alpha "ff" ui.colors.muted;
  ring-clear-color = alpha "ff" ui.colors.focus;
  ring-caps-lock-color = alpha "ff" ui.colors.focus;
  ring-ver-color = alpha "ff" ui.colors.focus;
  ring-wrong-color = alpha "ff" ui.colors.error;

  line-uses-ring = true;

  separator-color = alpha "00" ui.colors.background;
  key-hl-color = alpha "ff" ui.colors.focus;

  text-color = alpha "ff" ui.colors.foreground;
  text-clear-color = alpha "ff" ui.colors.foreground;
  text-caps-lock-color = alpha "ff" ui.colors.foreground;
  text-ver-color = alpha "ff" ui.colors.foreground;
  text-wrong-color = alpha "ff" ui.colors.foreground;

  layout-bg-color = alpha "cc" ui.colors.background;
  layout-border-color = alpha "ff" ui.colors.muted;
  layout-text-color = alpha "ff" ui.colors.foreground;

  screenshots = true;
  show-keyboard-layout = true;
  show-failed-attempts = true;
  effect-pixelate = 16;
}
