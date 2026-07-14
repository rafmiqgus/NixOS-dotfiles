{ pkgs, ... }:

{
  packages = with pkgs; [
    nodejs_20
  ];

  languages.javascript = {
    enable = true;
    npm.enable = true;
  };

  languages.typescript.enable = true;

  env = {
    # Placeholder — real values go in .env.local, never here
    NODE_ENV = "development";
  };

  scripts = {
    dev.exec = "npm run dev";
    build.exec = "npm run build";
    setup.exec = ''
      echo "Installing dependencies..."
      npm install
      echo "Done. Copy .env.local.example to .env.local and fill in your keys."
    '';
  };

  enterShell = ''
    echo "🎓 BDE Portal dev environment"
    echo "Node $(node --version) | npm $(npm --version)"
    echo "Run 'setup' to install deps, 'dev' to start."
  '';
}
