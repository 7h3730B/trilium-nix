{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    src.url = "github:zadam/trilium";
    src.flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, src }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system ; };
        nodejs = pkgs.nodejs-16_x;

        appBuild = pkgs.stdenv.mkDerivation {
          inherit src;
          name = "trilium-server";
          version = "0.1.0";
          buildInputs = [ nodejs pkgs.stdenv.cc.cc.lib ];

          buildPhase = ''
            runHook preBuild

            npm install

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            mkdir -p $out/share/trilium-server

            cp -r ./* $out/share/trilium-server

            runHook postInstall
          '';

          postFixup = ''
            cat > $out/bin/trilium-server <<EOF
            #!${pkgs.stdenv.cc.shell}
            cd $out/share/trilium-server
            exec ./node/bin/node src/www
            EOF
            chmod a+x $out/bin/trilium-server
          '';
        };
      in with pkgs; {
        defaultPackage = appBuild;
      });
}

