curl -sS \
  -A "whats1ttoya/mc-modchecker/1.0" \
  --connect-timeout 10 \
  --max-time 30 \
  "https://api.modrinth.com/v2/project/$project/version?game_versions=%5B%22$MC_VERSION%22%5D&loaders=%5B%22$LOADER%22%5D"