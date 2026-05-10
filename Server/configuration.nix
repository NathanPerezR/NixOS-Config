{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops = {
    defaultSopsFile = ../Secret/server-secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      matrix_registration_shared_secret = {};
      matrix_macaroon_secret_key = {};
      nathan_password = { 
        neededForUsers = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/volume-hil-1/postgresql 0700 postgres postgres -"
    "d /mnt/volume-hil-1/matrix/media 0750 matrix-synapse matrix-synapse -"
  ];

  services.matrix-synapse.settings.media_store_path = "/mnt/volume-hil-1/matrix/media";
  services.postgresql.dataDir = "/mnt/volume-hil-1/postgresql";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nix-server0";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;
  users.users.nathan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = config.sops.secrets.nathan_password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEh8hi8kMZgTNSaUwuJIVJVbPdABN8mJ+SOYCOi/OfqK nathan@pc"
    ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [{
      name = "matrix-synapse";
      ensureDBOwnership = true;
    }];
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "nathanperez.dev";
      public_baseurl = "https://nathanperez.dev";
      enable_registration = false;

      database = {
        name = "psycopg2";
        args = {
          database = "matrix-synapse";
          user = "matrix-synapse";
          host = "/run/postgresql";
        };
      };

      listeners = [{
        port = 8008;
        bind_addresses = [ "127.0.0.1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = false;
        }];
      }];
    };

    extraConfigFiles = [
      config.sops.secrets.matrix_registration_shared_secret.path
      config.sops.secrets.matrix_macaroon_secret_key.path
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@nathanperez.dev";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "matrix.nathanperez.dev" = {
        enableACME = true;
        forceSSL = true;
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            client_max_body_size 50M;
          '';
        };
        locations."/_synapse/client" = {
          proxyPass = "http://127.0.0.1:8008";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            client_max_body_size 50M;
          '';
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
  ];

  system.stateVersion = "25.11";
}
