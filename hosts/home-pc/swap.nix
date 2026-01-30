{ ... }:
{
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 20 * 1024; # MiB = 20 GiB
    }
  ];
}
