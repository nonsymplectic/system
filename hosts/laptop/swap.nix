{...}: {
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 10 * 1024; # MiB = 20 GiB
    }
  ];
}
