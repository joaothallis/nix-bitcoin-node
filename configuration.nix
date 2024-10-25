{ config, pkgs, lib, ... }: {
  imports = [
    <nix-bitcoin/modules/presets/secure-node.nix>

    ./hardware-configuration.nix
  ];
  services.bitcoind.dataDir = "/ssd";

  services.bitcoind.txindex = true;

  services.mempool.enable = true;

  nix-bitcoin.onionServices.mempool-frontend.enable = true;

  networking.hostName = "beelink";
  time.timeZone = "UTC";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnEUs9uctH6i4pWCJh1t3Q+WpuVHLjd4KHhHD85VyJS"
    ];
  };

  users.users.operator.extraGroups = [ "wheel" ];

  environment.systemPackages = with pkgs; [
  ];

  services.tailscale.enable = true;

  system.stateVersion = "23.05";

  nix-bitcoin.configVersion = "0.0.85";
}
