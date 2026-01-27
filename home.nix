{ config, pkgs, ... }:

{
  home.username = "nathan";
  home.homeDirectory = "/home/nathan";

  # font setup 
  fonts.fontconfig.enable = true;

  # Import files from the current configuration directory into the Nix store,
  # and create symbolic links pointing to those store files in the Home directory.

  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # Import the scripts directory into the Nix store,
  # and recursively generate symbolic links in the Home directory pointing to the files in the store.
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    nerd-fonts.fira-mono # font

    ripgrep    # recursively searches directories for a regex pattern
    fzf        # A command-line fuzzy finder
    zoxide     # better ls
    lazygit    # terminal git client

    nix-output-monitor # provides the 'nom' command, works like 'nix' but more output in the logs

    discord-ptb
    neofetch           # display system info 

    darktable     # raw photo editing application
    foliate       # pdf reader

    # programming stuff
    go
    rustup
    godot

    # nvim depedencies 
    gcc
    ripgrep
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Nathan Perez";
      user.email = "me@nathanperez.dev";
    }; 
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    secureSocket = false;
    mouse = true;
    clock24 = true;
    prefix = "C-a";
  };

  # terminal 
  programs.alacritty = {
    enable = true;
    theme = "catppuccin";
    settings = {
      font = {
        size = 12;
        normal.family = "FiraMono Nerd Font Mono";
      };
      selection.save_to_clipboard = true;
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "zoxide"
      ];
      theme = "agnoster";
    };
    shellAliases = {
      # nixOS stuff
      nr  = "sudo nixos-rebuild switch --flake .#pc";  # rebuild and switch
      nb  = "sudo nixos-rebuild build --flake .#pc";   # rebuild no switch

    };
    initContent = ''
      neofetch
    '';
  };
  
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
