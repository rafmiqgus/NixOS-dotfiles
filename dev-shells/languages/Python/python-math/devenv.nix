{ pkgs, ... }:

{
  packages = with pkgs; [
    (pkgs.python313.withPackages (ps: with ps; [ watchdog pdftotext pypdf ]))
  ];

  languages.python = {
    enable = true;
    uv.enable = true;
    venv.enable = true;
  };
}
