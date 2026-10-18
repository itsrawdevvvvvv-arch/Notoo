#!/usr/bin/env node
/**
 * Notoo MCP connector
 * -------------------
 * Gives an AI assistant (Claude, ChatGPT, Cursor, …) full access to the Notoo
 * notes & canvas app: notes, tags, boards, and every element type on a board
 * (text, sticky, shapes, images, stickers, pen strokes, connections).
 *
 * The store is a single JSON document shared with the app:
 *
 *   local file  ->  NOTOO_FILE=/path/to/notoo.json
 *   GitHub      ->  NOTOO_GITHUB_REPO=owner/repo  NOTOO_GITHUB_TOKEN=ghp_...
 *                   (optional) NOTOO_GITHUB_PATH=notoo.json  NOTOO_GITHUB_BRANCH=main
 *
 * Run with no backend configured and it falls back to ./notoo.json.
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from "node:fs/promises";
import path from "node:path";

/* ------------------------------------------------------------------ store */

const GH_REPO   = process.env.NOTOO_GITHUB_REPO || "";
const GH_TOKEN  = process.env.NOTOO_GITHUB_TOKEN || "";
const GH_PATH   = process.env.NOTOO_GITHUB_PATH || "notoo.json";
const GH_BRANCH = process.env.NOTOO_GITHUB_BRANCH || "main";
const FILE      = process.env.NOTOO_FILE || path.resolve(process.cwd(), "notoo.json");

const useGithub = Boolean(GH_REPO && GH_TOKEN);
let ghSha = null;                      // current blob sha, needed to update

const EMPTY = () => ({ app: "notoo", version: 1, updated: new Date().toISOString(), notes: [] });

async function readStore() {
  if (useGithub) {
    const url = `https://api.github.com/repos/${GH_REPO}/contents/${encodeURIComponent(GH_PATH)}?ref=${GH_BRANCH}`;
    const r = await fetch(url, { headers: ghHeaders() });
    if (r.status === 404) { ghSha = null; return EMPTY(); }
    if (!r.ok) throw new Error(`GitHub read failed: ${r.status} ${await r.text()}`);
    const j = await r.json();
    ghSha = j.sha;
    return JSON.parse(Buffer.from(j.content, "base64").toString("utf8"));
  }
  try { return JSON.parse(await fs.readFile(FILE, "utf8")); }
  catch { return EMPTY(); }
}

async function writeStore(doc) {
  doc.app = "notoo";
  doc.version = doc.version || 1;
  doc.updated = new Date().toISOString();
  const body = JSON.stringify(doc, null, 2);
  if (useGithub) {
    if (ghSha === null) await readStore();          // discover the sha if we don't have it
    const url = `https://api.github.com/repos/${GH_REPO}/contents/${encodeURIComponent(GH_PATH)}`;
    const payload = {
      message: `notoo: update ${new Date().toISOString()}`,
      content: Buffer.from(body, "utf8").toString("base64"),
      branch: GH_BRANCH,
    };
    if (ghSha) payload.sha = ghSha;
    const r = await fetch(url, { method: "PUT", headers: ghHeaders(), body: JSON.stringify(payload) });
    if (!r.ok) throw new Error(`GitHub write failed: ${r.status} ${await r.text()}`);
    const j = await r.json();
    ghSha = j.content && j.content.sha;
    return;
  }
  await fs.mkdir(path.dirname(FILE), { recursive: true });
  await fs.writeFile(FILE, body, "utf8");
}

function ghHeaders() {
  return {
    Authorization: `Bearer ${GH_TOKEN}`,
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "notoo-mcp",
  };
}

/* ------------------------------------------------------------- note model */

const uid = () => Math.random().toString(36).slice(2, 10) + Date.now().toString(36).slice(-4);
const nowISO = () => new Date().toISOString();

const CANVAS_TEXTURES = ["none", "dots", "grid", "ruled", "graph", "iso", "polka"];
const SHAPES = ["rect", "rrect", "ellipse", "triangle", "diamond", "star", "arrow", "pentagon", "hexagon"];
const STICKY_COLOURS = ["#F7E9B8", "#F8DFCB", "#DDE8D2", "#D3E3EF", "#F4D3DA", "#E0D6EE"];

