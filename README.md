# Build an AI agent workshop, step by step

We build a small AI agent around a local model (llama3.2, running with [Ollama](https://ollama.com)), adding one capability at a time: memory, tools, files, web search, MCP, skills. 

You talk to the agent in a web page. The code is written live by [OpenCode](https://opencode.ai), an opensource coding agent.

You can use your local environment if you are confortable with the terminal or work on github Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/SkatAI/build_agent)

## Before the workshop

- **Codespaces**: create a free account on [github.com](https://github.com/signup). Nothing else to install: everything runs in your browser.
- **Your computer**: follow [Run on your computer](#run-on-your-computer) below.

## Start (Codespaces)

1. Click **Open in GitHub Codespaces** above, then **Create codespace**. Wait until the code editor appears.
2. The agent's web page opens in a panel ("My agent: nothing here yet"). If it doesn't, open the **PORTS** tab at the bottom, find port 8501 ("Agent") and click the globe icon.
3. API keys: if your instructor added you to the repository, they are already set, skip to step 4. Otherwise, drag the `.env` file your instructor gave you into the file list on the left (next to `app.py`), then type in the terminal at the bottom:
   ```
   bash .devcontainer/start-app.sh
   ```
   and open a new terminal (**+** in the terminal panel), so the keys are loaded there too.
4. Start OpenCode: type `opencode` in the terminal. The provider (OpenRouter) and the model are already set in `opencode.json`.

## Run on your computer

For macOS or Linux, in a terminal (or your editor's terminal panel, for example in Zed). You need git, and about 3 GB of free disk space.

1. Install the tools, skipping those you already have:
   - Ollama: download and start the app from [ollama.com/download](https://ollama.com/download)
   - uv (Python manager, it installs Python by itself): `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - OpenCode: `curl -fsSL https://opencode.ai/install | bash`

   Then open a new terminal so the new commands are found.
2. Get the code, the model and the Python packages:
   ```
   git clone https://github.com/SkatAI/build_agent.git
   cd build_agent
   ollama pull llama3.2
   uv sync
   ```
3. Put the `.env` file your instructor gave you in the `build_agent` folder (or copy `.env.template` to `.env` and fill in the keys). Then start the agent's web page:
   ```
   bash .devcontainer/start-app.sh
   ```
   Open [http://localhost:8501](http://localhost:8501) in your browser ("My agent: nothing here yet").
4. Load the keys in your terminal, then start OpenCode:
   ```
   source .devcontainer/load-env.sh
   opencode
   ```
   To read the code while you work, open the folder in your editor (`zed .` for Zed).

The page keeps running in the background. To stop it: `kill $(cat /tmp/streamlit.pid)`. To restart it (for example after changing `.env`): `bash .devcontainer/start-app.sh`. Its log is in `/tmp/streamlit.log`.

## Follow along

The prompts for each step are in [prompts.md](prompts.md). Paste a prompt into OpenCode. When it saves `app.py`, the web page updates by itself: talk to your agent there.

| Step | Adds | What it shows |
|---|---|---|
| 1 | Chat page | The model remembers nothing |
| 2 | Conversation history | "Memory" in a chat is the history being resent |
| 3 | System prompt (`system.md`) | The harness sets the model's behaviour |
| 4 | `memory.md` | Memory across sessions is a file |
| 5 | First tool (date) | The agent loop: the model asks, the harness acts |
| 6 | File tools (`docs/`) | Access limits and permission to write |
| 7 | Web search (Tavily) | Current information and sources |
| 8 | `remember` tool | The model decides what to remember |
| 9 | MCP server (fetch) | Ready-made tools over a standard protocol |
| 10 | Skills (`skills/`) | Instructions loaded only when needed |
| 11 | Model choice | Same harness, different model |

Grey `[harness]` lines and "Tool result" boxes show what the program around the model does. The sidebar shows what is sent to the model.

## Lost? Jump to any step

Every step has a working version. To load it (this replaces your files), type in a terminal:

```
git checkout -f step-5
```

The web page updates by itself. Go back to the start with `git checkout -f main`.

## After the workshop

On Codespaces, stop your codespace to save your free hours: [github.com/codespaces](https://github.com/codespaces) → `...` → **Stop codespace**.

## Troubleshooting

- The web page is blank or says "connection refused": run `bash .devcontainer/start-app.sh`.
- OpenCode says "Missing Authentication header", or web search says the key is not set: the keys are missing. Check that `.env` is next to `app.py`, then run `bash .devcontainer/start-app.sh` and open a new terminal.
- The page shows an error about Ollama: run `bash .devcontainer/start-ollama.sh`.
- The answer is slow: the model runs on a CPU, without a GPU. Wait a few seconds.
- The agent invents an answer instead of using a tool: llama3.2 is a small model. In step 11, run `ollama pull qwen2.5:3b` and pick it in the sidebar.

## For the instructor: giving participants the API keys

Two options:

- **No action for participants**: make the repository private, invite each participant as a collaborator (Settings → Collaborators; they need a GitHub account and must accept the invitation), and add `OPENROUTER_API_KEY` and `TAVILY_API_KEY` under Settings → Secrets and variables → **Codespaces** → New repository secret. GitHub gives these secrets only to people with write access, which collaborators have. Collaborators can also push to the repository.
- **Share a `.env` file**: copy `.env.template` to `.env`, fill in the keys and send the file. Participants drop it into their codespace or project folder (see above). `.env` is ignored by git, so it is never published.

Codespaces usage on a repository owned by a personal account is billed to each participant's own free quota, whether the repository is public or private.
