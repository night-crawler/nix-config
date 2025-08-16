{ pkgs, lib, ... }:
with lib;
let
  exe = pkgs.lib.getExe;
in
{
  home.stateVersion = "25.05";
  programs.git = {
    enable = true;
    userName = "night-crawler";
    userEmail = "lilo.panic@gmail.com";

    extraConfig = {
      sequence.editor = "${exe pkgs.git-interactive-rebase-tool}";
    };
  };

  home.packages = with pkgs; [
    neofetch
    uv
    jq
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    bpf-linker
    # zed-editor

    # Essential libraries for building Python itself
    zlib
    bzip2
    xz
    openssl
    sqlite
    readline
    libffi
    ncurses
    tk
    libuuid

    # Common libraries for popular Python packages (e.g., Pillow)
    libjpeg
    libpng
    libwebp
    libxml2
    libxslt

    # video
    ffmpeg-full
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad

    s-tui
    orca-slicer
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "cursor"
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "sudo"
        "colored-man-pages"
        "history-substring-search"
      ];
      theme = "robbyrussell";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
    ];

    shellAliases = {
      nr = "nix run";
      ns = "nix search nixpkgs";

      ll = "ls -lah";
      g = "git";
      k = "kubectl";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$all";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*'";
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
  };

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "lua"
      "basher"
      "dracula"
    ];

    extraPackages = [ pkgs.nixd ];
  };
}
