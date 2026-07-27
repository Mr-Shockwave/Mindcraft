
import from datetime { datetime }


enum EmotionTheme {
    ANXIETY,
    OVERWHELM,
    SADNESS,
    FRUSTRATION,
    UNCERTAINTY
}

obj EmotionReading {
    has theme: EmotionTheme,
        gentle_label: str,
        metaphor: str,
        asset_id: str,
        transformed_asset_id: str,
        reflection: str,
        suggested_tools: list[str];
}

sem EmotionReading.gentle_label = "A brief, non-diagnostic label using the user's own framing.";
sem EmotionReading.metaphor = "A concrete nature metaphor that externalizes, but never pathologizes, the feeling.";
sem EmotionReading.asset_id = "Exactly one allowed initial asset ID.";
sem EmotionReading.transformed_asset_id = "Exactly one allowed transformed asset ID.";
sem EmotionReading.reflection = "One warm sentence that validates the experience without promising treatment.";
sem EmotionReading.suggested_tools = "Two optional tool IDs. The user remains free to choose any tool.";

def interpret_emotion(feeling_text: str) -> EmotionReading by llm(temperature=0.2);
sem interpret_emotion = """
Interpret a student's immediate feeling before a presentation. Do not diagnose, prescribe,
or claim therapy. Choose asset_id from dark_cloud, tangled_knot, heavy_stone, windy_leaves,
or fog_patch. Choose transformed_asset_id from rain_garden, open_ribbon, mossy_stone,
gentle_breeze, or lantern_path. Tool IDs may only be breathe, sunlight, water, or name_it.
Treat transformation as making room for an emotion, not eliminating or curing it.
""";


node MindIsland {
    has created_at: str;
}

node EmotionalEntity {
    has gentle_label: str,
        theme: str,
        metaphor: str,
        asset_id: str,
        transformed_asset_id: str,
        reflection: str,
        created_at: str,
        process_stage: str = "externalized",
        interaction_count: int = 0,
        is_transformed: bool = False,
        placed: bool = False,
        x: float = 0.5,
        y: float = 0.5;
}

node InteractionEvent {
    has tool_id: str,
        process_supported: str,
        created_at: str;
}

node ValueAction {
    has action_text: str,
        created_at: str;
}

edge Contains {}
edge Chose {}
edge LedTo {}


glob ALLOWED_ASSETS: dict = {
    "dark_cloud": "☁️",
    "tangled_knot": "🪢",
    "heavy_stone": "🪨",
    "windy_leaves": "🍂",
    "fog_patch": "🌫️",
    "rain_garden": "🌈",
    "open_ribbon": "🎗️",
    "mossy_stone": "🌱",
    "gentle_breeze": "🍃",
    "lantern_path": "🏮"
};

glob TRANSFORM_PAIRS: dict = {
    "dark_cloud": "rain_garden",
    "tangled_knot": "open_ribbon",
    "heavy_stone": "mossy_stone",
    "windy_leaves": "gentle_breeze",
    "fog_patch": "lantern_path"
};

glob TOOLS: dict = {
    "breathe": {"name": "Three slow breaths", "icon": "🫧", "process": "present-moment awareness"},
    "sunlight": {"name": "Offer warmth", "icon": "☀️", "process": "acceptance"},
    "water": {"name": "Make some room", "icon": "💧", "process": "willingness"},
    "name_it": {"name": "Name the story", "icon": "🏷️", "process": "cognitive defusion"}
};

glob THEME_ASSETS: dict = {
    "anxiety": ["dark_cloud", "tangled_knot", "fog_patch"],
    "overwhelm": ["tangled_knot", "heavy_stone", "fog_patch"],
    "sadness": ["heavy_stone", "dark_cloud", "windy_leaves"],
    "frustration": ["windy_leaves", "tangled_knot", "dark_cloud"],
    "uncertainty": ["fog_patch", "windy_leaves", "dark_cloud"]
};


def is_crisis_language(text: str) -> bool {
    lowered = text.lower();
    crisis_phrases = [
        "kill myself", "end my life", "want to die", "suicide",
        "hurt myself", "self harm", "self-harm", "can't go on",
        "cannot go on", "ending it all", "no reason to live"
    ];
    return any([phrase in lowered for phrase in crisis_phrases]) as bool;
}

def clamp01(value: float) -> float {
    if value < 0.08 {
        return 0.08;
    }
    if value > 0.92 {
        return 0.92;
    }
    return value;
}

