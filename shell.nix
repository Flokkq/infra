{pkgs ? (import ./nixpkgs.nix) {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    gnupg
    git-cliff

    nushell
    just
    pre-commit
    deadnix
    act
    jq
  ];
}
