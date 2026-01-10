{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  system.stateVersion = "25.11";

  imports = [
    ../../modules/shared
    ./hardware-configuration.nix
    ./disko.nix
  ];

  environment.shellAliases = {
    switch = "sudo nixos-rebuild switch";
    deploy = "${pkgs.deploy-rs}/bin/deploy";
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };
  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-resume.enable = true;
  systemd.services.nvidia-hibernate.enable = true;

  programs.bash.interactiveShellInit = ''
    if [ -S "$HOME/.bitwarden-ssh-agent.sock" ]; then
      export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
    fi
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.flatpak.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # services.desktopManager.cosmic.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  nix.settings.trusted-users = [ "@wheel" ];
  security.sudo.extraRules = [
    {
      users = [ "dev" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  users.users.dev = {
    isNormalUser = true;
    description = "dev";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs.unstable; [
      code-cursor
      vscode
      brave
      bitwarden-desktop
      htop
      btop
      gdu
      duf
      lazygit
      lazydocker
      mise
    ];
  };

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    gnomeExtensions.appindicator
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.arc-menu
    gnomeExtensions.paperwm
    gnomeExtensions.user-themes
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals
  ];
}
