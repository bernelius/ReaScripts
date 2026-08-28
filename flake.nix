{
  description = "ReaScripts dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          ruby
          bundler
          cmake
          gnumake
          gcc
          git
          libgit2
          libxml2
          zlib
          openssl
          pkg-config
          pandoc
        ];

        shellHook = ''
          export GEM_HOME="$PWD/.gems"
          export PATH="$GEM_HOME/bin:$PATH"
        '';
      };
    };
}
