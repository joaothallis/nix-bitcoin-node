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

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 9001;
        serve_from_sub_path = true;
      };
    };
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      access = "proxy";
      url = "http://127.0.0.1:${toString config.services.prometheus.port}";
    }
  ];

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
