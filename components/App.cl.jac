"""Mind Island client UI — Person A owns this file.

Do not change walker names, arguments, or response keys.
Edit visuals, layout, copy, and IslandSvg freely.
"""

sv import from ..main {
    get_world,
    manifest_emotion,
    place_entity,
    apply_interaction,
    commit_value_action,
    reset_demo
}

import "./styles.css";

def ToolButton(tool_id: str, tool: dict, selected: bool, choose: any) -> JsxElement {
    return <button
        className={"tool-button " + ("selected" if selected else "")}
        onClick={lambda -> None { choose(tool_id); }}
    >
        <span className="tool-icon">{tool["icon"]}</span>
        <span>{tool["name"]}</span>
    </button>;
}

def IslandSvg() -> JsxElement {
    return <svg
        viewBox="0 0 800 520"
        xmlns="http://www.w3.org/2000/svg"
        className="island-svg"
        aria-hidden="true"
        preserveAspectRatio="xMidYMid slice"
    >
        <defs>
            <linearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#c8e8f5" />
                <stop offset="100%" stopColor="#dff0e8" />
            </linearGradient>
            <linearGradient id="seaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#7bbfcf" />
                <stop offset="100%" stopColor="#4a9ab5" />
            </linearGradient>
            <radialGradient id="islandGrad" cx="50%" cy="45%" r="55%">
                <stop offset="0%" stopColor="#d4e8a0" />
                <stop offset="60%" stopColor="#a8cc72" />
                <stop offset="100%" stopColor="#7aaa4a" />
            </radialGradient>
        </defs>
        <rect width="800" height="520" fill="url(#skyGrad)" />
        <circle cx="680" cy="72" r="38" fill="#f5d060" opacity="0.9" />
        <circle cx="680" cy="72" r="52" fill="#f5d060" opacity="0.18" />
        <ellipse cx="120" cy="80" rx="60" ry="28" fill="white" opacity="0.7" />
        <ellipse cx="160" cy="68" rx="45" ry="22" fill="white" opacity="0.7" />
        <ellipse cx="85" cy="75" rx="38" ry="20" fill="white" opacity="0.6" />
        <ellipse cx="520" cy="55" rx="50" ry="22" fill="white" opacity="0.55" />
        <ellipse cx="555" cy="44" rx="38" ry="18" fill="white" opacity="0.55" />
        <rect y="310" width="800" height="210" fill="url(#seaGrad)" />
        <path d="M0 320 Q100 310 200 320 Q300 330 400 320 Q500 310 600 320 Q700 330 800 320" fill="none" stroke="white" strokeWidth="2" opacity="0.35" />
        <path d="M0 345 Q100 335 200 345 Q300 355 400 345 Q500 335 600 345 Q700 355 800 345" fill="none" stroke="white" strokeWidth="1.5" opacity="0.25" />
        <ellipse cx="400" cy="310" rx="270" ry="115" fill="url(#islandGrad)" />
        <ellipse cx="370" cy="270" rx="130" ry="48" fill="white" opacity="0.12" />
        <ellipse cx="200" cy="340" rx="22" ry="10" fill="#8aaa55" opacity="0.6" />
        <ellipse cx="590" cy="335" rx="18" ry="8" fill="#8aaa55" opacity="0.5" />
        <circle cx="240" cy="295" r="5" fill="#f9c8d0" opacity="0.8" />
        <circle cx="255" cy="288" r="4" fill="#f9c8d0" opacity="0.7" />
        <circle cx="530" cy="300" r="5" fill="#f9e8a0" opacity="0.8" />
        <circle cx="518" cy="292" r="4" fill="#f9e8a0" opacity="0.7" />
    </svg>;
}

