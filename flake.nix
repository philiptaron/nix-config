{
  description = "Philip Taron's configuration(s)";
  nixConfig.commit-lockfile-summary = "flake.nix: update the lockfile";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    # Empty flake for making complex flake dependencies stop dead.
    empty.url = "path:./empty.nix";
    empty.flake = false;

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "empty";

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    fh.inputs.nixpkgs.follows = "nixpkgs";

    llama-cpp.url = "github:ggerganov/llama.cpp";
    llama-cpp.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nurl.url = "github:nix-community/nurl";
    nurl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      overlays = {
        default = import ./overlays.nix;
        agenix = inputs.agenix.overlays.default;
        fh = inputs.fh.overlays.default;
        nurl = inputs.nurl.overlays.default;
        llama-cpp = inputs.llama-cpp.overlays.default;
      };

      mkConfig = system: {
        inherit system;

        overlays = builtins.attrValues overlays;

        config.allowUnfree = true;
        config.hostPlatform = system;
        config.cudaSupport = true;
        config.nvidia.acceptLicense = true;
      };

      x86_64-linux = import nixpkgs (mkConfig "x86_64-linux");
      aarch64-darwin = import nixpkgs (mkConfig "aarch64-darwin");
      aarch64-linux = import nixpkgs (mkConfig "aarch64-linux");
      nixpkgsConnection = {
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
      };
    in
    {
      inherit overlays;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      darwinConfigurations.vesper = nix-darwin.lib.darwinSystem {
        pkgs = aarch64-darwin;
        modules = [
          { networking.hostName = "vesper"; }
          nixpkgsConnection
        ];
      };

      nixosConfigurations.zebul = nixpkgs.lib.nixosSystem {
        pkgs = x86_64-linux;
        inherit (x86_64-linux) system;
        modules = [
          { networking.hostName = "zebul"; }
          { system.stateVersion = "23.05"; }
          nixpkgsConnection
          ./boot.nix
          ./containers.nix
          ./git.nix
          ./gui.nix
          ./hardware.nix
          ./kernel/default.nix
          ./network.nix
          ./nix.nix
          ./programs.nix
          ./sound.nix
        ];
      };
    };
}
