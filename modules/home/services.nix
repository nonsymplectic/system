{...}: {
  # red light filter
  services = {
    wlsunset = {
      enable = true;

      temperature = {
        day = 6500;
        night = 3000;
      };

      # Zurich hardcoded for now
      latitude = 47.3769;
      longitude = 8.5417;

      # needs to eventually refer to desktop plugin awarded target, without it display environment variables aren't set
      systemdTarget = "sway-session.target";
    };
  };
}
