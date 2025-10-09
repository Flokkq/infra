{pkgs ? (import ./nixpkgs.nix) {}}:
pkgs.mkShell {
  buildInputs = with pkgs;
    [
      gnupg
      git-cliff

      nushell
      just
      pre-commit
      deadnix
      act
      jq
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];
}
