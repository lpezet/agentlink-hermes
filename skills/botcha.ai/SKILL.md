---
name: botcha.ai
description: |
  Obtains a Botcha.ai JWTaccess token by solving proof-of-agent challenges.
  Handles all four challenge types: Speed (SHA-256 hash, 500ms), Reasoning
  (language/logic questions, 30s), Hybrid (both combined, 35s), and Compute
  (prime generation + hashing, 3-10s).

  Call with:
    app_id: <your Botcha.ai app ID>            [required]
    audience: <resource server URL>            [optional — scopes the token]
    refresh_token: <existing refresh token>    [optional — skips challenge entirely]

  Returns a JSON block with access_token, refresh_token, challenge_type, and
  strategy_notes (populated on failure to guide instruction improvements).
version: 1.0.0
author: lpezet@gmail.com
metadata:
  hermes:
    tags: [auth, botcha.ai]
    category: auth
---

Your sole job: obtain a valid `access_token` and return it as a JSON block. Follow these steps exactly.

## CRITICAL RULES

1. **NEVER use curl for `/v1/token/verify` or `/v1/challenges/*/verify`.** Use only
   the pre-built Python scripts or a Python script you write. curl is allowed only for
   token refresh.
2. **Every** Python HTTP call to `api.botcha.ai` must include `?app_id=APP_ID_HERE`
   in the URL — both the challenge fetch and the verify.
3. If you receive `APP_REGISTRATION_REQUIRED`, it does NOT mean the app is unregistered.
   It means `app_id` was missing from that specific request. Retry on a fresh challenge
   with `?app_id=` in the verify URL.

---

## Fast path: token refresh

If the caller provided a `refresh_token`, skip all challenges and run:

```bash
curl -s -X POST "https://api.botcha.ai/v1/token/refresh?app_id=APP_ID_HERE" \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "REFRESH_TOKEN_HERE"}'
```

Parse `access_token` from the response. Emit the output block (Step 3). Stop.

---

## Step 1: Fetch and solve

If the pre-built script was located in Step 0, use it — preferred, handles everything
atomically. Include `AUDIENCE_HERE` as a second argument if the caller provided one:

```bash
python3 scripts/botcha_get_token.py APP_ID_HERE
```

**If `success: true`** → go to Step 3. Done.
**If `needs_reasoning: true`** → go to Step 2.
**If the script was not found** → use the manual flow below.

---

### Manual flow (when script is not available)

**1a. Fetch the challenge:**

```bash
curl -s "https://api.botcha.ai/v1/token?app_id=APP_ID_HERE"
```

Note `challenge.id` and `challenge.problems`.

**1b. Compute SHA-256 answers** (replace NUM1…NUM5 with the actual problem numbers):

```bash
python3 -c "
import hashlib, json
nums = [NUM1, NUM2, NUM3, NUM4, NUM5]
print(json.dumps([hashlib.sha256(str(n).encode()).hexdigest()[:8] for n in nums]))
"
```

**1c. Verify — use this Python command, NOT curl.** Replace the three placeholders:

```bash
python3 -c "
import json, http.client, ssl
c = http.client.HTTPSConnection('api.botcha.ai', context=ssl.create_default_context())
payload = json.dumps({'id': 'CHALLENGE_ID_HERE', 'answers': ANSWERS_ARRAY_HERE}).encode()
c.request('POST', '/v1/token/verify?app_id=APP_ID_HERE', payload, {'Content-Type': 'application/json'})
print(c.getresponse().read().decode())
c.close()
"
```

`CHALLENGE_ID_HERE` → the `challenge.id` from step 1a.
`ANSWERS_ARRAY_HERE` → the JSON array from step 1b, e.g. `["ab12cd34","ef56gh78"]`.
`APP_ID_HERE` → the caller's app_id.

**Never use curl for the verify step.**

---

## Step 2: Answer the reasoning questions (only when needs_reasoning: true)

The script output contains a `challenge` object with a `questions` array.
You have **30 seconds** from when the challenge was issued. Work quickly.

For each question, read the `id` and answer it inline using the strategies below.
Build: `{"<question_id>": "<answer>", ...}`

**By category:**

- **Analogy** (`A is to B as C is to ?`): identify the A→B relationship, apply to C.
- **Math / word problem**: extract the numbers and compute directly — no calculator needed.
- **Logic** (if/then, ordering, set membership): trace the conditions step by step.
- **Wordplay** (anagram, rhyme, letter pattern): work through it character by character.
- **Computer science** (complexity, data structures, algorithms): apply knowledge directly.
- **Pattern completion** (number or symbol sequences): find the rule, apply it to the next term.

If you see a category not listed above, answer your best guess and record the category
name in `strategy_notes` so the instructions can be extended.

Then submit using the located script path:

```bash
python3 scripts/botcha_verify_reasoning.py APP_ID_HERE CHALLENGE_ID TYPE '{"q-id-1":"answer1","q-id-2":"answer2"}'
```

For hybrid challenges, the answers JSON format is:

```json
{"speed_answers": [...], "reasoning_answers": {"q-id": "answer"}}
```

The script prints a result JSON. Go to Step 3.

---

## Step 3: Emit output

**Always emit this JSON block, even on failure.**

```json
{
  "success": true,
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 3600,
  "challenge_type": "speed|reasoning|hybrid|compute",
  "time_to_solve_ms": 175,
  "strategy_notes": "brief note — what worked, what was ambiguous"
}
```

On failure:

```json
{
  "success": false,
  "challenge_type": "...",
  "error": "...",
  "raw_challenge": "...",
  "raw_verify_response": "...",
  "strategy_notes": "be specific: what instruction was missing, what the question looked like, what you tried"
}
```

The `strategy_notes` and `raw_*` fields on failure are the most valuable output —
they are the signal for improving these instructions.
