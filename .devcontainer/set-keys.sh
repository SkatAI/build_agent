#!/usr/bin/env bash
# Saves the API keys given by the teacher, then restarts the agent's web page so it can use them.
# Run with:  source .devcontainer/set-keys.sh
read -rsp "Paste the OpenRouter key, then press Enter: " OPENROUTER_API_KEY; echo
read -rsp "Paste the Tavily key, then press Enter: " TAVILY_API_KEY; echo
export OPENROUTER_API_KEY TAVILY_API_KEY

# The keys live in ~/.agent-keys, loaded by every new terminal and by the web page.
printf "export OPENROUTER_API_KEY='%s'\nexport TAVILY_API_KEY='%s'\n" "$OPENROUTER_API_KEY" "$TAVILY_API_KEY" > ~/.agent-keys
grep -q "agent-keys" ~/.bashrc || echo '[ -f ~/.agent-keys ] && source ~/.agent-keys' >> ~/.bashrc
echo "Saved: OpenRouter key ending in ...${OPENROUTER_API_KEY: -4}, Tavily key ending in ...${TAVILY_API_KEY: -4}"

# Restart the web page so it picks up the keys.
[ -f /tmp/streamlit.pid ] && kill -- -"$(cat /tmp/streamlit.pid)" 2>/dev/null && sleep 2
bash "$(dirname "${BASH_SOURCE[0]}")/start-app.sh"
