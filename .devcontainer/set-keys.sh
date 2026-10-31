#!/usr/bin/env bash
# Saves the API keys given by the instructor, then (re)starts the agent's web page so it can use them.
# Run it from the project folder with:  source .devcontainer/set-keys.sh   (works in bash and zsh)
printf "Paste the OpenRouter key, then press Enter: "
stty -echo 2>/dev/null; read -r OPENROUTER_API_KEY; stty echo 2>/dev/null; echo
printf "Paste the Tavily key, then press Enter: "
stty -echo 2>/dev/null; read -r TAVILY_API_KEY; stty echo 2>/dev/null; echo
export OPENROUTER_API_KEY TAVILY_API_KEY

# The keys live in ~/.agent-keys, loaded by every new terminal (bash or zsh) and by the web page.
printf "export OPENROUTER_API_KEY='%s'\nexport TAVILY_API_KEY='%s'\n" "$OPENROUTER_API_KEY" "$TAVILY_API_KEY" > ~/.agent-keys
for rc in ~/.bashrc ~/.zshrc; do
  grep -qs "agent-keys" "$rc" || echo '[ -f ~/.agent-keys ] && source ~/.agent-keys' >> "$rc"
done
echo "Saved: OpenRouter key ending in ...$(printf %s "$OPENROUTER_API_KEY" | tail -c 4), Tavily key ending in ...$(printf %s "$TAVILY_API_KEY" | tail -c 4)"

# Restart the web page so it picks up the keys.
[ -f /tmp/streamlit.pid ] && kill "$(cat /tmp/streamlit.pid)" 2>/dev/null && sleep 2
bash .devcontainer/start-app.sh
