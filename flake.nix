{
  description = "A very basic flake";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    flake-utils.url = "github:numtide/flake-utils";

    src.url = "github:zadam/trilium";
    src.flake = false;
  };
  outputs = { self, dream2nix, flake-utils, src, ... }@inputs:
    (dream2nix.lib.makeFlakeOutputs {
      systems = flake-utils.lib.defaultSystems;
      config.projectRoot = ./.;
      source = src;
      settings = [
        {
          subsystemInfo.noDev = true;
          subsystemInfo.nodejs = 18;
        }
      ];
    });
}