def sanitize_tools(tool_ids: list[str]) -> list[str] {
    clean: list[str] = [];
    for tool_id in tool_ids {
        if tool_id in TOOLS and tool_id not in clean {
            clean.append(tool_id);
        }
    }
    if not clean {
        return ["breathe", "name_it"];
    }
    return clean;
}

def theme_variants(theme_key: str) -> list[str] {
    defaults: list[str] = ["dark_cloud", "tangled_knot", "fog_patch"];
    raw: list[str] = defaults;
    if theme_key == "anxiety" {
        raw = ["dark_cloud", "tangled_knot", "fog_patch"];
    } elif theme_key == "overwhelm" {
        raw = ["tangled_knot", "heavy_stone", "fog_patch"];
    } elif theme_key == "sadness" {
        raw = ["heavy_stone", "dark_cloud", "windy_leaves"];
    } elif theme_key == "frustration" {
        raw = ["windy_leaves", "tangled_knot", "dark_cloud"];
    } elif theme_key == "uncertainty" {
        raw = ["fog_patch", "windy_leaves", "dark_cloud"];
    }

    variants: list[str] = [];
    for asset_id in raw {
        if asset_id in TRANSFORM_PAIRS and asset_id not in variants {
            variants.append(asset_id);
        }
    }
    if not variants {
        return defaults;
    }
    return variants;
}

def reading_is_valid(reading: EmotionReading) -> bool {
    if reading.asset_id not in TRANSFORM_PAIRS {
        return False;
    }
    if reading.transformed_asset_id != TRANSFORM_PAIRS[reading.asset_id] {
        return False;
    }
    return True;
}

def fallback_reading(feeling_text: str) -> EmotionReading {
    lowered = feeling_text.lower();
    if "angry" in lowered or "frustrat" in lowered {
        return EmotionReading(
            theme=EmotionTheme.FRUSTRATION,
            gentle_label="A lot of charged energy is here",
            metaphor="Wind is moving quickly through the leaves",
            asset_id="windy_leaves",
            transformed_asset_id="gentle_breeze",
            reflection="It makes sense that this moment carries energy; you can notice it without fighting it.",
            suggested_tools=["name_it", "breathe"]
        );
    }
    if "sad" in lowered or "heavy" in lowered {
        return EmotionReading(
            theme=EmotionTheme.SADNESS,
            gentle_label="Something feels heavy right now",
            metaphor="A stone is resting on the island",
            asset_id="heavy_stone",
            transformed_asset_id="mossy_stone",
            reflection="You do not have to force this heaviness away to take one caring next step.",
            suggested_tools=["water", "sunlight"]
        );
    }
    return EmotionReading(
        theme=EmotionTheme.ANXIETY,
        gentle_label="Presentation nerves are showing up",
        metaphor="A small cloud is passing over the island",
        asset_id="dark_cloud",
        transformed_asset_id="rain_garden",
        reflection="Nerves can be present while you still move toward what matters to you.",
        suggested_tools=["breathe", "name_it"]
    );
}

def safe_reading(feeling_text: str) -> EmotionReading {
    reading = fallback_reading(feeling_text);
    try {
        candidate = interpret_emotion(feeling_text);
        if reading_is_valid(candidate) {
            reading = candidate;
        }
    } except Exception {
        reading = fallback_reading(feeling_text);
    }
    reading.suggested_tools = sanitize_tools(reading.suggested_tools);
    return reading;
}

def entity_view(entity: EmotionalEntity) -> dict {
    current_asset = entity.transformed_asset_id if entity.is_transformed else entity.asset_id;
    return {
        "id": jid(entity),
        "label": entity.gentle_label,
        "theme": entity.theme,
        "metaphor": entity.metaphor,
        "asset_id": current_asset,
        "symbol": ALLOWED_ASSETS.get(current_asset, "✨"),
        "reflection": entity.reflection,
        "process_stage": entity.process_stage,
        "interaction_count": entity.interaction_count,
        "is_transformed": entity.is_transformed,
        "placed": entity.placed,
        "x": entity.x,
        "y": entity.y
    };
}

def island_entities(island: MindIsland) -> list {
    return [entity_view(entity) for entity in [island-->][?:EmotionalEntity]];
}


walker:pub get_world {
    can fetch with Root entry {
        islands = [-->][?:MindIsland];
        if not islands {
            island = MindIsland(created_at=datetime.now().isoformat());
            root +>: Contains() :+> island;
            report {"entities": [], "tools": TOOLS};
            return;
        }
        report {"entities": island_entities(islands[0]), "tools": TOOLS};
    }
}

