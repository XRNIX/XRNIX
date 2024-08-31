{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
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
            "-Drelease=false"
            "-Dtarget=aarch64-freestanding"
          ];
        };
        runner = pkgs.writeShellApplication {
          name = "runner";
          runtimeInputs = [
            pkgs.qemu_full
          ];

          text = ''
            qemu-system-aarch64 -machine raspi4b -kernel ${xrnix}/bin/XRNIX
          '';
        };
      in
      {
        # Use `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # Use `nix flake check`
        checks = {
          inherit xrnix runner;
          formatting = treefmtEval.config.build.check self;
        };

        # nix build .
        packages = {
          inherit xrnix runner;
          default = xrnix;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = runner;
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
