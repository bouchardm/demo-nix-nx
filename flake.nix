{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgsSpecific.url = "github:nixos/nixpkgs?ref=e6f23dc08d3624daab7094b701aa3954923c6bbb";
  };
  outputs = { self, nixpkgs, nixpkgsSpecific }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.hello = pkgs.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = [
        nixpkgsSpecific.legacyPackages.x86_64-linux.bun
        pkgs.biome
      ];
    };
  };
}
