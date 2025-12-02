{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
  };
  outputs = { self, nixpkgs, bun2nix }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    alpine = pkgs.dockerTools.pullImage {
      imageName = "alpine";
      # nix run nixpkgs#skopeo -- inspect docker://oven/bun:1
      imageDigest = "sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412";
      finalImageTag = "3.22";
      sha256 = "sha256-tsrC+ZwpRUx8hPsgMOoWkPdVOq8m1e8Yc7oHNlabLek=";
    };
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
        mkdir -p $out/demo
        cp -R packages/app/bin/cli $out/demo
      '';
    };

    packages.x86_64-linux.docker = pkgs.dockerTools.buildImage {
      name = "nix-demo";
      tag = "0.1.0";
      fromImage = alpine;
      copyToRoot = pkgs.buildEnv {
        name = "root";
        paths = [ 
          self.packages.x86_64-linux.demo
        ];
        pathsToLink = ["/demo"];
      };
      config = {
        Entrypoint = [ "/demo/cli" ];
      };
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
