{ lib, ... }:
{
  options.my.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = "Primary interactive user for this host.";
  };
}

