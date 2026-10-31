# Project rules: build a local AI agent, step by step

Context
- Goal: build a local AI agent one feature at a time, for a workshop. 
- Participants have a humanities background and have never coded. They do not have experience in computer science.  

Code
- The agent is a Streamlit web page in one file, `app.py`. It is already running on port 8501 and reloads by itself when `app.py` is saved. 
- Never start, stop or restart Streamlit.
- Keep the code simple and short. Short functions, no classes.
- This is demo code no need for production complexity.
- All dependencies (ollama, streamlit, tavily-python, mcp) are already installed from `pyproject.toml`. Do not add others.

Models 
- The model runs locally through Ollama, using the `ollama` Python library. `MODEL = "llama3.2"` is set at the top of the file.
- Chat display: `st.chat_message` and `st.chat_input`. 
- From step 2, keep the conversation in `st.session_state.messages`, show it from there, and call `st.rerun()` after the agent replies.

- Harness
- Make the harness visible:
    - each tool call as a grey `st.caption` starting with `[harness]`;
    - each tool result in an `st.expander`;
    - in the sidebar: how many messages are sent to the model and their approximate size in tokens (characters / 4), the tools, the system prompt and the memory.
- Tools are plain Python functions with type hints and a docstring (the model reads the docstring). Tool errors are returned to the model as text, never raised.

- One plain-English comment per block, explaining what it does and why.
- Each step adds exactly one feature. Keep earlier features working. Do not refactor or add error handling beyond what the step needs.
- To check your work, run `uv run python -m py_compile app.py`. Do not open the page yourself.
- Reference solutions exist as git tags `step-1` ... `step-11`. Do not read them unless asked.
