import from main {
    ALLOWED_ASSETS,
    TOOLS,
    TRANSFORM_PAIRS,
    Contains,
    EmotionalEntity,
    MindIsland,
    apply_interaction,
    clamp01,
    commit_value_action,
    fallback_reading,
    is_crisis_language,
    manifest_emotion,
    place_entity,
    reading_is_valid,
    reset_demo,
    sanitize_tools,
    theme_variants
}


test "crisis language is intercepted" {
    assert is_crisis_language("I want to kill myself");
    assert is_crisis_language("I cannot go on and want to end my life");
    assert is_crisis_language("I feel like ending it all");
    assert not is_crisis_language("I feel anxious about my presentation");
}

test "fallback always uses an approved asset pair" {
    reading = fallback_reading("I feel nervous about presenting");
    assert reading.asset_id in ALLOWED_ASSETS;
    assert reading.transformed_asset_id == TRANSFORM_PAIRS[reading.asset_id];
    assert reading_is_valid(reading);
}

test "sad fallback uses a nonviolent nature metaphor" {
    reading = fallback_reading("I feel sad and heavy");
    assert reading.asset_id == "heavy_stone";
    assert reading.transformed_asset_id == "mossy_stone";
}

test "tools support ACT processes rather than mood scores" {
    assert TOOLS["name_it"]["process"] == "cognitive defusion";
    assert "score" not in TOOLS["breathe"];
}

test "sanitize tools drops invents and keeps allowlisted ids" {
    cleaned = sanitize_tools(["breathe", "chainsaw", "name_it", "breathe"]);
    assert cleaned == ["breathe", "name_it"];
    assert sanitize_tools(["laser"]) == ["breathe", "name_it"];
}

test "theme variants only return transformable assets" {
    for asset_id in theme_variants("anxiety") {
        assert asset_id in TRANSFORM_PAIRS;
    }
}

test "clamp01 keeps island coordinates in bounds" {
    assert clamp01(-1.0) == 0.08;
    assert clamp01(2.0) == 0.92;
    assert clamp01(0.4) == 0.4;
}

test "island contains emotional entities through typed edges" {
    island = MindIsland(created_at="demo");
    root +>: Contains() :+> island;
    entity = EmotionalEntity(
        gentle_label="Presentation nerves are showing up",
        theme="anxiety",
        metaphor="A cloud",
        asset_id="dark_cloud",
        transformed_asset_id="rain_garden",
        reflection="Nerves can come with you.",
        created_at="demo"
    );
    island +>: Contains() :+> entity;

    assert island in [root ->:Contains:->];
    assert entity in [island ->:Contains:->];
}

test "manifest creates three pending tray entities" {
    result = root spawn reset_demo();
    assert result.reports[0]["ok"];

    result = root spawn manifest_emotion(
        feeling_text="I feel anxious about presenting my project."
    );
    payload = result.reports[0];
    assert payload["ok"];
    assert len(payload["pending"]) == 3;
    for entity in payload["pending"] {
        assert entity["placed"] == False;
        assert entity["asset_id"] in TRANSFORM_PAIRS;
    }
}

test "place interaction and commit follow ACT stages" {
    root spawn reset_demo();
    manifested = root spawn manifest_emotion(
        feeling_text="I feel anxious about presenting my project."
    );
    pending = manifested.reports[0]["pending"];
    entity_id = pending[0]["id"];

    blocked = root spawn apply_interaction(entity_id=entity_id, tool_id="breathe");
    assert blocked.reports[0]["ok"] == False;

    placed = root spawn place_entity(entity_id=entity_id, x=1.5, y=-0.2);
    assert placed.reports[0]["ok"];
    assert placed.reports[0]["entity"]["placed"] == True;
    assert placed.reports[0]["entity"]["x"] == 0.92;
    assert placed.reports[0]["entity"]["y"] == 0.08;
    assert placed.reports[0]["entity"]["process_stage"] == "externalized";

    acknowledged = root spawn apply_interaction(entity_id=entity_id, tool_id="breathe");
    assert acknowledged.reports[0]["ok"];
    assert acknowledged.reports[0]["entity"]["is_transformed"] == True;
    assert acknowledged.reports[0]["entity"]["process_stage"] == "acknowledged";

    integrated = root spawn commit_value_action(
        entity_id=entity_id,
        action_text="Say the first prepared sentence."
    );
    assert integrated.reports[0]["ok"];
    world = integrated.reports[0]["world"];
    target = [e for e in world if e["id"] == entity_id][0];
    assert target["process_stage"] == "integrated";
}

test "crisis path does not create an entity" {
    root spawn reset_demo();
    result = root spawn manifest_emotion(feeling_text="I want to kill myself");
    payload = result.reports[0];
    assert payload["ok"] == False;
    assert payload["crisis"] == True;

    islands = [root-->][?:MindIsland];
    if islands {
        assert len([islands[0]-->][?:EmotionalEntity]) == 0;
    }
}
