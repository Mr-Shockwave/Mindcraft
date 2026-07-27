
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
or claim therapy. Choose theme that best matches the text among anxiety, overwhelm, sadness,
frustration, or uncertainty — do not default to anxiety when another theme fits better.
Choose asset_id from dark_cloud, tangled_knot, heavy_stone, windy_leaves, or fog_patch.
Choose transformed_asset_id from rain_garden, open_ribbon, mossy_stone, gentle_breeze,
or lantern_path, matching the pair for your asset_id.
Tool IDs may only be breathe, sunlight, water, or name_it.
Treat transformation as making room for an emotion, not eliminating or curing it.
Write reflection as one concrete, warm sentence that mirrors the user's wording and names
what is hard without promising calm or a cure. Prefer suggested_tools that fit the moment:
breathe for racing thoughts, name_it for sticky self-stories, water for overwhelm,
sunlight for harsh self-criticism.
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

edge Contains {}
edge Chose {}


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

def theme_key_of(reading: EmotionReading) -> str {
    raw = str(reading.theme).split(".")[-1].lower().strip();
    if raw in THEME_ASSETS {
        return raw;
    }
    return "anxiety";
}

def coerce_reading(candidate: EmotionReading) -> EmotionReading {
    if candidate.asset_id in TRANSFORM_PAIRS {
        candidate.transformed_asset_id = TRANSFORM_PAIRS[candidate.asset_id] as str;
    }
    candidate.suggested_tools = sanitize_tools(candidate.suggested_tools);
    if not candidate.suggested_tools {
        candidate.suggested_tools = ["breathe", "name_it"];
    }
    if not candidate.gentle_label.strip() {
        candidate.gentle_label = "Something is showing up right now";
    }
    if not candidate.metaphor.strip() {
        candidate.metaphor = "A nature form has arrived on the island";
    }
    if not candidate.reflection.strip() {
        candidate.reflection = "This feeling can be present while you choose one small next step.";
    }
    return candidate;
}

