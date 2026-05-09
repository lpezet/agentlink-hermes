# AgentLink Skills

A collection of skills compatible with both [Claude Code](https://claude.ai/code)
and [Hermes Agent](https://hermes-agent.nousresearch.com/). Each skill lives in
its own directory under `skills/` and is defined by a `SKILL.md` file loaded at
runtime.

## Installation

### Claude Code

Add the marketplace and install the skill:

```bash
/plugin marketplace add github:lpezet/agentlink-skills
/plugin install botcha-ai@agentlink-skills
```

Or add it once to your project settings (`.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": ["github:lpezet/agentlink-skills"]
}
```

Then install any skill with `/plugin install <skill-name>@agentlink-skills`.

### Hermes Agent

From the command line:

```bash
hermes skills tap add lpezet/agentlink-skills && hermes skills install lpezet/agentlink-skills/botcha-ai
```

Or within Hermes:

```bash
/skills tap add lpezet/agentlink-skills
/skills install lpezet/agentlink-skills/botcha-ai
/reset
```

## Skills

### [botcha-ai](skills/botcha-ai/SKILL.md)

**Category:** auth | **Tags:** auth, botcha.ai | **Version:** 2.0.0

Obtains a [Botcha.ai](https://botcha.ai) JWT access token for an AI agent.
Manages the full identity lifecycle: first-run TAP registration (Ed25519 keypair
generation), fast keypair challenge-response auth on subsequent runs, and
challenge-solving fallback for unauthenticated contexts.

| Challenge | Mechanism                  | Time limit |
| --------- | -------------------------- | ---------- |
| Speed     | SHA-256 hash               | 500 ms     |
| Reasoning | Language / logic questions | 30 s       |
| Hybrid    | Speed + Reasoning combined | 35 s       |
| Compute   | Prime generation + hashing | 3–10 s     |

**Inputs:**

| Parameter  | Required | Description                                    |
| ---------- | -------- | ---------------------------------------------- |
| `app_id`   | yes      | Your Botcha.ai application ID                  |
| `audience` | no       | Resource server URL — scopes the token         |

**Output:** JSON block with `access_token`, `refresh_token`, `auth_method`,
`agent_id` (on first registration), and `strategy_notes`.
