{
  description = "Philip Taron's configuration(s)";

  inputs = {
    empty.url = "path:./empty.nix";
    empty.flake = false;
    nixpkgs.url = "github:NixOS/nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Stub these out so that they don't do anything.
    agenix.inputs.darwin.follows = "empty";
    agenix.inputs.home-manager.follows = "empty";
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs:
    let
      hostname = "zebul";
      system = "x86_64-linux";
    in
    {
      overlays.default = final: prev: {
        # Enable building Evolution Data Server without Gnome Online Accounts (GOA)
        evolution-data-server = prev.evolution-data-server.overrideAttrs (prevAttrs: {
          buildInputs = builtins.filter (e: e != prev.gnome-online-accounts) prevAttrs.buildInputs;
          cmakeFlags = ["-DENABLE_GOA=OFF"] ++ prevAttrs.cmakeFlags;
        });

        gnome = prev.gnome.overrideScope' (gnome-final: gnome-prev: {
          # Enable building Gnome Control Center without Gnome Online Accounts (GOA)
          gnome-control-center = gnome-prev.gnome-control-center.overrideAttrs (prevAttrs: {
            buildInputs = builtins.filter (e: e != prev.gnome-online-accounts) prevAttrs.buildInputs;
            patches = prevAttrs.patches ++ [./remove-online-accounts-from-gnome-control-center.patch];
          });
        });
      };
      formatter."${system}" = nixpkgs.legacyPackages."${system}".nixpkgs-fmt;
      nixosModules = {
        programs.agenix = agenix.nixosModules.default;
        traits.overlay = { nixpkgs.overlays = [ self.overlays.default ]; };
      };
      nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = with self.nixosModules; [
          { networking.hostName = hostname; }
          { nixpkgs.hostPlatform = system; }
          { nixpkgs.config.allowUnfree = true; }
          { system.stateVersion = "23.05"; }
          ./boot.nix
          ./containers.nix
          ./gui.nix
          ./hardware.nix
          ./nix.nix
          ./programs.nix
          ./sound.nix
          programs.agenix
          traits.overlay
        ];
      };
    };
}
