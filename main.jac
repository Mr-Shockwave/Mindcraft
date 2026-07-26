"""Mind Island: an ACT-inspired, graph-native emotional externalization demo."""

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
        is_transformed: bool = False;
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


def is_crisis_language(text: str) -> bool {
    lowered = text.lower();
    crisis_phrases = [
        "kill myself", "end my life", "want to die", "suicide",
        "hurt myself", "self harm", "can't go on"
    ];
    return any([phrase in lowered for phrase in crisis_phrases]);
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
        if candidate.asset_id in ALLOWED_ASSETS and
           candidate.transformed_asset_id == TRANSFORM_PAIRS[candidate.asset_id] {
            reading = candidate;
        }
    } except Exception {
        # The deterministic path keeps the live demo usable without an API response.
        reading = fallback_reading(feeling_text);
    }
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
        "is_transformed": entity.is_transformed
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
        entity = EmotionalEntity(
            gentle_label=reading.gentle_label,
            theme=str(reading.theme).split(".")[-1].lower(),
            metaphor=reading.metaphor,
            asset_id=reading.asset_id,
            transformed_asset_id=reading.transformed_asset_id,
            reflection=reading.reflection,
            created_at=datetime.now().isoformat()
        );
        island +>: Contains() :+> entity;
        report {
            "ok": True,
            "entity": entity_view(entity),
            "suggested_tools": reading.suggested_tools,
            "world": island_entities(island)
        };
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

    def ToolButton(tool_id: str, tool: dict, selected: bool, choose: any) -> JsxElement {
        return <button
            className={"tool-button " + ("selected" if selected else "")}
            onClick={lambda -> None { choose(tool_id); }}
        >
            <span className="tool-icon">{tool["icon"]}</span>
            <span>{tool["name"]}</span>
        </button>;
    }

    def:pub app() -> JsxElement {
        has feeling_text: str = "I feel anxious about presenting my project.";
        has entities: list = [];
        has selected_entity: any = "";
        has selected_tool: any = "breathe";
        has action_text: str = "Open my notes and say the first sentence.";
        has notice: str = "";
        has error: str = "";
        has loading: bool = True;
        has busy: bool = False;

        async can with entry {
            result = root spawn get_world();
            if result.reports and len(result.reports) > 0 {
                initial_entities = result.reports[0]["entities"];
                entities = initial_entities;
                if len(initial_entities) > 0 {
                    selected_entity = initial_entities[len(initial_entities) - 1]["id"];
                }
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
                    entities = response["world"];
                    selected_entity = response["entity"]["id"];
                    if len(response["suggested_tools"]) > 0 {
                        selected_tool = response["suggested_tools"][0];
                    }
                    notice = response["entity"]["reflection"];
                } else {
                    error = response["error"];
                }
            } except Exception {
                error = "The island paused for a moment. Please try again.";
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
                entities = response["world"];
                notice = response["message"];
            } else {
                error = response["error"];
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
                entities = response["world"];
                notice = response["message"];
            } else {
                error = response["error"];
            }
            busy = False;
        }

        return <main className="app-shell">
            <header className="hero">
                <div>
                    <p className="eyebrow">A three-minute emotional reset</p>
                    <h1>Mind Island</h1>
                    <p className="subtitle">
                        Notice what is here. Give it shape. Carry it with you.
                    </p>
                </div>
                <div className="privacy-pill">Anonymous session · not therapy</div>
            </header>

            <section className="workspace">
                <aside className="panel check-in">
                    <span className="step">01 · Externalize</span>
                    <h2>What is showing up?</h2>
                    <textarea
                        value={feeling_text}
                        onChange={lambda (e: ChangeEvent) { feeling_text = e.target.value; }}
                        maxLength={280}
                        aria-label="Describe what you are feeling"
                    />
                    <button className="primary" onClick={lambda -> None { manifest(); }} disabled={busy}>
                        {("Listening…" if busy else "Place it on my island")}
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
                    <div className="island-sky">
                        <span className="sun">✦</span>
                        <p>Your inner weather can change without being wrong.</p>
                    </div>
                    <div className="island">
                        {loading and <p className="empty-state">Growing your island…</p>}
                        {not loading and len(entities) == 0 and
                            <p className="empty-state">Your island has room for whatever arrives.</p>
                        }
                        {[
                            <button
                                key={entity["id"]}
                                className={"entity " + ("active" if selected_entity == entity["id"] else "")}
                                onClick={lambda -> None { selected_entity = entity["id"]; }}
                                aria-label={entity["label"]}
                            >
                                <span className="entity-symbol">{entity["symbol"]}</span>
                                <span className="entity-label">{entity["label"]}</span>
                                <small>{entity["process_stage"]}</small>
                            </button>
                            for entity in entities
                        ]}
                    </div>
                    {notice and <div className="notice">{notice}</div>}
                    {error and <div className="error" role="alert">{error}</div>}
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
                        onChange={lambda (e: ChangeEvent) { action_text = e.target.value; }}
                        aria-label="One small next action"
                    />
                    <button className="primary" onClick={lambda -> None { commit_action(); }} disabled={not selected_entity or busy}>
                        Plant this intention
                    </button>
                    <div className="act-note">
                        <strong>Why this works</strong>
                        <span>Externalize → allow → choose → act</span>
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
}
