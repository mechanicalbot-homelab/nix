{
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  username = "dev";
in
{
  system.stateVersion = "25.11";

  imports = [
    ../../modules/shared
    ../../modules/wsl
  ];

  x.wsl.enable = true;
  x.wsl.username = username;

  networking.hostName = "wsl";

  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoGbJn//BJtnXEeNQ9mmHZ8KXcJKmB73VGsQ6PR+M7r"
    ];
  };

  services.openssh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    htop
    btop
    gdu
    duf
    iperf
  ];

  environment.shellAliases = {
    switch = "sudo nixos-rebuild switch";
    deploy = "${pkgs.deploy-rs}/bin/deploy";
  };

  programs = {
    lazygit = {
      enable = true;
      settings = {
        gui = {
          splitDiff = "always";
        };
        git = {
          pagers = [
            {
              pager = "${pkgs.ydiff}/bin/ydiff -p cat -s --wrap --width={{columnWidth}}";
              colorArg = "never";
              externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always";
            }
            {
              pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
            }
            {
              pager = "${pkgs.delta}/bin/delta --dark --paging=never";
            }
          ];
        };
      };
    };
  };
}