function newNote(over = {}) {
  return {
    id: uid(), type: "note", title: "", html: "", color: "default", tag: "", due: "",
    font: "Fredoka", pinned: false, fav: false, trashed: false,
    created: nowISO(), updated: nowISO(), ...over,
  };
}
function newBoard(over = {}) {
  return newNote({
    type: "canvas",
    canvas: { els: [], links: [], cam: { x: 0, y: 0, z: 1 }, bg: { color: "#3A2418", texture: "dots" } },
    ...over,
  });
}
function findBoard(doc, id) {
  return doc.notes.find((n) => n.id === id && n.type === "canvas");
}
function findNote(doc, id) {
  return doc.notes.find((n) => n.id === id);
}
function touch(n) { n.updated = nowISO(); }

/** Normalise whatever the caller passed into a canvas element. */
function element(type, o = {}) {
  const base = {
    id: o.id || uid(), type,
    x: num(o.x, 0), y: num(o.y, 0), w: num(o.w, 200), h: num(o.h, 140), rot: num(o.rot, 0),
  };
  if (type === "text") {
    return { ...base, text: String(o.text ?? ""), color: o.color || "#FFFFFF", fontSize: num(o.fontSize, 24), font: o.font || undefined, weight: o.weight || undefined };
  }
  if (type === "sticky") {
    return { ...base, text: String(o.text ?? ""), bg: o.bg || STICKY_COLOURS[0], color: o.color || "#3A2418", fontSize: num(o.fontSize, 16) };
  }
  if (type === "image") {
    return { ...base, src: o.src, bw: num(o.bw, base.w), bh: num(o.bh, base.h) };
  }
  if (type === "path") {
    return { ...base, points: o.points || [[0, 0], [base.w, base.h]], stroke: o.stroke || "#FFFFFF", strokeWidth: num(o.strokeWidth, 4), bw: base.w, bh: base.h };
  }
  // shapes
  return { ...base, stroke: o.stroke || "#FFFFFF", strokeWidth: num(o.strokeWidth, 4), bg: o.bg || "transparent" };
}
const num = (v, d) => (typeof v === "number" && isFinite(v) ? v : (v === undefined || v === null || v === "" ? d : Number(v) || d));

/** Fetch an image and return a data URL the app can render. */
async function toDataUrl(src) {
  if (!src) throw new Error("image src is required");
  if (src.startsWith("data:")) return src;
  if (src.trim().startsWith("<svg")) {
    return "data:image/svg+xml;charset=utf-8," + encodeURIComponent(src);
  }
  const r = await fetch(src, { headers: { "User-Agent": "notoo-mcp" } });
  if (!r.ok) throw new Error(`could not fetch image (${r.status}): ${src}`);
  const type = (r.headers.get("content-type") || "image/jpeg").split(";")[0];
  const buf = Buffer.from(await r.arrayBuffer());
  if (buf.length > 6 * 1024 * 1024) throw new Error(`image too large (${(buf.length / 1048576).toFixed(1)} MB): ${src}`);
  return `data:${type};base64,${buf.toString("base64")}`;
}

/* ---------------------------------------------------------------- server */

const server = new McpServer({ name: "notoo", version: "1.0.0" });
const ok = (text) => ({ content: [{ type: "text", text }] });
const okj = (obj) => ({ content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] });

server.tool(
  "notoo_status",
  "Check the Notoo connection: which store is in use and how many notes and boards exist.",
  {},
  async () => {
    const doc = await readStore();
    const notes = doc.notes.filter((n) => n.type !== "canvas");
    const boards = doc.notes.filter((n) => n.type === "canvas");
    return okj({
      connected: true,
      store: useGithub ? `github:${GH_REPO}/${GH_PATH}@${GH_BRANCH}` : `file:${FILE}`,
      notes: notes.length, boards: boards.length,
      lastUpdated: doc.updated,
    });
  }
);

