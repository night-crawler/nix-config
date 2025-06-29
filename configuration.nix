# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      name: kp:
      (builtins.match "linux_[0-9]+_[0-9]+" name) != null
      && (builtins.tryEval kp).success
      && (!kp.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    ) pkgs.linuxKernel.packages;

  latestKernelPackage =
    lib.last (lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version)
                     (builtins.attrValues zfsCompatibleKernelPackages));
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.kernelPackages = latestKernelPackage;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  hardware.graphics.enable = true;

  fileSystems."/" =
    { device = "penguins/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home" =
    { device = "penguins/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/usr" =
    { device = "penguins/usr";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/work" =
    { device = "penguins/work";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/nix" =
    { device = "penguins/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/etc" =
    { device = "penguins/etc";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  services.zfs = {
    autoScrub.enable = true;               # weekly scrub
    trim.enable      = true;               # periodic full-pool TRIM
  };
  
  services.tlp.enable = true;
  #services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;
  #services.auto-cpufreq.settings = {
  #  battery = {
  #    governor = "powersave";
  #    turbo = "never";
  #  };
  #  charger = {
  #    governor = "performance";
  #    turbo = "auto";
  #  };
  #};

  boot.kernelParams = [
    "zfs.zfs_arc_max=12884901888"
    "mitigations=off"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    devNodes    = "/dev/disk/by-id";
    extraPools  = [ "penguins" ];
  };

  systemd.services.zfs-mount.enable = false;

  networking = {
    hostName = "emperor";
    networkmanager.enable = true;
    hostId = "1023e441";
    firewall.enable = false;
  };

  time.timeZone = "Europe/Dublin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
#   console = {
#     font = "Lat2-Terminus16";
#     keyMap = "us";
#     useXkbConfig = true; # use xkb.options in tty.
#   };

  services = {
    #xserver.enable = true;
    
    xserver = {
      enable = true;                            # already present
      xkb = {
        # two layouts available system-wide
        layout  = "us,ru";                      # order: English first, Russian second
        options = "grp:caps_toggle,grp_led:caps";
        #  grp:caps_toggle → Caps Lock cycles layouts
        #  grp_led:caps    → Caps LED shows current layout (on = Russian)
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    hashedPassword = "$6$vyuDcMFaLlhHg1Rg$v68/8eVYIQwnSkfXz/cGgGdVHljl0V82CjCcOS8nMwg6EwYXho53M8HvPeaAuUDHFIZ1dbtViOl58y1p4iou30";
  };

  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  services.openssh.enable = true;

  services.tailscale.enable = true;

  environment.systemPackages = lib.mkMerge [
    (with pkgs; [
      gajim telegram-desktop
      ripgrep bat git wget mc curl imhex unzip
      htop btop sysstat iftop cpufrequtils powertop
      lm_sensors smartmontools
      tailscale
      vlc haruna
      libreoffice-fresh
      jetbrains-toolbox zed-editor
      thunderbird
    ])
    (with pkgs.kdePackages; [
      konsole dolphin kate spectacle gwenview okular ark kcalc
      kolourpaint kdeconnect-kde
    ])
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
}

