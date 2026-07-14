{ pkgs, ... }:

{
  packages = with pkgs; [
    llvmPackages_20.clang
    llvmPackages_20.clang-tools
    glibc.dev
    glibc.static
    bear
    pkg-config
    gdb
    criterion
    llvmPackages_20.libllvm
    llvmPackages_20.llvm
    llvmPackages.stdenv
    lldb
    vscode-extensions.vadimcn.vscode-lldb
    libxcrypt
    valgrind
    gcovr
    clang-analyzer
    upx
    (pkgs.python313.withPackages (ps: with ps; [ watchdog pdftotext pypdf python-docx ]))
  ];

  languages.c.enable = true;

  scripts.sanity_check.exec = ''
    ${pkgs.clang-analyzer}/bin/scan-build --status-bugs -disable-checker unix.Malloc make re
  '';
}
