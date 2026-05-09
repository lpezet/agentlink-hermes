# AgentLink Hermes Skills

A collection of skills for the [Hermes Agent](https://hermes-agent.nousresearch.com/). Each skill lives in its own directory under `skills/` and is defined by a `SKILL.md` file that Hermes loads at runtime.

## Installation

1. Add tap: `hermes skills tap add lpezet/agentlink-hermes`, or using the skill `/skills tap add lpezet/agentlink-hermes`.
1. Install skill: `hermes skills install lpezet/agentlink-hermes/[skill]`, or using the skill `/skills install lpezet/agentlink-hermes/[skill]`.

For example, from command line:

```bash
hermes skills tap add lpezet/agentlink-hermes && hermes skills install lpezet/agentlink-hermes/botcha.ai
```

Or within Hermes:

```bash
/skills tap add lpezet/agentlink-hermes
/skills install lpezet/agentlink-hermes/botcha.ai
/reset
```

## Skills

### [botcha.ai](skills/botcha.ai/SKILL.md)

**Category:** auth | **Tags:** auth, botcha.ai | **Version:** 1.0.0

Obtains a [Botcha.ai](https://botcha.ai) JWT access token by solving proof-of-agent challenges. Handles all four challenge types:

| Challenge | Mechanism                  | Time limit |
| --------- | -------------------------- | ---------- |
| Speed     | SHA-256 hash               | 500 ms     |
| Reasoning | Language / logic questions | 30 s       |
| Hybrid    | Speed + Reasoning combined | 35 s       |
| Compute   | Prime generation + hashing | 3–10 s     |

**Inputs:**

| Parameter       | Required | Description                                           |
| --------------- | -------- | ----------------------------------------------------- |
| `app_id`        | yes      | Your Botcha.ai application ID                         |
| `audience`      | no       | Resource server URL — scopes the token                |
| `refresh_token` | no       | Existing refresh token — skips the challenge entirely |

**Output:** JSON block with `access_token`, `refresh_token`, `challenge_type`, and `strategy_notes`.
