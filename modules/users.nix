{ config, pkgs, ... }:

{
  users.users.qreenify = {
    isNormalUser = true;
    description = "qreenify";
    extraGroups = [ "networkmanager" "wheel" "fuse" "video" "render" "input" "libvirtd" ];
    shell = pkgs.nushell;
  };
}