server.tool(
  "list_notes",
  "List every note (not boards). Returns id, title, tag, pinned, favourite and last-updated.",
  { include_trashed: z.boolean().optional().describe("include notes in the bin") },
  async ({ include_trashed }) => {
    const doc = await readStore();
    const list = doc.notes
      .filter((n) => n.type !== "canvas" && (include_trashed || !n.trashed))
      .sort((a, b) => String(b.updated).localeCompare(String(a.updated)))
      .map((n) => ({ id: n.id, title: n.title || "Untitled note", tag: n.tag || "", pinned: !!n.pinned, fav: !!n.fav, updated: n.updated, preview: strip(n.html).slice(0, 120) }));
    return okj(list);
  }
);

server.tool(
  "search_notes",
  "Full-text search across note titles and bodies.",
  { query: z.string().describe("text to look for") },
  async ({ query }) => {
    const q = String(query).toLowerCase();
    const doc = await readStore();
    const hits = doc.notes
      .filter((n) => ((n.title || "") + " " + strip(n.html)).toLowerCase().includes(q))
      .map((n) => ({ id: n.id, title: n.title || "Untitled note", type: n.type, snippet: excerpt(n, q) }));
    return okj(hits);
  }
);

server.tool(
  "get_note",
  "Read one note or board in full, including every canvas element and connection.",
  { id: z.string().describe("note id") },
  async ({ id }) => {
    const doc = await readStore();
    const n = findNote(doc, id);
    if (!n) return ok(`No note with id ${id}`);
    return okj(n);
  }
);

server.tool(
  "create_note",
  "Create a text note. HTML is supported (h1-h3, b, i, u, ul/ol, blockquote, checkboxes as <div data-check>).",
  {
    title: z.string().optional(),
    html: z.string().optional().describe("note body as HTML"),
    tag: z.string().optional(),
    colour: z.string().optional().describe("colour key: default, butter, blush, sage, sky, lilac"),
    font: z.string().optional(),
    pinned: z.boolean().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const n = newNote({ title: a.title || "", html: a.html || "", tag: a.tag || "", color: a.colour || "default", font: a.font || "Fredoka", pinned: !!a.pinned });
    doc.notes.unshift(n);
    await writeStore(doc);
    return okj({ created: n.id, title: n.title });
  }
);

server.tool(
  "update_note",
  "Change fields on an existing note. Only the fields you pass are touched.",
  {
    id: z.string(),
    title: z.string().optional(),
    html: z.string().optional(),
    tag: z.string().optional(),
    colour: z.string().optional(),
    font: z.string().optional(),
    pinned: z.boolean().optional(),
    fav: z.boolean().optional(),
    due: z.string().optional().describe("due date, YYYY-MM-DD"),
  },
  async (a) => {
    const doc = await readStore();
    const n = findNote(doc, a.id);
    if (!n) return ok(`No note with id ${a.id}`);
    if (a.title !== undefined) n.title = a.title;
    if (a.html !== undefined) n.html = a.html;
    if (a.tag !== undefined) n.tag = a.tag;
    if (a.colour !== undefined) n.color = a.colour;
    if (a.font !== undefined) n.font = a.font;
    if (a.pinned !== undefined) n.pinned = a.pinned;
    if (a.fav !== undefined) n.fav = a.fav;
    if (a.due !== undefined) n.due = a.due;
    touch(n);
    await writeStore(doc);
    return okj({ updated: n.id });
  }
);

server.tool(
  "delete_note",
  "Move a note or board to the bin (recoverable in the app).",
  { id: z.string() },
  async ({ id }) => {
    const doc = await readStore();
    const n = findNote(doc, id);
    if (!n) return ok(`No note with id ${id}`);
    n.trashed = true; touch(n);
    await writeStore(doc);
    return okj({ trashed: id });
  }
);

server.tool("list_boards", "List every canvas board with its element count.", {}, async () => {
  const doc = await readStore();
  const list = doc.notes.filter((n) => n.type === "canvas").map((n) => ({
    id: n.id, title: n.title || "Untitled canvas",
    elements: (n.canvas?.els || []).length, connections: (n.canvas?.links || []).length,
    background: n.canvas?.bg || null, updated: n.updated,
  }));
  return okj(list);
});

