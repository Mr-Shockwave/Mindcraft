import from main {
    ALLOWED_ASSETS,
    TOOLS,
    TRANSFORM_PAIRS,
    Contains,
    EmotionalEntity,
    MindIsland,
    fallback_reading,
    is_crisis_language
}


test "crisis language is intercepted" {
    assert is_crisis_language("I want to kill myself");
    assert is_crisis_language("I cannot go on and want to end my life");
    assert not is_crisis_language("I feel anxious about my presentation");
}

test "fallback always uses an approved asset pair" {
    reading = fallback_reading("I feel nervous about presenting");
    assert reading.asset_id in ALLOWED_ASSETS;
    assert reading.transformed_asset_id == TRANSFORM_PAIRS[reading.asset_id];
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
