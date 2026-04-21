{ config, pkgs, unstable,  home, inputs, ... }:

{
  home.username = "nathan";
  home.homeDirectory = "/home/nathan";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # git
  home.activation.createGitRepos = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/GitRepos
  '';
  programs.git = {
    enable = true;
    settings = { 
      user.name = "Nathan Perez";
      user.email = "contact@nathanperez.dev";
    };
  };


  # tmux
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

  # alacritty 
  programs.alacritty = {
    enable = true;
    theme = "catppuccin";
    settings = {
      font = {
        size = 12;
        normal.family = "JetBrainsMono Nerd Font";
      };
      selection.save_to_clipboard = true;
    };
  };

  # zsh 
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "agnoster";
    };
    shellAliases = {
      nr  = "sudo nixos-rebuild switch --flake .#pc";
      nb  = "sudo nixos-rebuild build --flake .#pc";
      nfu = "nix flake update";
    };
    initContent = ''
      fastfetch
      eval "$(zoxide init zsh)"
    '';
  };

  home.packages = with pkgs; [

    firefox
    zoxide
    lazygit
    alacritty
    fastfetch
    nix-output-monitor
    discord-ptb
    teamspeak6-client
    heroic
    prismlauncher
    darktable
    vlc
    obs-studio

    # neovim stuffs
    pkgs.unstable.neovim
    ripgrep
    fzf
    gcc
    lua-language-server
    omnisharp-roslyn
    dotnet-sdk_8
    dotnet-runtime_8

  ];
}