server.tool(
  "create_board",
  "Create an empty canvas board, ready to receive text, stickies, shapes and images.",
  {
    title: z.string().optional(),
    background: z.string().optional().describe("background colour, e.g. #3A2418 or #F6EEDA"),
    texture: z.enum(CANVAS_TEXTURES).optional().describe("background texture"),
    tag: z.string().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const b = newBoard({ title: a.title || "Untitled canvas", tag: a.tag || "" });
    if (a.background) b.canvas.bg.color = a.background;
    if (a.texture) b.canvas.bg.texture = a.texture;
    doc.notes.unshift(b);
    await writeStore(doc);
    return okj({ created: b.id, title: b.title, background: b.canvas.bg });
  }
);

server.tool(
  "get_board",
  "Read a board's elements and connections.",
  { id: z.string() },
  async ({ id }) => {
    const doc = await readStore();
    const b = findBoard(doc, id);
    if (!b) return ok(`No board with id ${id}`);
    return okj({ id: b.id, title: b.title, background: b.canvas.bg, elements: b.canvas.els, connections: b.canvas.links });
  }
);

server.tool(
  "add_element",
  "Add any element to a board. Prefer the specific helpers (add_text, add_sticky, add_shape, add_image) unless you need a pen stroke.",
  {
    board: z.string().describe("board id"),
    type: z.enum(["text", "sticky", "image", "path", ...SHAPES]).describe("element type"),
    x: z.number().optional(), y: z.number().optional(),
    w: z.number().optional(), h: z.number().optional(),
    text: z.string().optional(), src: z.string().optional(),
    colour: z.string().optional().describe("fill / text colour"),
    stroke: z.string().optional(), stroke_width: z.number().optional(),
    font_size: z.number().optional(), rot: z.number().optional(),
    points: z.array(z.array(z.number())).optional().describe("for type=path: [[x,y], …]"),
  },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = element(a.type, {
      x: a.x, y: a.y, w: a.w, h: a.h, text: a.text, src: a.src,
      bg: a.colour, color: a.colour, stroke: a.stroke, strokeWidth: a.stroke_width,
      fontSize: a.font_size, rot: a.rot, points: a.points,
    });
    b.canvas.els.push(el); touch(b);
    await writeStore(doc);
    return okj({ added: el.id, type: el.type, x: el.x, y: el.y, w: el.w, h: el.h });
  }
);

server.tool(
  "add_text",
  "Add a text label to a board.",
  {
    board: z.string(), text: z.string(),
    x: z.number().optional(), y: z.number().optional(),
    size: z.number().optional().describe("font size in px (default 24)"),
    colour: z.string().optional(), font: z.string().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const size = num(a.size, 24);
    const el = element("text", { x: num(a.x, 0), y: num(a.y, 0), w: Math.max(160, a.text.length * size * 0.62), h: Math.round(size * 1.5), text: a.text, color: a.colour || "#FFFFFF", fontSize: size, font: a.font });
    b.canvas.els.push(el); touch(b);
    await writeStore(doc);
    return okj({ added: el.id, w: el.w, h: el.h });
  }
);

server.tool(
  "add_sticky",
  "Add a sticky note to a board.",
  {
    board: z.string(), text: z.string(),
    x: z.number().optional(), y: z.number().optional(),
    w: z.number().optional(), h: z.number().optional(),
    colour: z.string().optional().describe("one of " + STICKY_COLOURS.join(", ")),
  },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = element("sticky", { x: num(a.x, 0), y: num(a.y, 0), w: num(a.w, 180), h: num(a.h, 170), text: a.text, bg: a.colour || STICKY_COLOURS[0] });
    b.canvas.els.push(el); touch(b);
    await writeStore(doc);
    return okj({ added: el.id });
  }
);

