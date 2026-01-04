{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0026b76840109445";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes =
                  let
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  in
                  {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = mountOptions;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = mountOptions;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = mountOptions;
                    };
                  };
              };
            };
          };
        };
      };
    };
  };
}