walker:pub manifest_emotion {
    has feeling_text: str;

    can manifest with Root entry {
        clean_text = self.feeling_text.strip();
        if len(clean_text) < 3 {
            report {"ok": False, "error": "Write a few words about what is showing up."};
            return;
        }
        if is_crisis_language(clean_text) {
            report {
                "ok": False,
                "crisis": True,
                "error": "Mind Island is not crisis support. If you may act on these thoughts, call emergency services now. In the U.S. or Canada, call or text 988."
            };
            return;
        }

        islands = [-->][?:MindIsland];
        if islands {
            island = islands[0];
        } else {
            island = MindIsland(created_at=datetime.now().isoformat());
            root +>: Contains() :+> island;
        }

        reading = safe_reading(clean_text);
        theme_key = str(reading.theme).split(".")[-1].lower();
        variants = theme_variants(theme_key);

        new_entities: list = [];
        for asset_id in variants {
            entity = EmotionalEntity(
                gentle_label=reading.gentle_label,
                theme=theme_key,
                metaphor=reading.metaphor,
                asset_id=asset_id,
                transformed_asset_id=TRANSFORM_PAIRS[asset_id] as str,
                reflection=reading.reflection,
                created_at=datetime.now().isoformat(),
                placed=False,
                x=0.5,
                y=0.5
            );
            island +>: Contains() :+> entity;
            new_entities.append(entity_view(entity));
        }

        report {
            "ok": True,
            "pending": new_entities,
            "suggested_tools": reading.suggested_tools,
            "world": island_entities(island)
        };
    }
}

walker:pub place_entity {
    has entity_id: str;
    has x: float;
    has y: float;

    can place with Root entry {
        for island in [-->][?:MindIsland] {
            for entity in [island-->][?:EmotionalEntity] {
                if jid(entity) == self.entity_id {
                    entity.placed = True;
                    entity.x = clamp01(self.x);
                    entity.y = clamp01(self.y);
                    report {
                        "ok": True,
                        "message": "Your island made room for this feeling.",
                        "entity": entity_view(entity),
                        "world": island_entities(island)
                    };
                    return;
                }
            }
        }
        report {"ok": False, "error": "That feeling could not be found."};
    }
}

walker:pub apply_interaction {
    has entity_id: str;
    has tool_id: str;

    can apply with Root entry {
        if self.tool_id not in TOOLS {
            report {"ok": False, "error": "That tool is not available."};
            return;
        }
        for island in [-->][?:MindIsland] {
            for entity in [island-->][?:EmotionalEntity] {
                if jid(entity) == self.entity_id {
                    if not entity.placed {
                        report {
                            "ok": False,
                            "error": "Drag this feeling onto your island before choosing an interaction."
                        };
                        return;
                    }
                    event = InteractionEvent(
                        tool_id=self.tool_id,
                        process_supported=str(TOOLS[self.tool_id]["process"]),
                        created_at=datetime.now().isoformat()
                    );
                    entity +>: Chose() :+> event;
                    entity.interaction_count += 1;
                    entity.process_stage = "acknowledged";
                    entity.is_transformed = True;
                    report {
                        "ok": True,
                        "message": "The feeling did not need to disappear. Your island made room for it.",
                        "entity": entity_view(entity),
                        "world": island_entities(island)
                    };
                    return;
                }
            }
        }
        report {"ok": False, "error": "That feeling could not be found."};
    }
}

walker:pub commit_value_action {
    has entity_id: str;
    has action_text: str;

    can commit with Root entry {
        clean_action = self.action_text.strip();
        if len(clean_action) < 3 {
            report {"ok": False, "error": "Choose one small action you can actually take."};
            return;
        }
        for island in [-->][?:MindIsland] {
            for entity in [island-->][?:EmotionalEntity] {
                if jid(entity) == self.entity_id {
                    if not entity.is_transformed {
                        report {
                            "ok": False,
                            "error": "Choose how you want to meet this feeling before planting an intention."
                        };
                        return;
                    }
                    action = ValueAction(
                        action_text=clean_action,
                        created_at=datetime.now().isoformat()
                    );
                    entity +>: LedTo() :+> action;
                    entity.process_stage = "integrated";
                    report {
                        "ok": True,
                        "message": "Your feeling can come with you while you take this step.",
                        "world": island_entities(island)
                    };
                    return;
                }
            }
        }
        report {"ok": False, "error": "That feeling could not be found."};
    }
}

walker:pub reset_demo {
    can reset with Root entry {
        for island in [-->][?:MindIsland] {
            for entity in [island-->][?:EmotionalEntity] {
                del entity;
            }
            del island;
        }
        report {"ok": True};
    }
}

cl {
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
                                    <span className="tray-name">{entity["theme"]}</span>
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
}
