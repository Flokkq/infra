{}: let
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  hostKinds = [
    "rpi-5"
    "server"
  ];
in {
  inherit systems hostKinds;
}