server.tool(
  "add_shape",
  "Add a shape to a board.",
  {
    board: z.string(),
    shape: z.enum(SHAPES),
    x: z.number().optional(), y: z.number().optional(),
    w: z.number().optional(), h: z.number().optional(),
    fill: z.string().optional(), stroke: z.string().optional(), stroke_width: z.number().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = element(a.shape, { x: a.x, y: a.y, w: num(a.w, 160), h: num(a.h, 160), bg: a.fill, stroke: a.stroke, strokeWidth: a.stroke_width });
    b.canvas.els.push(el); touch(b);
    await writeStore(doc);
    return okj({ added: el.id });
  }
);

server.tool(
  "add_image",
  "Put an image on a board. Pass a public image URL (it is downloaded and embedded) or raw SVG markup. Use this for photos, and for stickers when you supply SVG.",
  {
    board: z.string(),
    url: z.string().describe("image URL, a data: URL, or raw <svg> markup"),
    x: z.number().optional(), y: z.number().optional(),
    w: z.number().optional(), h: z.number().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const src = await toDataUrl(a.url);
    const el = element("image", { x: num(a.x, 0), y: num(a.y, 0), w: num(a.w, 260), h: num(a.h, 195), src });
    el.bw = el.w; el.bh = el.h;
    b.canvas.els.push(el); touch(b);
    await writeStore(doc);
    return okj({ added: el.id, bytes: src.length });
  }
);

server.tool(
  "move_element",
  "Move an element on a board.",
  { board: z.string(), element: z.string(), x: z.number(), y: z.number() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = b.canvas.els.find((e) => e.id === a.element);
    if (!el) return ok(`No element with id ${a.element}`);
    el.x = a.x; el.y = a.y; touch(b);
    await writeStore(doc);
    return okj({ moved: el.id, x: el.x, y: el.y });
  }
);

server.tool(
  "resize_element",
  "Resize an element. For images and pen strokes this scales the content, never crops it.",
  { board: z.string(), element: z.string(), w: z.number(), h: z.number() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = b.canvas.els.find((e) => e.id === a.element);
    if (!el) return ok(`No element with id ${a.element}`);
    if (el.type === "image") { const ar = (el.bw || el.w) / (el.bh || el.h || 1); a.h = Math.round(a.w / ar); }
    el.w = a.w; el.h = a.h; touch(b);
    await writeStore(doc);
    return okj({ resized: el.id, w: el.w, h: el.h });
  }
);

server.tool(
  "rotate_element",
  "Rotate an element (degrees).",
  { board: z.string(), element: z.string(), degrees: z.number() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const el = b.canvas.els.find((e) => e.id === a.element);
    if (!el) return ok(`No element with id ${a.element}`);
    el.rot = a.degrees; touch(b);
    await writeStore(doc);
    return okj({ rotated: el.id, rot: el.rot });
  }
);

server.tool(
  "delete_element",
  "Remove an element from a board (its connections go too).",
  { board: z.string(), element: z.string() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const before = b.canvas.els.length;
    b.canvas.els = b.canvas.els.filter((e) => e.id !== a.element);
    b.canvas.links = (b.canvas.links || []).filter((l) => l.from !== a.element && l.to !== a.element);
    touch(b);
    await writeStore(doc);
    return okj({ removed: before !== b.canvas.els.length });
  }
);

server.tool(
  "connect_elements",
  "Draw a node-style connection between two elements on a board.",
  { board: z.string(), from: z.string(), to: z.string(), colour: z.string().optional() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    const has = (id) => b.canvas.els.some((e) => e.id === id);
    if (!has(a.from) || !has(a.to)) return ok("both element ids must exist on this board");
    b.canvas.links = b.canvas.links || [];
    if (b.canvas.links.some((l) => (l.from === a.from && l.to === a.to) || (l.from === a.to && l.to === a.from))) {
      return ok("those two are already connected");
    }
    const link = { id: uid(), from: a.from, to: a.to };
    if (a.colour) link.color = a.colour;
    b.canvas.links.push(link); touch(b);
    await writeStore(doc);
    return okj({ connected: link.id });
  }
);

