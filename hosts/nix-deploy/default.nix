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

  networking.hostName = "nix-deploy";

  users.users.dev = {
    isNormalUser = true;
    initialPassword = "dev";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoGbJn//BJtnXEeNQ9mmHZ8KXcJKmB73VGsQ6PR+M7r"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    btop
    gdu
  ];

  environment.shellAliases = {
    switch = "sudo nixos-rebuild switch";
    deploy = "nix run github:serokell/deploy-rs";
  };

  # enable vscode ssh
  programs.nix-ld.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
