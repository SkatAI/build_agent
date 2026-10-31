# Building a local agent: OpenCode prompts

One prompt per step, each adding one capability to `app.py`: a web page where you talk to an agent that runs on a small local model (qwen2.5:3b or llama3.2:3b) through Ollama. OpenCode (with a cloud model) writes the code; the agent itself runs locally, except web search in step 7.

## Setup

1. Open the codespace, or run it on your computer (see README). The agent's page runs on port 8804 and reloads by itself each time `app.py` is saved. OpenCode reads `AGENTS.md` automatically: it holds the rules for every step.
2. Paste one prompt per step into OpenCode, then talk to the agent in the web page.

Two small local models are available, picked in the sidebar: qwen2.5:3b (default) handles tools well enough for the demos; llama3.2:3b is chattier but often picks the wrong tool. Both make mistakes (an unneeded tool call, a wrong argument, an invented source), and these mistakes are worth showing. Switch models at any step to compare.

## Part 1: Memory

### Step 1: Stateless chat

The model is a function: text in, text out. It remembers nothing.

```markdown
Replace app.py with a chat page: a title, st.chat_input, and for each message, send ONLY that message to the model and show the question and the answer with st.chat_message. 
Stream the answer so it appears as it is written: ollama.chat with stream=True, displayed with st.write_stream. 
In the sidebar, add a selectbox to pick the model: "qwen2.5:3b" (default) or "llama3.2:3b". 
Keep no history.
```

**Demo**: "My name is Alexis." then "What is my name?". It doesn't know, and the previous exchange disappears from the page: Streamlit reruns the whole file for each message. Then switch the model in the sidebar and ask the same question: same code, a different answer.

### Step 2: Conversation history

In-session memory is the harness resending the whole conversation every turn.

```markdown
Keep the conversation history in `st.session_state.messages`: 
- add every user message and model reply, 
- end the full list on each turn, 
- and show the whole conversation on the page. 

Keep streaming the answer; save the full text returned by `st.write_stream` as the reply. 
In the sidebar, show how many messages are sent and their approximate size in tokens (total characters divided by 4).
```

**Demo**: the name question now works. Watch the size grow in the sidebar: that is the context window filling up. Reload the page: everything is gone.

### Step 3: System prompt

The harness decides who the model is before the user says anything.

```markdown
Read the system prompt from system.md on every run and put it first in the messages list (do not show it in the chat). 
Show it in the sidebar. 
```

system.md is already in the folder: the agent is Amandine, a farmer in Normandy, proud of her chickens and obsessed with the price of eggs.

Demo: ask a question, then add "Answer only in French." to system.md and send another message: no reload needed.

### Step 4: Persistent memory

Memory across sessions is a file the harness reads and writes, automatically.

```markdown
Remember the conversation automatically. 
After each reply, append the new exchange to memory.md as plain text, one line per message: "User: ..." then "Agent: ...". 
On every run, read memory.md and add it to the system prompt under "Previous conversations:". 
In the sidebar, show the size of memory.md in approximate tokens (characters divided by 4), next to the context size. 
Do not summarize anything.
```

Demo: "Hi, I'm Alexis, I work in consulting and I prefer short answers.", reload the page, "What do you know about me?". Open memory.md: plain text anyone can read or edit. Chat across a few reloads and watch the sidebar: every past exchange is resent with each message, so the context only grows.

## Part 2: Tools

### Step 5: First tool and the agent loop

The model can't act; it can only ask. The harness runs the function and sends back the result. This loop is what makes it an agent.

```markdown
Add tool calling. 
Write a Python function get_current_datetime() with the docstring "Get today's date and the current time. Use only when the user asks about the date or time." and pass it to ollama.chat as a tool. 
Implement the agent loop: if the reply contains tool calls, run each function, append the result as a "tool" message, and call the model again; repeat until the model replies with plain text. 
The agent loop does not stream: show a "Thinking..." spinner while it runs. 
If a tool fails, send the error back to the model as text. 
Store the model's messages with message.model_dump(exclude_none=True). 
In the chat, show each tool call as a grey [harness] caption and each tool result in an expander. 
List the tools in the sidebar.
Add to system.md: "You have tools, but most questions do not need them. If no tool clearly matches the question, answer directly from your own knowledge without calling any tool. When a tool returns a result, trust it and use it in your answer."
```

Demo: before this step, ask "What is today's date?" (it guesses or refuses). After, ask again and open the tool result. Then ask "Who wrote Les Misérables?": a small model sometimes calls the date tool anyway. The answer no longer streams: the harness must receive a tool call in full before it can run it.

