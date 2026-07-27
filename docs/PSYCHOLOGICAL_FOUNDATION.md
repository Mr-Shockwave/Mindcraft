# Mindcraft Psychological Foundation

## Purpose and scope

Mindcraft is a brief, non-clinical emotional reflection experience for a university student facing an immediate high-pressure moment, such as giving a presentation. It is intended to help the user notice and describe an experience, create psychological distance from it, and choose one small values-guided action.

It is not therapy, diagnosis, crisis support, medical treatment, or a substitute for a qualified professional. The product must never claim that it heals anxiety, improves a disorder, or produces a clinically meaningful outcome.

## Central design principle

The desired outcome is **psychological flexibility**, not forced positivity.

The game does not reward a user for making an emotion disappear. It rewards the process of:

1. noticing what is present;
2. placing it outside the self as a metaphor;
3. allowing it to exist without combat;
4. choosing how to relate to it;
5. taking one small action connected to what matters.

An entity's visual transformation means “my relationship to this experience shifted.” It must not mean “the bad emotion was defeated” or “I am cured.”

## Acceptance and Commitment Therapy model

Mindcraft draws design inspiration from the six processes commonly described in ACT. It does not attempt to deliver an ACT treatment protocol.

### Present-moment awareness

The check-in asks what is showing up **right now**. The breathing interaction offers a short attentional anchor. Neither mechanic promises calmness; calm may or may not occur.

Design requirements:

- Use immediate, observational language.
- Do not require a detailed personal history.
- Do not mark continued discomfort as failure.

### Acceptance and willingness

The island always has room for the entity. Interactions such as water, warmth, or breathing communicate care and willingness rather than removal.

Design requirements:

- Never provide attack, delete, imprison, or destroy actions.
- Do not use “health,” “damage,” or “enemy” meters.
- Do not score symptom reduction.

### Cognitive defusion

The user’s statement becomes a separate entity with a nature metaphor. This helps shift language from “I am anxious” toward “an anxious story or sensation is showing up.”

Design requirements:

- Describe the entity as one experience, not the user's identity.
- Prefer “nerves are showing up” over “you are an anxious person.”
- Never infer a disorder from a short text entry.

### Self-as-context

The island represents the larger observing context. An emotion occupies part of the island, but the island is more than any single entity.

Design requirements:

- Preserve prior entities as parts of a broader landscape.
- Avoid making one emotional state fill or define the entire world.
- Use language such as “your island can hold this.”

### Values

The final prompt asks what matters in the immediate situation. For the demo persona, possible values include learning, courage, contribution, honesty, or connection.

The MVP does not ask the LLM to infer a user's values. The user names their own next step.

### Committed action

The session concludes with one small, concrete action that can be taken while discomfort is present, such as opening notes or saying the first prepared sentence.

A useful action is:

- chosen by the user;
- small enough to perform immediately;
- observable and specific;
- not conditional on feeling better first.

## Expressive arts and externalization

The visual metaphor turns an abstract internal experience into a manipulable symbolic form. The predefined asset library limits unsafe or inconsistent imagery. The AI selects from approved metaphors; it does not generate images.

Metaphors should be:

- nonviolent;
- culturally neutral where possible;
- grounded in weather, plants, paths, light, and natural materials;
- open to interpretation rather than presented as psychological truth.

The user should eventually be allowed to reject or change a metaphor. For the hackathon MVP, the deterministic fallback provides a reliable and gentle default.

## Reinforcement and gamification

Gamification must reinforce healthy process rather than emotional suppression or compulsive engagement.

Allowed reinforcement:

- an island becoming more varied after reflection;
- a visible transformation after a chosen interaction;
- acknowledgement of completing a values-guided step;
- optional records of strategies the user chose.

Avoid:

- points based on happiness or symptom reduction;
- streak loss, guilt, countdown pressure, or push-notification pressure;
- leaderboards comparing emotional wellness;
- “perfect mental health” completion states;
- rewards for disclosing increasingly sensitive information;
- dark patterns that increase session length.

The ideal session ends after three to five minutes. Successful disengagement is a product success.

## State model

Entities move through process stages rather than health levels:

- `externalized`: the experience has been given a separate form;
- `acknowledged`: the user chose a way to make room for it;
- `integrated`: the user connected the experience to a small next action.

The optional self-rated intensity of an experience may be collected in a future version, but it must remain descriptive. A lower rating is not required for completion.

## AI behavior

The LLM receives only the current short text. Its typed output is constrained to:

- a broad emotional theme, not a diagnosis;
- a brief non-clinical label;
- a gentle metaphor;
- approved initial and transformed asset IDs;
- one validating reflection;
- optional interaction suggestions.

The user chooses the interaction. AI suggestions are not treatment recommendations.

The backend validates every asset ID and transformation pair. A deterministic path must remain available when the model is unavailable, slow, or returns invalid data.

## Safety behavior

Mindcraft should intercept clear crisis phrases before calling the LLM or creating a graph node. The current MVP displays an immediate limitation statement and U.S./Canada 988 information.

Before public release:

- add region-aware crisis resources;
- have the wording reviewed by a qualified mental-health professional;
- test false positives and evasive phrasing;
- provide an always-visible way to access urgent support;
- define an incident and content-review process.

The app should not attempt a conversational crisis intervention. It should clearly redirect to immediate human support.

## Privacy

Hackathon mode is anonymous and stores the minimum session graph needed for the experience. Raw journal histories, diagnoses, demographics, and account profiles are out of scope.

Required practices:

- never place API keys in client code or source control;
- do not log the user’s raw emotional text;
- explain that an external model provider may process submitted text;
- provide a reset action before any real-world pilot;
- avoid analytics that capture free-text input.

## Language guide

Prefer:

- “What is showing up?”
- “Your island can make room for this.”
- “You can choose a step while this feeling comes along.”
- “This metaphor is one possible way to picture it.”

Avoid:

- “We detected anxiety.”
- “This tool will calm you down.”
- “You healed the negative emotion.”
- “Your emotion score improved.”
- “Complete your streak to stay mentally healthy.”

## Evidence and evaluation

The hackathon demo should make only implementation-level claims: the product externalizes a user-described feeling, offers constrained choices, and records a values-guided action.

A later user study could evaluate:

- whether users understand that the metaphor is separate from identity;
- perceived autonomy over interaction choices;
- whether the flow helps users name a feasible next action;
- perceived safety, warmth, and clarity;
- session completion without pressure to disclose more.

Clinical efficacy claims would require a suitable study design, validated measures, ethics review where applicable, and professional oversight.

## Review requirement

This document is a design rationale, not clinical approval. Any pilot involving vulnerable users, schools, counselors, or stored mental-health information requires review by qualified mental-health, privacy, and safeguarding professionals.
