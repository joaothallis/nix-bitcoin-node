{
  config,
  pkgs,
  lib,
  ...
}:
{
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

  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    enabledCollectors = [ "systemd" ];
    extraFlags = [
      "--collector.ethtool"
      "--collector.softirqs"
      "--collector.tcpstat"
      "--collector.wifi"
    ];
  };

  # http://beelink.tail49bf1.ts.net:9000/metrics
  systemd.services.tailscale-funnel = {
    description = "Tailscale Funnel Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale funnel ${toString config.services.prometheus.exporters.node.port}";
      Restart = "on-failure";
    };

    wantedBy = [ "multi-user.target" ];
  };

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

  environment.systemPackages =
    with pkgs;
    [
    ];

  services.tailscale.enable = true;

  system.stateVersion = "23.05";

  nix-bitcoin.configVersion = "0.0.85";
}