### Step 6: Local files

Tools give the agent reach; the harness decides how far.

```markdown
Before calling a tool, drop any argument the function does not accept.
Add three file tools, all restricted to the docs/ folder (refuse any path outside it):
- list_files() lists the files in docs/
- read_file(name) returns a file's text; if the file does not exist, return "No file named ... Files available: ..."
- write_file(name, content) writes a file, but only if an "Allow file writes" toggle in the sidebar is on; otherwise return "Not saved: file writes are switched off. Ask the user to turn on 'Allow file writes' in the sidebar, then try again."
Show the files in docs/ in the sidebar.
```

`docs/` already holds two sample files that contradict each other.

Demo: "Which files do I have?" first (small models guess file names otherwise), then "Do the press release and the interview notes agree on the budget?", then "Save a two-line summary of the contradiction to summary.md" with the toggle off, then on.

### Step 7: Web search

The model's knowledge stops at its training date; search brings in current sources.

```markdown
Add a web_search(query) tool using the tavily-python library. 
Read the key from the TAVILY_API_KEY environment variable; if it is missing, return "Web search is unavailable: TAVILY_API_KEY is not set."
Call search with max_results=5 and include_answer=True. 
Return Tavily's answer first, then each result as title, published date, URL and the first 500 characters.
Add today's date to the system prompt.
Add to system.md: "When you use web search, base your answer only on the search results and cite their URLs. If the results do not answer the question, say so."
```

Demo: ask about something from this week, then open the tool result and compare it with the answer.

### Step 8: Memory as a tool

Instead of the harness saving every exchange, the model decides what is worth remembering, and when.

```markdown
Replace the automatic saving of the conversation with a remember(fact) tool.
The fact argument is one short sentence, written by the model in its own words, that summarizes a lasting fact about the user. Never the user's message copied as is. Say this in the tool's docstring, since the model reads it.
The tool appends that sentence as one line to memory.md, unless the same line is already there.
Keep loading memory.md on every run.
Add to system.md: "When the user shares a lasting fact about themselves (name, job, preferences, projects), call remember with a one-sentence summary of that fact. Do not save questions, greetings or the conversation itself."
```

Demo: delete memory.md first (it still holds the raw conversations from step 4). Then "Hi, I'm Alexis and I'm vegetarian." and watch the tool call. Reload, then "Suggest a dinner for me tonight." Discuss: what should an agent be allowed to remember, and who checks?

## Part 3: Standard extensions

### Step 9: MCP

Instead of writing each tool, plug in a server that offers ready-made ones over a standard protocol.

```markdown
Connect the agent to an MCP server with the official mcp Python SDK (version 2 or later: tool schemas are in tool.input_schema). The server is started with `uvx mcp-server-fetch` over stdio. Write one async function that starts the server and either lists its tools or calls one, and run it with asyncio.run. List the MCP tools once (st.cache_resource), convert them to Ollama tool definitions, and add them to the tools sent to the model. When the model calls an MCP tool, drop arguments whose value is None, then call it on the server. Show the MCP tools in the sidebar.
```

**Demo**: 
No fetch code was written in app.py: the same server works in Claude, OpenCode or Cursor.

```
Fetch the history section of that wikipedia page [https://en.wikipedia.org/wiki/Large_language_model](https://en.wikipedia.org/wiki/Large_language_model#History) and summarize it in a few sentences.
```


### Step 10: Skills

A skill is a written procedure the agent loads only when it needs it. The system prompt holds just the index.

```markdown
Add skills. 
Each skill is a folder in skills/ containing a SKILL.md that starts with a header between --- lines, giving a name and a one-line description. Add only the names and descriptions to the system prompt, and show them in the sidebar. 
Add a load_skill(name) tool that returns the full SKILL.md. 
Create skills/fact-check/SKILL.md: restate the claim, find two independent sources with web_search, give one line per source with its URL, then a verdict (TRUE, FALSE or UNVERIFIED). 
Never invent sources.
```

**Demo**: 

Watch load_skill. Small models may load the skill and then skip web_search, citing sources from memory: compare the URLs with the tool results. Then write a second skill live, in plain English, with no code.

```
Fact-check this claim: France is the most visited country in the world.
```


To close: switch to the other model and repeat a few earlier questions (the date, the files, the fact-check). Same harness, different model, different results. OpenCode, which wrote all of this, is the same kind of harness around a much larger model.
