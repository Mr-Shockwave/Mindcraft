"""Mind Island client UI — Person A owns this file.

Person A may redesign freely here and in styles.css / assets.
Do not change walker names, arguments, or response keys.
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
            canvas = doc.getElementById("dream-stage");
            rect = canvas.getBoundingClientRect();
            raw_x = ((e.clientX as float) - (rect.left as float)) / (rect.width as float);
            raw_y = ((e.clientY as float) - (rect.top as float)) / (rect.height as float);
            px = (0.04 if raw_x < 0.04 else (0.96 if raw_x > 0.96 else raw_x)) as float;
            py = (0.08 if raw_y < 0.08 else (0.86 if raw_y > 0.86 else raw_y)) as float;
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

        return <main
            id="dream-stage"
            className={"app-shell dream-stage" + (" drag-active" if dragging_id else "")}
            onDragOver={lambda (e: any) { e.preventDefault(); }}
            onDrop={lambda (e: any) { on_drop(e); }}
        >
            <header className="top-bar">
                <button className="brand" onClick={lambda -> None { reset_island(); }} disabled={busy}>
                    <span className="brand-mark">MI</span>
                    <span>Mind Island</span>
                </button>
                <div className="user-menu" aria-label="User account and settings">
                    <button className="icon-button" aria-label="Settings">⚙</button>
                    <button className="login-button">Log in</button>
                </div>
            </header>

            <section className="sky-world">
                <div className="sunrise-glow"></div>
                <div className="cotton-cloud cloud-left"></div>
                <div className="cotton-cloud cloud-right"></div>
                <div className="cotton-cloud cloud-low"></div>
                <div className="cloud-field">
                    <span></span><span></span><span></span><span></span><span></span>
                    <span></span><span></span><span></span><span></span>
                </div>

                {loading and <p className="canvas-hint">Growing your island...</p>}
                {not loading and len(placed_entities) == 0 and len(tray_entities) == 0 and
                    <p className="canvas-hint">Your island has room for whatever arrives.</p>
                }
                {not loading and len(tray_entities) > 0 and len(placed_entities) == 0 and
                    <p className="canvas-hint drop-hint">Drag a form anywhere into the sky</p>
                }

                {[
                    <button
                        key={entity["id"]}
                        className={"placed-entity dream-creature " + ("active" if selected_entity == entity["id"] else "")}
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
            </section>

            <section className="bottom-dock" aria-label="AI chat composer">
                {len(tray_entities) > 0 and
                    <div className="entity-tray">
                        <div className="tray-row">
                            {[
                                <div
                                    key={entity["id"]}
                                    className={"tray-entity" + (" dragging" if dragging_id == entity["id"] else "")}
                                    draggable={True}
                                    onDragStart={lambda (e: any) {
                                        dragging_id = str(entity["id"]);
                                        e.dataTransfer.effectAllowed = "move";
                                    }}
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

                {(notice or error) and
                    <div className={"toast error" if error else "toast notice"} role={"alert" if error else "status"}>
                        {error if error else notice}
                    </div>
                }

                <div className="tool-row" aria-label="Choose how to meet this feeling">
                    <button
                        className={"tool-chip" + (" selected" if selected_tool == "breathe" else "")}
                        onClick={lambda -> None { selected_tool = "breathe"; }}
                        type="button"
                    >🫧 Breathe</button>
                    <button
                        className={"tool-chip" + (" selected" if selected_tool == "sunlight" else "")}
                        onClick={lambda -> None { selected_tool = "sunlight"; }}
                        type="button"
                    >☀️ Warmth</button>
                    <button
                        className={"tool-chip" + (" selected" if selected_tool == "water" else "")}
                        onClick={lambda -> None { selected_tool = "water"; }}
                        type="button"
                    >💧 Make room</button>
                    <button
                        className={"tool-chip" + (" selected" if selected_tool == "name_it" else "")}
                        onClick={lambda -> None { selected_tool = "name_it"; }}
                        type="button"
                    >🏷️ Name it</button>
                </div>

                <div className="chat-box">
                    <textarea
                        value={feeling_text}
                        onChange={lambda (e: any) { feeling_text = str(e.target.value); }}
                        maxLength={280}
                        aria-label="Describe what you are feeling"
                        placeholder="Tell the island what feeling or thought is here..."
                    />
                    <div className="chat-actions">
                        <button className="chip-button" onClick={lambda -> None { interact(); }} disabled={not selected_entity or busy}>
                            Try this interaction
                        </button>
                        <input
                            value={action_text}
                            onChange={lambda (e: any) { action_text = str(e.target.value); }}
                            aria-label="One small next action"
                            placeholder="One small next action"
                        />
                        <button className="chip-button" onClick={lambda -> None { commit_action(); }} disabled={not selected_entity or busy}>
                            Plant this intention
                        </button>
                        <button className="send-button" onClick={lambda -> None { manifest(); }} disabled={busy}>
                            {("Listening..." if busy else "Place it on my island")}
                        </button>
                    </div>
                </div>
            </section>
        </main>;
    }