def fallback_reading(feeling_text: str) -> EmotionReading {
    lowered = feeling_text.lower();
    if (
        "angry" in lowered or "frustrat" in lowered or "irritat" in lowered
        or "annoyed" in lowered or "mad" in lowered
    ) {
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
    if (
        "sad" in lowered or "heavy" in lowered or "lonely" in lowered
        or "down" in lowered or "cry" in lowered or "grief" in lowered
    ) {
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
    if (
        "overwhelm" in lowered or "too much" in lowered or "swamped" in lowered
        or "burned out" in lowered or "burnt out" in lowered or "exhausted" in lowered
    ) {
        return EmotionReading(
            theme=EmotionTheme.OVERWHELM,
            gentle_label="Everything feels like a lot at once",
            metaphor="A tangled knot is sitting on the path",
            asset_id="tangled_knot",
            transformed_asset_id="open_ribbon",
            reflection="When a lot arrives together, you can still choose one thread to hold.",
            suggested_tools=["water", "breathe"]
        );
    }
    if (
        "uncertain" in lowered or "unsure" in lowered or "confused" in lowered
        or "lost" in lowered or "don't know" in lowered or "dont know" in lowered
        or "doubt" in lowered
    ) {
        return EmotionReading(
            theme=EmotionTheme.UNCERTAINTY,
            gentle_label="The path feels unclear right now",
            metaphor="A soft fog is resting across the island",
            asset_id="fog_patch",
            transformed_asset_id="lantern_path",
            reflection="Not knowing yet can sit beside one small step you still choose.",
            suggested_tools=["name_it", "sunlight"]
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
        candidate = coerce_reading(interpret_emotion(feeling_text));
        if candidate.asset_id in TRANSFORM_PAIRS {
            reading = candidate;
        }
    } except Exception {
        reading = fallback_reading(feeling_text);
    }
    reading.suggested_tools = sanitize_tools(reading.suggested_tools);
    return reading;
}

def safe_reading_bundle(feeling_text: str) -> dict {
    source = "fallback";
    reading = fallback_reading(feeling_text);
    try {
        candidate = coerce_reading(interpret_emotion(feeling_text));
        if candidate.asset_id in TRANSFORM_PAIRS {
            reading = candidate;
            source = "llm";
        }
    } except Exception {
        reading = fallback_reading(feeling_text);
        source = "fallback";
    }
    reading.suggested_tools = sanitize_tools(reading.suggested_tools);
    return {"reading": reading, "source": source};
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
                "error": "Mindcraft is not crisis support. If you may act on these thoughts, call emergency services now. In the U.S. or Canada, call or text 988."
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

        reading_bundle = safe_reading_bundle(clean_text);
        reading = reading_bundle["reading"] as EmotionReading;
        ai_source = str(reading_bundle["source"]);
        theme_key = theme_key_of(reading);
        variants = theme_variants(theme_key);
        # Prefer the model-chosen primary form first in the tray.
        if reading.asset_id in TRANSFORM_PAIRS {
            preferred: list[str] = [reading.asset_id];
            for asset_id in variants {
                if asset_id != reading.asset_id and len(preferred) < 3 {
                    preferred.append(asset_id);
                }
            }
            variants = preferred;
        }

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
            "reflection": reading.reflection,
            "gentle_label": reading.gentle_label,
            "theme": theme_key,
            "ai_source": ai_source,
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
                    # Keep one placed form; remove unused tray twins so they do not stack.
                    for other in [island-->][?:EmotionalEntity] {
                        if jid(other) != self.entity_id and not other.placed {
                            del other;
                        }
                    }
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

def value_action_commit(entity_id: str, action_text: str) -> dict {
    clean_action = action_text.strip();
    if len(clean_action) < 3 {
        return {"ok": False, "error": "Choose one small action you can actually take."};
    }
    for island in [root-->][?:MindIsland] {
        for entity in [island-->][?:EmotionalEntity] {
            if jid(entity) == entity_id {
                if not entity.is_transformed {
                    return {
                        "ok": False,
                        "error": "Choose how you want to meet this feeling before planting an intention."
                    };
                }
                entity.process_stage = "integrated";
                return {
                    "ok": True,
                    "message": "Your feeling can come with you while you take this step.",
                    "world": island_entities(island)
                };
            }
        }
    }
    return {"ok": False, "error": "That feeling could not be found."};
}

walker:pub commit_value_action {
    has entity_id: str;
    has action_text: str;

    can commit with Root entry {
        report value_action_commit(self.entity_id, self.action_text);
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

# Client entry for the demo lives here so JacHammer can serve one stable app.
cl {
    import "./styles.css";

    def:pub app() -> JsxElement {
        has feeling_text: str = "I feel anxious about presenting my project.";
        has entities: list = [];
        has selected_entity: str = "";
        has selected_tool: str = "breathe";
        has suggested_tools: list = ["breathe", "name_it"];
        has action_text: str = "Open my notes and say the first sentence.";
        has generation_target: str = "object";
        has world_style: str = "cloud";
        has event_text: str = "";
        has event_entity: str = "";
        has planted_entity: str = "";
        has notice: str = "";
        has error: str = "";
        has loading: bool = True;
        has busy: bool = False;
        has dragging_id: str = "";
        has tool_labels: dict = {
            "breathe": "Three slow breaths",
            "sunlight": "Offer warmth",
            "water": "Make some room",
            "name_it": "Name the story"
        };

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
                    selected_entity = "";
                    planted_entity = "";
                    suggested_tools = response["suggested_tools"] as list;
                    if len(suggested_tools) > 0 {
                        selected_tool = str(suggested_tools[0]);
                    }
                    theme = str(response["theme"]);
                    source = str(response["ai_source"]);
                    source_note = "AI reading" if source == "llm" else "local metaphor map";
                    notice = str(response["reflection"]) + " (" + theme + " · " + source_note + "). Drag one form onto your island.";
                } else {
                    error = str(response["error"]);
                }
            } except Exception {
                error = "The island paused for a moment. Please try again.";
            }
            busy = False;
        }

        def apply_world() -> None {
            selected_entity = "";
            event_entity = "";
            event_text = "";
        }

        def canvas_point(e: any) -> dict {
            doc = document as any; # jac:ignore[W2001]
            canvas = doc.getElementById("dream-stage");
            rect = canvas.getBoundingClientRect();
            raw_x = ((e.clientX as float) - (rect.left as float)) / (rect.width as float);
            raw_y = ((e.clientY as float) - (rect.top as float)) / (rect.height as float);
            return {
                "x": (0.04 if raw_x < 0.04 else (0.96 if raw_x > 0.96 else raw_x)) as float,
                "y": (0.08 if raw_y < 0.08 else (0.86 if raw_y > 0.86 else raw_y)) as float
            };
        }

        def locally_place_entity(eid: str, x: float, y: float) -> None {
            updated: list = [];
            for item in entities {
                if str(item["id"]) == eid {
                    item["x"] = x;
                    item["y"] = y;
                    item["placed"] = True;
                }
                updated.append(item);
            }
            entities = updated;
        }

        async def send_prompt() -> None {
            if generation_target == "world" {
                apply_world();
                notice = "World mood updated.";
                return;
            }
            # Always manifest a feeling from the text; never hijack into a bubble.
            selected_entity = "";
            planted_entity = "";
            event_entity = "";
            event_text = "";
            manifest();
        }

        async def on_drop(e: any) -> None {
            e.preventDefault();
            eid = dragging_id;
            if not eid {
                return;
            }
            point = canvas_point(e);
            px = point["x"] as float;
            py = point["y"] as float;
            dragging_id = "";
            locally_place_entity(eid, px, py);
            busy = True;
            error = "";
            result = root spawn place_entity(entity_id=eid, x=px, y=py);
            response = result.reports[0];
            if response["ok"] {
                entities = response["world"] as list;
                selected_entity = str(response["entity"]["id"]);
                planted_entity = "";
                notice = "Step 1: choose a tool, then tap Meet this feeling.";
            } else {
                error = str(response["error"]);
            }
            busy = False;
        }

        def start_free_drag(e: any, eid: str) -> None {
            e.preventDefault();
            e.stopPropagation();
            selected_entity = eid;
            dragging_id = eid;
            point = canvas_point(e);
            locally_place_entity(eid, point["x"] as float, point["y"] as float);
            e.currentTarget.setPointerCapture(e.pointerId);
        }

        def move_free_drag(e: any) -> None {
            if not dragging_id {
                return;
            }
            e.preventDefault();
            point = canvas_point(e);
            locally_place_entity(dragging_id, point["x"] as float, point["y"] as float);
        }

        async def end_free_drag(e: any) -> None {
            eid = dragging_id;
            if not eid {
                return;
            }
            e.preventDefault();
            point = canvas_point(e);
            px = point["x"] as float;
            py = point["y"] as float;
            dragging_id = "";
            locally_place_entity(eid, px, py);
            result = root spawn place_entity(entity_id=eid, x=px, y=py);
            response = result.reports[0];
            if response["ok"] {
                entities = response["world"] as list;
                selected_entity = str(response["entity"]["id"]);
                if response["entity"]["is_transformed"] as bool {
                    planted_entity = selected_entity;
                } else {
                    planted_entity = "";
                    notice = "Step 1: choose a tool, then tap Meet this feeling.";
                }
            } else {
                error = str(response["error"]);
            }
        }

        def selected_stage() -> str {
            for item in entities {
                if str(item["id"]) == selected_entity {
                    return str(item["process_stage"]);
                }
            }
            return "";
        }

        async def meet_selected() -> None {
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
                planted_entity = selected_entity;
                tool_name = str(tool_labels[selected_tool]);
                notice = str(response["message"]) + " Step 2: plant one small intention. (Met with " + tool_name + ")";
            } else {
                error = str(response["error"]);
            }
            busy = False;
        }

        async def commit_intention() -> None {
            target = planted_entity if planted_entity else selected_entity;
            if not target or busy {
                return;
            }
            busy = True;
            error = "";
            result = root spawn commit_value_action(
                entity_id=target,
                action_text=action_text
            );
            response = result.reports[0];
            if response["ok"] {
                entities = response["world"] as list;
                planted_entity = target;
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
                planted_entity = "";
                event_entity = "";
                event_text = "";
                notice = "Mindcraft is cleared. Ready for a fresh check-in.";
            } else {
                error = "Could not reset the island.";
            }
            busy = False;
        }

        placed_entities = [e for e in entities if e["placed"]];
        tray_entities = [e for e in entities if not e["placed"]];
        stage = selected_stage();
        can_meet = selected_entity and stage != "integrated";
        can_intend = selected_entity and (stage == "acknowledged" or planted_entity == selected_entity);

        return <main
            id="dream-stage"
            className={"app-shell dream-stage world-" + world_style + (" drag-active" if dragging_id else "")}
            onDragOver={lambda (e: any) { e.preventDefault(); }}
            onDrop={lambda (e: any) { on_drop(e); }}
        >
            <header className="top-bar">
                <div className="brand">
                    <span className="brand-mark">MI</span>
                    <span>Mindcraft</span>
                </div>
            </header>

            <section className="sky-world">
                <div className="sunrise-glow"></div>
                <div className="world-layer"></div>
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
                    <p className="canvas-hint drop-hint">Drag one form into the sky — extras clear after you place it</p>
                }

                {[
                    <div
                        key={entity["id"]}
                        className={"placed-entity dream-creature " + ("active" if selected_entity == entity["id"] else "") + (" planted" if planted_entity == entity["id"] else "") + (" dragging" if dragging_id == entity["id"] else "")}
                        style={{"left": str((entity["x"] as float) * 100.0) + "%", "top": str((entity["y"] as float) * 100.0) + "%"}}
                        onPointerDown={lambda (e: any) { start_free_drag(e, str(entity["id"])); }}
                        onPointerMove={lambda (e: any) { move_free_drag(e); }}
                        onPointerUp={lambda (e: any) { end_free_drag(e); }}
                        onPointerCancel={lambda (e: any) { dragging_id = ""; }}
                        onClick={lambda -> None { selected_entity = str(entity["id"]); }}
                        aria-label={entity["label"]}
                    >
                        <span className={"art-object art-" + str(entity["asset_id"])}>
                            <span></span><span></span><span></span>
                        </span>
                        <span className="entity-caption">{entity["theme"]}</span>
                    </div>
                    for entity in placed_entities
                ]}
            </section>

            <section className="bottom-dock" aria-label="AI chat composer">
                <div className="mode-selects">
                    <select
                        value={generation_target}
                        onChange={lambda (e: any) {
                            generation_target = str(e.target.value);
                            selected_entity = "";
                        }}
                        aria-label="Generation target"
                    >
                        <option value="object">Generate Feeling Form</option>
                        <option value="world">Generate World</option>
                    </select>
                    <select
                        value={world_style}
                        onChange={lambda (e: any) {
                            world_style = str(e.target.value);
                            generation_target = "world";
                            selected_entity = "";
                        }}
                        aria-label="World style"
                    >
                        <option value="cloud">Cloud World</option>
                        <option value="glass">Glass Garden</option>
                        <option value="night">Night Lake</option>
                    </select>
                </div>

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
                                    <span className={"art-object art-" + str(entity["asset_id"])}>
                                        <span></span><span></span><span></span>
                                    </span>
                                    <span className="tray-name">{entity["theme"]}</span>
                                </div>
                                for entity in tray_entities
                            ]}
                        </div>
                    </div>
                }

                {can_meet and
                    <div className="interact-panel">
                        <p className="interact-label">
                            {("Step 2 · Plant an intention" if can_intend else "Step 1 · Meet this feeling")}
                        </p>
                        <div className="tool-row" role="group" aria-label="Choose how to meet this feeling">
                            <button
                                type="button"
                                className={"tool-chip" + (" selected" if selected_tool == "breathe" else "")}
                                onClick={lambda -> None { selected_tool = "breathe"; }}
                            >
                                Three slow breaths
                            </button>
                            <button
                                type="button"
                                className={"tool-chip" + (" selected" if selected_tool == "sunlight" else "")}
                                onClick={lambda -> None { selected_tool = "sunlight"; }}
                            >
                                Offer warmth
                            </button>
                            <button
                                type="button"
                                className={"tool-chip" + (" selected" if selected_tool == "water" else "")}
                                onClick={lambda -> None { selected_tool = "water"; }}
                            >
                                Make some room
                            </button>
                            <button
                                type="button"
                                className={"tool-chip" + (" selected" if selected_tool == "name_it" else "")}
                                onClick={lambda -> None { selected_tool = "name_it"; }}
                            >
                                Name the story
                            </button>
                        </div>
                        <div className="object-editor">
                            <button className="implant-button" onClick={lambda -> None { meet_selected(); }} disabled={busy}>
                                Meet this feeling
                            </button>
                        </div>
                        {can_intend and
                            <div className="value-row">
                                <input
                                    type="text"
                                    value={action_text}
                                    onChange={lambda (e: any) { action_text = str(e.target.value); }}
                                    maxLength={120}
                                    aria-label="One small next step"
                                    placeholder="One small next step you can take..."
                                />
                                <button
                                    className="implant-button"
                                    onClick={lambda -> None { commit_intention(); }}
                                    disabled={busy}
                                >
                                    Plant intention
                                </button>
                            </div>
                        }
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
                        placeholder={("Describe the world mood you want..." if generation_target == "world" else "What's showing up right now? Try: sad, overwhelmed, unsure, frustrated...")}
                    />
                    <button className="send-button" onClick={lambda -> None { send_prompt(); }} disabled={busy}>
                        {("..." if busy else "Send")}
                    </button>
                </div>
            </section>
        </main>;
    }
}
