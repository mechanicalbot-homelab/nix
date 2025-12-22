{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.x.wsl;
in
{
  options.x.wsl = {
    enable = lib.mkEnableOption "WSL configuration";
    username = lib.mkOption {
      type = lib.types.str;
      description = "Default WSL username";
      example = "dev";
    };
  };

  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = cfg.username;
      interop.register = true;
      docker-desktop.enable = true;
    };

    # vscode remote
    programs.nix-ld.enable = true;

    # SSH agent forwarding
    environment.variables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/wsl2-ssh-agent.sock";
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
  };
}
