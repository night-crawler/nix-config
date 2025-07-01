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
    jq
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
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
}
