{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [

    # --- Discord Clients & Mods ---
    dissent                   # Native GTK Discord client (lightweight)
    arrpc                     # Open Discord RPC server for custom presence

    # --- Discord Utilities ---
    discordchatexporter-cli   # Export chat logs to HTML/JSON/CSV
    discord-sh                # Send messages via webhooks from CLI
    cliscord                  # CLI tool to send text/files to Discord

    # --- Bot Development (Node.js) ---
    nodejs                    # Node.js runtime
    bun                       # Fast JS runtime & bundler (discord.js works great)
    deno                      # Secure JS/TS runtime (Discordeno)
    typescript                # TypeScript compiler
    pnpm                      # Fast, disk-efficient package manager
    yarn                      # Alternative package manager

    # --- Bot Development (Python) ---
    (pkgs.python3.withPackages (ps: with ps; [
      discordpy         # Main Python Discord API wrapper
      nextcord          # discord.py fork with slash commands
      jishaku           # Debug/REPL cog for discord.py bots
      aiohttp           # Async HTTP (webhooks, API calls)
      python-dotenv     # Load .env files for bot tokens
      pillow            # Image generation/manipulation for bots
      pynacl            # Voice support for discord.py
      aiosqlite         # Async SQLite for bot databases
      asyncpg           # Async PostgreSQL driver
      motor             # Async MongoDB driver
      requests          # HTTP library
      pycryptodome      # Cryptographic primitives
    ]))

    # --- Databases ---
    sqlite                    # Lightweight DB (perfect for small bots)
    redis                     # In-memory store (caching, queues, rate limits)

    # --- Media Processing ---
    ffmpeg                    # Audio/video processing (voice bots, media commands)
    yt-dlp                    # Download audio/video (music bots)
    imagemagick               # Image manipulation CLI (meme generators, overlays)
    sox                       # Audio effects & conversion
    gifsicle                  # GIF manipulation (resize, optimize, crop)
    optipng                   # PNG optimization

    # --- Networking & API ---
    curl                      # HTTP requests
    wget                      # File retrieval
    jq                        # JSON parsing (Discord API responses)
    websocat                  # WebSocket CLI client (debug gateway connections)
    ngrok                     # Expose local bot to internet (webhook testing)
    cloudflared               # Cloudflare tunnel (alt to ngrok)
    openssh                   # SSH for deploying bots
  ];
}
