{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnsupportedSystem = true;
        };
        stdenv = pkgs.stdenv;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        xrnix = stdenv.mkDerivation {
          pname = "xrnix";
          version = "dev";

          src = ./.;

          nativeBuildInputs = [
            pkgs.zig_0_13.hook
          ];

          zigBuildFlags = [
            "-Doptimize=Debug"
            "-Dtarget=aarch64-freestanding"
          ];
        };
      in
      {
        # Use `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # Use `nix flake check`
        checks.formatting = treefmtEval.config.build.check self;

        # nix build .
        packages = {
          inherit xrnix;
          default = xrnix;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Compiler
            zig_0_13

            # Qemu
            qemu_full

            # LSP
            zls
            nil
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      });
}
