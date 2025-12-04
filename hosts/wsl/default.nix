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

  networking.hostName = "wsl";
  wsl.enable = true;
  wsl.defaultUser = "dev";
  wsl.interop.register = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    htop
    btop
    gdu
  ];

  environment.shellAliases = {
    switch = "sudo nixos-rebuild switch";
    deploy = "${pkgs.deploy-rs}/bin/deploy";
  };

  programs.nix-ld.enable = true;

  systemd.user.services.wsl2-ssh-agent = {
    description = "WSL2 SSH Agent Bridge";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    unitConfig = {
      ConditionUser = "!root";
    };
    serviceConfig = {
      ExecStart = "${pkgs.wsl2-ssh-agent}/bin/wsl2-ssh-agent --verbose --foreground --powershell-path=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe --socket=%t/wsl2-ssh-agent.sock";
      Restart = "on-failure";
    };
  };

  environment.variables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/wsl2-ssh-agent.sock";
}
