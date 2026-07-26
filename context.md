# Project Context: Mind Island (Mental Health Interactive World)

## 1. Project Vision & Core Philosophy
**Mind Island** is a 2D interactive web application designed for mental health and emotional regulation. Unlike traditional building games (e.g., Minecraft) focused on resource accumulation, this project focuses on **Cognitive Reframing** and **Emotional Externalization**. Users input their current emotional state, and the system manifests it into a tangible, interactive 2D entity within a growing "Mind Island." Users then interact with these entities to gently transform them, turning negative emotions into positive, constructive elements of their personal world.

## 2. Theoretical Foundation: ACT & Expressive Arts Therapy
The core mechanics are strictly based on **Acceptance and Commitment Therapy (ACT)** and **Expressive Arts Therapy**. The game does NOT use a "combat/destroy" metaphor for negative emotions.

*   **Cognitive Defusion (认知解离):** ACT emphasizes separating the "self" from the "emotion." 
    *   *Game Mechanic:* The user types their feeling, and the AI generates a separate, visual "Emotional Entity" (e.g., a dark cloud, a thorny vine). This externalizes the emotion, allowing the user to observe it objectively rather than being overwhelmed by it.
*   **Acceptance (接纳):** ACT encourages making room for unpleasant feelings rather than fighting them.
    *   *Game Mechanic:* Users cannot "destroy" or "attack" the entity with weapons. They must use gentle, nurturing interaction tools (e.g., "Sunlight," "Deep Breathing," "Water") to acknowledge and soothe the entity.
*   **Committed Action (价值行动):** Taking steps guided by personal values even in the presence of difficult emotions.
    *   *Game Mechanic:* When an entity is successfully soothed, it doesn't disappear. It **transforms** into a positive, permanent part of the world (e.g., the dark cloud transforms into a rainbow; the thorny vine blooms into flowers). This metaphorically represents building a meaningful life *alongside* managed emotions.

## 3. Target Audience & User Personas
*   **Primary:** High cognitive-load young professionals and university students (18-30 years old). They face short-term, high-intensity stress, have no time for 50-minute therapy sessions, and need a low-barrier, non-judgmental, 3-5 minute emotional outlet.
*   **Secondary:** School counselors or junior therapists who can use this tool as an "ice-breaker" to help clients visualize and articulate complex feelings.

## 4. Core Gameplay Loop
1.  **Externalize (Input):** User types their current feeling (e.g., "I feel anxious about my presentation").
2.  **Manifest (AI Generation):** The AI analyzes the text and spawns a specific 2D visual entity representing that emotion (e.g., a "tangled knot" or "dark cloud") on the 2D canvas.
3.  **Reframe & Interact (Action):** The user selects a coping tool from the toolbar (e.g., "Sunlight") and applies it to the entity.
4.  **Transform (Feedback):** The entity's state changes. The visual asset updates to its "healed" counterpart (e.g., the dark cloud becomes a gentle breeze), and the "Mind Island" expands or becomes more vibrant.

## 5. World Design & Visual Paradigm
*   **Visual Style:** 2D top-down isometric or flat 2D "Mind Island" / Infinite Canvas. Soft, healing, lo-fi aesthetic. 
*   **Coordinate System:** NO complex physics engine coordinates (x,y,z). We use a **Logical Grid / Topological Graph**. The frontend handles pixel rendering based on logical relationships defined in the backend.
*   **Asset Management:** The AI **DOES NOT** generate images. It selects from a strictly predefined `assets_library.json` containing 30-50 high-quality 2D SVG/PNG assets (clouds, trees, flowers, rocks, tools).

## 6. AI Integration & Strict Guardrails
To prevent AI hallucinations and ensure 100% technical execution in a 1-day hackathon, AI freedom is heavily constrained:
*   **Strict JSON Schema:** The LLM must output a strict JSON object matching the Jac `node` schema.
*   **Asset Mapping:** The LLM is prompted to choose `asset_id` ONLY from a predefined allowed list based on the emotion tag.
*   **Emotional Consistency:** The backend validates that the chosen asset matches the emotional tone (e.g., preventing a "chainsaw" from spawning in a "calm" context).

## 7. Technical Architecture (The "JacHacks" Stack)
The shipped project is a single full-stack Jac application optimized for JacHammer. Lovable may be used for visual exploration, but production frontend, backend, AI, and graph logic remain in Jac.

### Full Stack: Jac (Jaseci) - *The Core Brain and Interface*
*Must utilize Jac's Object Spatial Programming (OSP) to score high on the "Use of Jac" rubric.*
*   **Nodes:** 
    *   `MindIsland`: Anonymous session world.
    *   `EmotionalEntity`: Stores `asset_id`, emotional theme, ACT process stage, and transform target.
    *   `InteractionEvent`: Records the user-chosen tool and supported ACT process.
    *   `ValueAction`: Records one small action chosen by the user.
*   **Walkers (The Logic Flow):**
    *   `manifest_emotion`: Takes user text, calls `byLLM()` to generate structured JSON, and spawns an `EmotionalEntity` node connected to the `World`.
    *   `apply_interaction`: Traverses the graph, records the user's choice, and transforms the visual metaphor without treating emotion as damage or disease.
    *   `commit_value_action`: Connects the entity to a user-chosen next step and marks it integrated.
*   **API:** Public walkers expose the core workflow to Jac client code.
*   **Frontend:** Jac client JSX renders the island, check-in, tool palette, and action prompt. Jac generates the React client and RPC boundary.

## 8. Configurable Logic (Human-in-the-Loop)
The following logic is hardcoded/configurable by the developers to ensure a perfect demo, rather than relying on AI randomness:
1.  **Emotion-to-Asset Mapping:** Defined in `assets_library.json`. (e.g., "anxiety" -> `["dark_cloud_01", "tangled_knot_01"]`).
2.  **Interaction Compatibility:** Defined in Jac as optional ACT-consistent suggestions. The user remains free to choose; there are no health percentages or mood scores.
3.  **Transform Target Path:** Hardcoded in the `EmotionalEntity` node. Transforming represents integration, not curing or eliminating the feeling.

## 9. Instructions for Cursor (How to use this context)
You are an expert full-stack developer specializing in **Jac (Jaclang)**, Jac client JSX, and AI agent architecture. 
*   **Do not** write a Python/Node.js backend. All core logic, state management, and AI orchestration MUST be written in **Jac**.
*   **Focus on Jac features:** Use `node`, `edge`, `walker`, and `byLLM()` extensively. The code must demonstrate "Central" use of Jac (graph traversal, agentic flows).
*   **Keep it simple:** We are building an MVP for a 1-day hackathon. Prioritize a flawless, end-to-end working demo over complex features. 
*   **Next Steps:** I will guide you through the specific tasks (e.g., "Write the Jac nodes", "Write the frontend Canvas component"). Acknowledge this context and wait for my first specific coding instruction.