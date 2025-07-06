{
  config,
  lib,
  pkgs,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kp:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kp).success
    && (!kp.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;

  latestKernelPackage = lib.last (
    lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );

  # clionWithCopilot = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.clion [ "github-copilot" ];
  # roverWithCopilot = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [ "github-copilot" ];
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = latestKernelPackage;
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "user"
      ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 8;
    };
  };
  nixpkgs.config.allowUnfree = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics.enable = true;

  fileSystems."/" = {
    device = "penguins/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home" = {
    device = "penguins/home";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/usr" = {
    device = "penguins/usr";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/work" = {
    device = "penguins/work";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "penguins/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/etc" = {
    device = "penguins/etc";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  boot.kernelParams = [
    "zfs.zfs_arc_max=12884901888"
    "mitigations=off"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    devNodes = "/dev/disk/by-id";
    extraPools = [ "penguins" ];
  };

  systemd.services.zfs-mount.enable = false;

  virtualisation.docker.enable = true;

  networking = {
    hostName = "emperor";
    networkmanager.enable = true;
    hostId = "1023e441";
    firewall.enable = false;
  };

  programs.wireshark.enable = true;

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_US.UTF-8";
  #   console = {
  #     font = "Lat2-Terminus16";
  #     keyMap = "us";
  #     useXkbConfig = true; # use xkb.options in tty.
  #   };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle,grp_led:caps";
      };
    };

    libinput.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager = {
      plasma6.enable = true;
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };

  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  security.sudo.wheelNeedsPassword = false;

  systemd.tmpfiles.rules = [
    # type  path   mode  user group  age  argument
    # “d”   = directory (create if missing & always fix perms)
    # 2775  = rwx for owner+group, set-gid so new files inherit ‘users’
    "d /work 2775 user users - -"
  ];
  programs.zsh.enable = true;

  users.users.user = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "wireshark"
    ];
    packages = with pkgs; [
      tree
    ];
    initialPassword = "initial";
    shell = pkgs.zsh;
  };

  users.defaultUserShell = pkgs.zsh;

  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;

  environment.systemPackages = lib.mkMerge [
    (with pkgs; [
      comma
      delta
      dua
      dust
      fd
      glow
      tokei
      pavucontrol
      home-manager
      gajim
      telegram-desktop
      ripgrep
      bat
      git
      wget
      mc
      curl
      imhex
      kubernetes-helm
      llvm_20
      unzip
      nil
      nixd
      htop
      btop
      sysstat
      iftop
      cpufrequtils
      powertop
      pciutils
      usbutils
      mesa-demos
      vulkan-tools
      nmap
      rustup
      protobuf
      terraform
      awscli2
      bind.dnsutils
      file
      github-cli
      pkg-config
      udev
      direnv
      hyperfine
      nfs-utils
      coreutils
      gcc
      strace
      mold
      (python3.withPackages (
        p: with p; [
          ipython
          numpy
          requests
          tqdm
        ]
      ))
      wget
      whois
      go_1_24
      ungoogled-chromium
      cachix
      cargo-expand
      cargo-outdated
      cargo-nextest
      clang-tools
      cmake
      ffmpeg-full
      lm_sensors
      smartmontools
      tailscale
      vlc
      haruna
      libreoffice-fresh
      jetbrains-toolbox
      zed-editor

      # jetbrains.pycharm-professional
      # roverWithCopilot
      # clionWithCopilot
      # jetbrains.idea-ultimate

      jetbrains-toolbox

      thunderbird
    ])
    (with pkgs.kdePackages; [
      konsole
      dolphin
      kate
      spectacle
      gwenview
      okular
      ark
      kcalc
      kolourpaint
      kdeconnect-kde
    ])
    [ config.boot.kernelPackages.perf ]
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    (google-fonts.override { fonts = [ "Poppins" ]; })
    jetbrains-mono
    fira-code
    fira-code-symbols
    dosis
    iosevka
  ];

  environment.sessionVariables = {
    KWIN_DRM_NO_AMS = "1"; # work around DCN bug
    # optional fine-tuning if you still see artefacts
    # KWIN_DRM_USE_MODIFIERS = "0";
  };

  system.stateVersion = "25.05";
}
