{ ... }:

{
  # red light filter
  services.wlsunset = {
    enable = true;

    temperature = {
      day = 6500;
      night = 3000;
    };

    # Zurich hardcoded for now
    latitude = 47.3769;
    longitude = 8.5417;
  };
}
