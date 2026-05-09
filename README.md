# AgentLink Hermes Skills

A collection of skills for the [Hermes Agent](https://hermes-agent.nousresearch.com/). Each skill lives in its own directory under `skills/` and is defined by a `SKILL.md` file that Hermes loads at runtime.

## Adding a skill

1. Create a directory under `skills/<skill-name>/`.
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`, `version`, `author`, and optional `metadata.hermes` tags).
3. Place any supporting scripts or assets alongside it.

## Skills

### [botcha.ai](skills/botcha.ai/SKILL.md)

**Category:** auth | **Tags:** auth, botcha.ai | **Version:** 1.0.0

Obtains a [Botcha.ai](https://botcha.ai) JWT access token by solving proof-of-agent challenges. Handles all four challenge types:

| Challenge | Mechanism | Time limit |
|-----------|-----------|-----------|
| Speed | SHA-256 hash | 500 ms |
| Reasoning | Language / logic questions | 30 s |
| Hybrid | Speed + Reasoning combined | 35 s |
| Compute | Prime generation + hashing | 3–10 s |

**Inputs:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `app_id` | yes | Your Botcha.ai application ID |
| `audience` | no | Resource server URL — scopes the token |
| `refresh_token` | no | Existing refresh token — skips the challenge entirely |

**Output:** JSON block with `access_token`, `refresh_token`, `challenge_type`, and `strategy_notes`.