def:pub app() -> JsxElement {
    has feeling_text: str = "I feel anxious about presenting my project.";
    has entities: list = [];
    has selected_entity: str = "";
    has selected_tool: str = "breathe";
    has action_text: str = "Open my notes and say the first sentence.";
    has notice: str = "";
    has error: str = "";
    has loading: bool = True;
    has busy: bool = False;
    has dragging_id: str = "";

    async can with entry {
        try {
            result = root spawn get_world();
            if result.reports and len(result.reports) > 0 {
                initial_entities = result.reports[0]["entities"] as list;
                entities = initial_entities;
                placed = [e for e in initial_entities if e["placed"]];
                if len(placed) > 0 {
                    selected_entity = str(placed[len(placed) - 1]["id"]);
                }
            }
        } except Exception {
            error = "The island is waking up. Refresh if it does not appear in a moment.";
        }
        loading = False;
    }

    async def manifest() -> None {
        if not feeling_text.strip() or busy {
            return;
        }
        busy = True;
        error = "";
        notice = "";
        try {
            result = root spawn manifest_emotion(feeling_text=feeling_text.strip());
            response = result.reports[0];
            if response["ok"] {
                entities = response["world"] as list;
                suggested_tools = response["suggested_tools"] as list;
                if len(suggested_tools) > 0 {
                    selected_tool = str(suggested_tools[0]);
                }
                notice = "Three forms appeared in the tray. Drag the one that feels right onto your island.";
            } else {
                error = str(response["error"]);
            }
        } except Exception {
            error = "The island paused for a moment. Please try again.";
        }
        busy = False;
    }

    async def on_drop(e: any) -> None {
        e.preventDefault();
        eid = dragging_id;
        if not eid {
            return;
        }
        doc = document as any; # jac:ignore[W2001]
        canvas = doc.getElementById("island-canvas");
        rect = canvas.getBoundingClientRect();
        raw_x = ((e.clientX as float) - (rect.left as float)) / (rect.width as float);
        raw_y = ((e.clientY as float) - (rect.top as float)) / (rect.height as float);
        px = (0.08 if raw_x < 0.08 else (0.92 if raw_x > 0.92 else raw_x)) as float;
        py = (0.08 if raw_y < 0.08 else (0.92 if raw_y > 0.92 else raw_y)) as float;
        dragging_id = "";
        busy = True;
        error = "";
        result = root spawn place_entity(entity_id=eid, x=px, y=py);
        response = result.reports[0];
        if response["ok"] {
            entities = response["world"] as list;
            selected_entity = str(response["entity"]["id"]);
            notice = str(response["message"]);
        } else {
            error = str(response["error"]);
        }
        busy = False;
    }

    async def interact() -> None {
        if not selected_entity or busy {
            return;
        }
        busy = True;
        error = "";
        result = root spawn apply_interaction(
            entity_id=selected_entity,
            tool_id=selected_tool
        );
        response = result.reports[0];
        if response["ok"] {
            entities = response["world"] as list;
            notice = str(response["message"]);
        } else {
            error = str(response["error"]);
        }
        busy = False;
    }

    async def commit_action() -> None {
        if not selected_entity or busy {
            return;
        }
        busy = True;
        error = "";
        result = root spawn commit_value_action(
            entity_id=selected_entity,
            action_text=action_text
        );
        response = result.reports[0];
        if response["ok"] {
            entities = response["world"] as list;
            notice = str(response["message"]);
        } else {
            error = str(response["error"]);
        }
        busy = False;
    }

    async def reset_island() -> None {
        if busy {
            return;
        }
        busy = True;
        error = "";
        notice = "";
        result = root spawn reset_demo();
        if result.reports and result.reports[0]["ok"] {
            entities = [];
            selected_entity = "";
            notice = "Island cleared. Ready for a fresh check-in.";
        } else {
            error = "Could not reset the island.";
        }
        busy = False;
    }

    placed_entities = [e for e in entities if e["placed"]];
    tray_entities = [e for e in entities if not e["placed"]];

    return <main className="app-shell">
        <header className="hero">
            <div>
                <p className="eyebrow">A three-minute emotional reset</p>
                <h1>Mind Island</h1>
                <p className="subtitle">
                    Notice what is here. Give it shape. Carry it with you.
                </p>
            </div>
            <div className="hero-actions">
                <div className="privacy-pill">Anonymous session · not therapy</div>
                <button className="ghost" onClick={lambda -> None { reset_island(); }} disabled={busy}>
                    Reset demo
                </button>
            </div>
        </header>

        <section className="workspace">
            <aside className="panel check-in">
                <span className="step">01 · Externalize</span>
                <h2>What is showing up?</h2>
                <textarea
                    value={feeling_text}
                    onChange={lambda (e: any) { feeling_text = str(e.target.value); }}
                    maxLength={280}
                    aria-label="Describe what you are feeling"
                />
                <button className="primary" onClick={lambda -> None { manifest(); }} disabled={busy}>
                    {("Listening..." if busy else "Place it on my island")}
                </button>

                <span className="step second">02 · Choose</span>
                <h2>How would you like to meet it?</h2>
                <div className="tool-grid">
                    <ToolButton
                        tool_id="breathe"
                        tool={{"name": "Three slow breaths", "icon": "🫧"}}
                        selected={selected_tool == "breathe"}
                        choose={lambda (choice: str) { selected_tool = choice; }}
                    />
                    <ToolButton
                        tool_id="sunlight"
                        tool={{"name": "Offer warmth", "icon": "☀️"}}
                        selected={selected_tool == "sunlight"}
                        choose={lambda (choice: str) { selected_tool = choice; }}
                    />
                    <ToolButton
                        tool_id="water"
                        tool={{"name": "Make some room", "icon": "💧"}}
                        selected={selected_tool == "water"}
                        choose={lambda (choice: str) { selected_tool = choice; }}
                    />
                    <ToolButton
                        tool_id="name_it"
                        tool={{"name": "Name the story", "icon": "🏷️"}}
                        selected={selected_tool == "name_it"}
                        choose={lambda (choice: str) { selected_tool = choice; }}
                    />
                </div>
                <button className="secondary" onClick={lambda -> None { interact(); }} disabled={not selected_entity or busy}>
                    Try this interaction
                </button>
            </aside>

            <section className="island-panel">
                <div
                    id="island-canvas"
                    className={"island-canvas" + (" drag-active" if dragging_id else "")}
                    onDragOver={lambda (e: any) { e.preventDefault(); }}
                    onDrop={lambda (e: any) { on_drop(e); }}
                >
                    <IslandSvg />

                    {loading and <p className="canvas-hint">Growing your island...</p>}
                    {not loading and len(placed_entities) == 0 and len(tray_entities) == 0 and
                        <p className="canvas-hint">Your island has room for whatever arrives.</p>
                    }
                    {not loading and len(tray_entities) > 0 and len(placed_entities) == 0 and
                        <p className="canvas-hint drop-hint">Drag a form from the tray below onto your island</p>
                    }

                    {[
                        <button
                            key={entity["id"]}
                            className={"placed-entity " + ("active" if selected_entity == entity["id"] else "")}
                            style={{"left": str((entity["x"] as float) * 100.0) + "%", "top": str((entity["y"] as float) * 100.0) + "%"}}
                            onClick={lambda -> None { selected_entity = str(entity["id"]); }}
                            aria-label={entity["label"]}
                        >
                            <span className="entity-symbol">{entity["symbol"]}</span>
                            <span className="entity-label">{entity["label"]}</span>
                            <small>{entity["process_stage"]}</small>
                        </button>
                        for entity in placed_entities
                    ]}
                </div>

                {notice and <div className="notice">{notice}</div>}
                {error and <div className="error" role="alert">{error}</div>}

                {len(tray_entities) > 0 and
                    <div className="entity-tray">
                        <p className="tray-label">Choose a form - drag it onto your island</p>
                        <div className="tray-row">
                            {[
                                <div
                                    key={entity["id"]}
                                    className={"tray-entity" + (" dragging" if dragging_id == entity["id"] else "")}
                                    draggable={True}
                                    onDragStart={lambda (e: any) { dragging_id = str(entity["id"]); }}
                                    onDragEnd={lambda (e: any) { dragging_id = ""; }}
                                    aria-label={entity["label"]}
                                >
                                    <span className="tray-symbol">{entity["symbol"]}</span>
                                    <span className="tray-name">{entity["label"]}</span>
                                </div>
                                for entity in tray_entities
                            ]}
                        </div>
                    </div>
                }
            </section>

            <aside className="panel action-panel">
                <span className="step">03 · Move with it</span>
                <h2>One tiny values-guided step</h2>
                <p>
                    You do not have to wait to feel fearless. What can you do while
                    this feeling comes along?
                </p>
                <input
                    value={action_text}
                    onChange={lambda (e: any) { action_text = str(e.target.value); }}
                    aria-label="One small next action"
                />
                <button className="primary" onClick={lambda -> None { commit_action(); }} disabled={not selected_entity or busy}>
                    Plant this intention
                </button>
                <div className="act-note">
                    <strong>Why this works</strong>
                    <span>Externalize - allow - choose - act</span>
                    <small>Inspired by ACT and expressive arts practices.</small>
                </div>
            </aside>
        </section>

        <footer>
            <span>Mind Island does not diagnose or replace professional care.</span>
            <span>Built full-stack in Jac · graph walkers · typed byLLM</span>
        </footer>
    </main>;
}
