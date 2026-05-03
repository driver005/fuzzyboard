# FuzzyBoard Canvas — Agent Reference

This document describes the intended behaviour of the workflow canvas
(`lib/features/workflows/workflow_canvas.dart`).  It is the authoritative
reference for any AI agent or developer working on the canvas.

---

## Overview

The workflow canvas is a full-screen, infinite visual editor for building
automation workflows out of connected nodes.  It is opened from the Workflows
page via the **Edit Canvas** button or when creating a new workflow.

---

## Canvas coordinate system

- The canvas lives inside an `InteractiveViewer` with
  `boundaryMargin: EdgeInsets.all(double.infinity)` and
  `clipBehavior: Clip.none`.  There are **no hard edges** — the user can pan
  to any canvas coordinate without restriction.
- The inner `SizedBox` is `100 000 × 100 000` logical pixels.  This is a
  reference size required by `InteractiveViewer`; it does not limit where
  nodes can be placed.
- The background grid is rendered **outside** the `InteractiveViewer` as a
  screen-space `CustomPaint` (`_InfiniteGridPainter`).  An `AnimatedBuilder`
  on the `TransformationController` keeps grid lines aligned with the current
  pan/zoom, giving the appearance of a truly infinite grid.
- `TransformationController.toScene(screenOffset)` converts any screen
  position to canvas coordinates.

---

## Nodes

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | UUID v4, immutable |
| `label` | `String` | Editable in the config panel |
| `type` | `NodeType` | `trigger / action / condition / delay / script / end` |
| `position` | `Offset` | Canvas coordinates (top-left of the 160 px wide node widget) |
| `config` | `Map<String, dynamic>` | Arbitrary key/value bag for node-specific settings |

### Adding nodes

Three entry points all ultimately call `add_node_and_maybe_connect(NodeType)`:

1. **Add Node toolbar button** — opens the Quick Menu centred on the viewport.
2. **Ctrl+Space / ⌘+Space** — opens the Quick Menu centred on the viewport.
3. **Left-click on empty canvas in connect mode** — opens the Quick Menu
   anchored to the click position; the new node is automatically connected
   from the current source node.

New nodes are placed at `pendingNodePosition` (canvas coordinates), which is
set before `showQuickMenu` is called.

### Dragging nodes

`GestureDetector.onPanUpdate` on each `_NodeWidget` calls
`onDrag(delta)` → `node.position += delta`.  Every drag step triggers a
`setState` so connections repaint in real time.

### Deleting nodes

`deleteNode(String id)` removes the node **and all connections** that
reference it.

---

## Connections

A `WorkflowConnection` links two nodes:

| Field | Notes |
|---|---|
| `fromNodeId` | Source node |
| `toNodeId` | Target node |
| `type` | `always / success / failure` — controls arrow colour |
| `label` | Optional label drawn on the connection chip |

### Connecting nodes

1. Click the 🔗 icon on a node → `startConnect(id)`.  `connecting = true`,
   `connectFromId = id`.  All other nodes highlight as potential targets.
2. Click a target node → `onNodeTap(id)` detects `connecting` and creates a
   `WorkflowConnection`.
3. **Smart connect on empty canvas**: while in connect mode, a `Listener`
   wrapping the `InteractiveViewer` fires on pointer-up.  If the pointer
   moved < 10 px (tap, not pan) and no node occupies the tap position, the
   Quick Menu opens.  Selecting a node type calls
   `add_node_and_maybe_connect(type)` which adds the node **and** auto-wires the
   connection in one step.
4. Press **ESC** or the × chip in the toolbar → `cancelConnect()`.

---

## Quick Menu (`_QuickMenuOverlay`)

A floating `Material` card shown via `showGeneralDialog`.

- **Auto-focused** search field filters node types by name and description.
- Keyboard: type to search, Enter / click to select.
- Barrier is transparent so the canvas remains visible behind the menu.
- Anchored near the click position when triggered from the canvas; centred on
  the viewport when triggered from the toolbar or keyboard shortcut.

---

## Undo / Redo

- Up to **30** undo steps stored in `undoStack` (LIFO).
- `pushUndo()` captures a full snapshot of nodes + connections before any
  mutating operation.
- `undo()` / `redo()` call `applySnapshot()` which replaces the node and
  connection lists in-place.
- The toolbar Undo / Redo buttons are disabled when the respective stack is
  empty.

---

## Export / Import

- **Export** serialises the workflow to pretty-printed JSON and copies it to
  the clipboard.
- **Import** parses JSON from a dialog text field and replaces the current
  nodes / connections.

---

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| **ESC** | Cancel connect mode |
| **Ctrl+Space** / **⌘+Space** | Open Quick Menu at viewport centre |

---

## Adapter architecture

All persistent data (tasks, workflows, plugins, workers, chat) is abstracted
behind adapter interfaces defined in `lib/adapters/adapters.dart`.

In-memory example implementations live in
`example/adapters/in_memory_adapter.dart`.  These are seeded from
`lib/data/seed_data.dart` and are intended to be replaced by real back-end
adapters without touching `AppProvider`.

```
lib/
  adapters/
    adapters.dart          ← abstract interfaces (permanent)
  data/
    seed_data.dart         ← all demo / seed data (single source of truth)
example/
  adapters/
    in_memory_adapter.dart ← example implementations (will be replaced)
```