server.tool(
  "set_board_background",
  "Change a board's background colour and/or texture.",
  { board: z.string(), colour: z.string().optional(), texture: z.enum(CANVAS_TEXTURES).optional() },
  async (a) => {
    const doc = await readStore();
    const b = findBoard(doc, a.board);
    if (!b) return ok(`No board with id ${a.board}`);
    if (a.colour) b.canvas.bg.color = a.colour;
    if (a.texture) b.canvas.bg.texture = a.texture;
    touch(b);
    await writeStore(doc);
    return okj({ background: b.canvas.bg });
  }
);

server.tool(
  "list_tags",
  "List every tag in use and how many items carry it.",
  {},
  async () => {
    const doc = await readStore();
    const counts = {};
    doc.notes.forEach((n) => { if (n.tag) counts[n.tag] = (counts[n.tag] || 0) + 1; });
    return okj(counts);
  }
);

server.tool(
  "set_note_tag",
  "Set or clear a note's tag.",
  { id: z.string(), tag: z.string().describe("leave empty to clear") },
  async (a) => {
    const doc = await readStore();
    const n = findNote(doc, a.id);
    if (!n) return ok(`No note with id ${a.id}`);
    n.tag = a.tag || ""; touch(n);
    await writeStore(doc);
    return okj({ id: n.id, tag: n.tag });
  }
);

server.tool(
  "create_mood_board",
  "One-shot: build a complete mood board from a list of image URLs. Lays the images out in a tidy non-overlapping grid, adds a title, and optionally connects them. This is the tool to use when asked to 'make a mood board from these images'.",
  {
    title: z.string().optional(),
    images: z.array(z.string()).describe("public image URLs (or data: URLs)"),
    background: z.string().optional().describe("background colour, default #3A2418"),
    texture: z.enum(CANVAS_TEXTURES).optional(),
    columns: z.number().optional().describe("grid columns, default 3"),
    connect: z.boolean().optional().describe("link the images in sequence"),
    tag: z.string().optional(),
  },
  async (a) => {
    const doc = await readStore();
    const board = newBoard({ title: a.title || "Mood board", tag: a.tag || "" });
    board.canvas.bg.color = a.background || "#3A2418";
    board.canvas.bg.texture = a.texture || "dots";

    const cols = Math.max(1, Math.min(8, Math.round(a.columns || 3)));
    const CW = 260, CH = 195, GAP = 34;
    const ids = [];
    const failures = [];

    for (let i = 0; i < a.images.length; i++) {
      try {
        const src = await toDataUrl(a.images[i]);
        const col = i % cols, row = Math.floor(i / cols);
        const el = element("image", { x: col * (CW + GAP), y: row * (CH + GAP), w: CW, h: CH, src });
        el.bw = CW; el.bh = CH;
        board.canvas.els.push(el);
        ids.push(el.id);
      } catch (e) {
        failures.push({ url: a.images[i], error: String(e.message || e) });
      }
    }

    if (a.title) {
      board.canvas.els.push(element("text", {
        x: 0, y: -110, w: Math.max(220, a.title.length * 22), h: 54,
        text: a.title, color: "#F6EEDA", fontSize: 38,
      }));
    }
    if (a.connect) {
      for (let i = 1; i < ids.length; i++) {
        board.canvas.links.push({ id: uid(), from: ids[i - 1], to: ids[i] });
      }
    }

    doc.notes.unshift(board);
    await writeStore(doc);
    return okj({
      board: board.id, title: board.title,
      imagesAdded: ids.length, failed: failures,
      layout: `${cols} columns`,
    });
  }
);

/* ---------------------------------------------------------------- helpers */

function strip(html) {
  return String(html || "").replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}
function excerpt(n, q) {
  const t = strip(n.html);
  const i = t.toLowerCase().indexOf(q);
  return i < 0 ? t.slice(0, 120) : t.slice(Math.max(0, i - 40), i + 80);
}

/* ------------------------------------------------------------------- boot */

const transport = new StdioServerTransport();
await server.connect(transport);
console.error(`[notoo-mcp] ready — store: ${useGithub ? "github:" + GH_REPO : "file:" + FILE}`);
