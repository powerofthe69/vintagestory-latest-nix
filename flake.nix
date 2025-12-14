{
  description = "Auto-updating Vintage Story Flake (Stable/Unstable/Latest)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:

    let
      system = "x86_64-linux";
      # Point to the new location of sources.json
      sources = builtins.fromJSON (builtins.readFile ./sources.json);
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # --- OVERLAYS ---
      overlays.default = final: prev: {
        vintagestory-stable = final.callPackage ./pkgs/default.nix {
          sourceData = sources.stable;
          channel = "stable";
        };
        vintagestory-unstable = final.callPackage ./pkgs/default.nix {
          sourceData = sources.unstable;
          channel = "unstable";
        };
        vintagestory = final.callPackage ./pkgs/default.nix {
          sourceData = sources.latest;
          channel = "latest";
        };
      };

      packages.${system} = {
        stable = pkgs.callPackage ./pkgs/default.nix {
          sourceData = sources.stable;
          channel = "stable";
        };
        unstable = pkgs.callPackage ./pkgs/default.nix {
          sourceData = sources.unstable;
          channel = "unstable";
        };
        default = pkgs.callPackage ./pkgs/default.nix {
          sourceData = sources.latest;
          channel = "latest";
        };
      };

      apps.${system}.update = {
        type = "app";
        program =
          (pkgs.writeShellScriptBin "update-vs" (builtins.readFile ./pkgs/update.sh)).outPath
          + "/bin/update-vs";
      };
    };
}
