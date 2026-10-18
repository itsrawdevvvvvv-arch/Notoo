# Notoo MCP connector

This lets an AI assistant — Claude, ChatGPT, Cursor, anything that speaks MCP —
read and build your Notoo notes and boards directly. Ask it to *"make a mood
board from these images"* and it creates the board, drops the pictures in a tidy
grid, adds a title and connects them, and the board shows up in the app.

## How it fits together

```
  Notoo app  ──┐
               ├──►  notoo.json  ◄──  this MCP server  ◄──  Claude / ChatGPT
  your phone   │     (one file)
```

Both the app and the server read and write the **same JSON document**. Whichever
one changes it, the other picks the change up. That document can live in two
places:

| Store | When to use it |
| --- | --- |
| **A private GitHub repo** | Recommended. Works from anywhere; the app syncs over the internet. |
| **A local file** | Simplest. Good for trying it out on one computer. |

## 1. Set up the store

### Option A — a private GitHub repo (recommended)

1. Create a **private** repo, e.g. `yourname/notoo-sync`. It can be empty.
2. Make a **fine-grained personal access token**: GitHub → Settings → Developer
   settings → Personal access tokens → Fine-grained tokens. Give it access to
   **only that repo**, with **Contents: Read and write**. Copy the token.
3. In the Notoo app: **Profile → AI Connector**. Paste the repo (`yourname/notoo-sync`)
   and the token, then tap **Test**, then **Send**. Your notes are now in the cloud.

### Option B — a local file

Skip the app step and just let the server create `notoo.json` where you run it.
The app can still push and pull to a GitHub repo later.

## 2. Install and run the server

```bash
cd mcp
npm install
```

## 3. Connect your assistant

### Claude Desktop

Open **Settings → Developer → Edit Config** and add:

```json
{
  "mcpServers": {
    "notoo": {
      "command": "node",
      "args": ["/full/path/to/Notoo/mcp/notoo-mcp.mjs"],
      "env": {
        "NOTOO_GITHUB_REPO": "yourname/notoo-sync",
        "NOTOO_GITHUB_TOKEN": "github_pat_…",
        "NOTOO_GITHUB_PATH": "notoo.json",
        "NOTOO_GITHUB_BRANCH": "main"
      }
    }
  }
}
```

The app's **Copy Claude Desktop config** button fills most of this in for you.
Restart Claude Desktop afterwards.

### ChatGPT

ChatGPT connectors only talk to a server with a **public web address**, so a
local process is not enough. You need to run the server somewhere reachable —
a small VM, a free container host, or a tunnel — and point ChatGPT at it. Claude
Desktop has no such restriction. This is a limitation of ChatGPT, not of Notoo.

### Local file instead of GitHub

Set `NOTOO_FILE` to the path of the JSON file and omit the GitHub variables:

```json
"env": { "NOTOO_FILE": "/Users/you/notoo.json" }
```

## Tools

| Tool | What it does |
| --- | --- |
| `notoo_status` | Which store is in use, how many notes and boards exist |
| `list_notes` / `search_notes` / `get_note` | Read your notes |
| `create_note` / `update_note` / `delete_note` | Write your notes |
| `list_boards` / `create_board` / `get_board` | Boards |
| `add_text` / `add_sticky` / `add_shape` / `add_image` / `add_element` | Put things on a board |
| `move_element` / `resize_element` / `rotate_element` / `delete_element` | Arrange them |
| `connect_elements` | Node-style links between items |
| `set_board_background` | Background colour and texture |
| `list_tags` / `set_note_tag` | Tags |
| `create_mood_board` | **Build a whole board from a list of image URLs in one step** |

Images can be given as public URLs — the server downloads and embeds them — or
as raw `<svg>` markup, which is handy for stickers and icons.

## Things worth trying

- *"Make a mood board called Summer from these image URLs …"*
- *"Search my notes for the phrase 'renewal' and summarise what I wrote."*
- *"Create a note titled 'Weekend plan' tagged personal."*
- *"On my Goals board, connect the 'Start' sticky to every other sticky."*

## Notes and limits

- The GitHub token lives in your app settings and in your assistant's config.
  Use a **fine-grained token scoped to the one repo**, and keep that repo private.
- Images are embedded in the JSON. Very large pictures are rejected (over 6 MB)
  rather than bloating your sync file.
- Only one writer at a time is safe. If two devices push at once you may get a
  conflict error; pull and push again.
