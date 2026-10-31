#!/usr/bin/env bash
# Start the agent's web page (Streamlit, port 8501) in the background, if it is not already running.
# It reloads by itself whenever app.py changes. Works in Codespaces, on macOS and on Linux.
export PATH="$HOME/.local/bin:$PATH"
[ -f ~/.agent-keys ] && source ~/.agent-keys
cd "$(dirname "$0")/.."
if ! curl -s http://localhost:8501/_stcore/health > /dev/null; then
  [ -d .venv ] || uv sync -q
  # setsid keeps the page running after the terminal closes (Linux); macOS does not need it.
  if command -v setsid > /dev/null; then LAUNCH="setsid nohup"; else LAUNCH="nohup"; fi
  $LAUNCH .venv/bin/streamlit run app.py > /tmp/streamlit.log 2>&1 < /dev/null &
  echo $! > /tmp/streamlit.pid
fi
for _ in $(seq 1 60); do
  curl -s http://localhost:8501/_stcore/health > /dev/null && echo "Agent page running: http://localhost:8501" && exit 0
  sleep 1
done
echo "The agent page did not start; see /tmp/streamlit.log" && exit 1
