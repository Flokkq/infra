{}: let
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  hostKinds = [
    "rpi-5"
    "server"
  ];
in rec {
  inherit systems hostKinds;

  isPi = host:
    host.system.type == "rpi-5";

  isServer = host:
    !isPi host;

  isX86 = host:
    host.system.arch == "x86_64-linux";

  isAarch = host:
    !isX86 host;
}
