{
  description = "transcendental-syntax";

  inputs = {
    # Remark: when adding inputs here, don't forget to also add them in the
    # arguments to `outputs` below!
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  # Remark: keep the list of outputs in sync with the list of inputs above
  # (see above remark)
  outputs = { self, flake-utils, nixpkgs}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ocamlPackages = pkgs.ocamlPackages;
        easy_logging = ocamlPackages.buildDunePackage rec {
          pname = "easy_logging";
          version = "0.8.2";
          src = pkgs.fetchFromGitHub {
            owner = "sapristi";
            repo = "easy_logging";
            rev = "v${version}";
            sha256 = "sha256-Xy6Rfef7r2K8DTok7AYa/9m3ZEV07LlUeMQSRayLBco=";
          };
          buildInputs = [ ocamlPackages.calendar ];
        };

        transcendental-syntax = ocamlPackages.buildDunePackage {
          pname = "transcendental-syntax";
          version = "0.1.0";
          duneVersion = "3";
          src = ./.;
          OCAMLPARAM = "_,warn-error=+A"; # Turn all warnings into errors.
          propagatedBuildInputs = [
            easy_logging
          ] ++ (with ocamlPackages; [
	    calendar
	    alcotest
	    base
          ]);
        };
      in
      {
        packages = {
          inherit transcendental-syntax;
          default = transcendental-syntax;
        };
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.ocamlPackages.ocaml
            pkgs.ocamlPackages.ocamlformat
            pkgs.ocamlPackages.menhir
            pkgs.ocamlPackages.odoc
	          pkgs.ocamlPackages.ocaml-lsp
            pkgs.jq
          ];

          inputsFrom = [
            self.packages.${system}.transcendental-syntax
          ];
        };
      });
}
