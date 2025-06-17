{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "thanos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Dhaka";

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

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.ratul = {
    isNormalUser = true;
    description = "Rezwan Ahmed Ratul";
    extraGroups = [ "networkmanager" "wheel" "lp" ];  # added "lp" group for Bluetooth permissions
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.krdc
      kdePackages.qtwebengine
      kdePackages.kdeconnect-kde
      kdePackages.bluedevil
    ];
  };

  programs.firefox.enable = false;

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Explicitly enable bluetooth systemd service
  systemd.services.bluetooth = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    brave
    google-chrome
    alacritty
    htop
    btop
    bat
    gedit
    vlc
    exfat
    exfatprogs
    ntfs3g
    nerd-fonts.jetbrains-mono
    lohit-fonts.bengali
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-extra
    libreoffice-qt6-fresh
    pkgs.qt6.qtvirtualkeyboard
    yt-dlp
    ffmpeg
    python3Packages.pip
    bluez
    #blueman
    vscode
    gcc
    gnumake
    cmake
  ];

  # Nix Garbage Collection Automation (weekly, keep only 7 days)
  systemd.services.nix-gc-cleanup = {
    description = "Nix Garbage Collector (keep only 7 days)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "nix-gc-cleanup" ''
        #!/bin/sh
        nix-collect-garbage --delete-older-than 7d
        nix-collect-garbage -d
        nix store gc
      ''}";
    };
  };

  systemd.timers."nix-gc" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  system.stateVersion = "25.05";
}

