{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
  ];

  boot.loader.grub.enable = true;
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  services.qemuGuest.enable = true;

  networking.hostName = "dokploy";

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    htop
    btop
    gdu
  ];

  nix.settings.trusted-users = [ "@wheel" ];
  users.users.dev = {
    isNormalUser = true;
    initialPassword = "dev";
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoGbJn//BJtnXEeNQ9mmHZ8KXcJKmB73VGsQ6PR+M7r"
    ];
  };

  # system.activationScripts.expire-dev-password = ''
  #   FLAG_FILE="/var/lib/dev-password-changed"
  #   if id -u dev > /dev/null 2>&1 && [ ! -f "$FLAG_FILE" ]; then
  #     ${pkgs.shadow}/bin/passwd -e dev || true
  #     touch "$FLAG_FILE"
  #   fi
  # '';

  # programs.nix-ld.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
