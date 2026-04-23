{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];


  sops.secrets.font = {
    owner = "nathan";
    path = "/home/nathan/.local/share/fonts/cool-font.ttf";
    format = "binary";
    sopsFile = ./Secret/font.ttf;
  };

  sops = {
    defaultSopsFile = ./Secret/secrets.yaml;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/home/nathan/.config/sops/age/keys.txt";
    };
  };

  sops.secrets.github_ssh_key = {
    owner = "nathan";
    path = "/home/nathan/.ssh/github";
  };

  

  networking.hostName = "pc";

  # nvidia driver stuff
  services.xserver.videoDrivers = [ "nvidia" ];

  # nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # boot 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking 
  networking.networkmanager.enable = true;

  # time
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # display 
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true; 

  # audio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse = {
      enable = true; 
    };
  };
  security.rtkit.enable = true;
  services.printing.enable = true;    

  # fonts
  # fonts.packages = with pkgs; [
  #   nerd-fonts.jetbrains-mono
  # ];

  # shell
  programs.zsh.enable = true;

  # user
  users.users.nathan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
  };

  # steam
  programs.steam.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # ← this is missing!
  };
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;  # ← recommended for stability
  };

  # bluetooth
  hardware.xone.enable = true; 
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  boot.kernelModules = [ "xpad" ];
  services.blueman.enable = true;

  # ssh
  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


  # keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # global
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  system.stateVersion = "25.11";
}
