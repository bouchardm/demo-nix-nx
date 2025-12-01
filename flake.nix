{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
  };
  outputs = { self, nixpkgs, bun2nix }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.hello = pkgs.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    packages.x86_64-linux.demo = pkgs.stdenv.mkDerivation {
      pname = "demo";
      name = "demo";
      src = ./.;
      nativeBuildInputs = [
        bun2nix.packages.x86_64-linux.default.hook
      ];
      bunDeps = bun2nix.packages.x86_64-linux.default.fetchBunDeps {
        bunNix = ./bun.nix;
      };
      buildPhase = ''
        bun build packages/link/index.ts --outdir packages/link/dist
        bun build packages/app/index.ts --outfile packages/app/bin/cli --compile
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -R packages/app/bin/cli $out
      '';
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = [
        pkgs.bun
        bun2nix.packages.x86_64-linux.default
        pkgs.biome
      ];
    };
  };
}
