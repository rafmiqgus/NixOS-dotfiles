{ pkgs, inputs,... }:

pkgs.stdenv.mkDerivation rec {
  pname = "pam_faceid";
  version = "latest";

  src = "${inputs.ambxst-faceid-mod}/pam";

  buildInputs = [ pkgs.gnumake pkgs.pam ];

  buildPhase = ''
    make clean
    make
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp *.so $out/lib/
  '';
}
