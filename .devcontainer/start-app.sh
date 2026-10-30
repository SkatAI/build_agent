#!/usr/bin/env bash
# Start the agent's web page (Streamlit, port 8501) in the background.
# It reloads by itself whenever app.py changes.
export PATH="$HOME/.local/bin:$PATH"
[ -f ~/.agent-keys ] && source ~/.agent-keys
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if ! curl -s http://localhost:8501/_stcore/health > /dev/null; then
  setsid nohup uv run streamlit run app.py > /tmp/streamlit.log 2>&1 < /dev/null &
  echo $! > /tmp/streamlit.pid
fi
for _ in $(seq 1 60); do
  curl -s http://localhost:8501/_stcore/health > /dev/null && echo "Agent page running on port 8501" && exit 0
  sleep 1
done
echo "The agent page did not start; see /tmp/streamlit.log" && exit 1
