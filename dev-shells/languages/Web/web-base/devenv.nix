{ pkgs, ... }:

{
  packages = with pkgs; [
    sql-formatter
    sqls
    sqlfluff
    mariadb.client
  ];

  languages.typescript.enable = true;

  languages.javascript = {
    enable = true;
    npm.enable = true;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  scripts.devenv_up.exec = ''
    devenv up --from path:/home/rafael/Epitech/.devenv-profiles/web
  '';
}
