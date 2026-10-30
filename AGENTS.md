# Project rules: build a local AI agent, step by step

- Goal: build a local AI agent one feature at a time, for a class of students who do not code. The teacher reads the code aloud.
- Everything lives in one file, `agent.py`. Short functions, no classes.
- The model runs locally through Ollama, using the `ollama` Python library. `MODEL = "llama3.2"` is set at the top of the file.
- Run with `uv run agent.py`. Dependencies are declared in an inline script header (PEP 723), so no virtual environment is needed.
- One plain-English comment per block, explaining what it does and why.
- Make the harness visible: print every memory load/save and every tool call (name, arguments, result) on its own line, prefixed with `[harness]`, in grey (`\033[90m ... \033[0m`).
- Tools are plain Python functions with type hints and a docstring (the model reads the docstring). Tool errors are returned to the model as text, never raised.
- Each step adds exactly one feature. Keep earlier features working. Do not refactor or add error handling beyond what the step needs.
- Do not run the interactive chat yourself. To check your work, run `uv run python -m py_compile agent.py`.
- Reference solutions exist as git tags `step-1` ... `step-11`. Do not read them unless asked.
