# Report template

Fill this in. Keep the headings so the developer (and any agent that fixes things later) can find
their way. Short sentences. Every finding has a scenario.

```markdown
# Robux Audit – <game name>

Date: <date> · Read-only audit. Nothing was edited, committed or published.

## Verdict

**<Safe to sell | Safe to sell with these fixes | Not safe to sell yet>.** <2–4 sentences: what
holds up (e.g. receipts only say granted after saving, retries never double-grant) and where the
problems are.>

How this was checked: <what you traced, whether live ids were checked with GetProductInfo, what
you could not run>.

## 🔴 Must fix before selling

### 1. <short title saying what's wrong>
- **Kind:** less | free | policy
- **Where:** `path/File.luau:123`
- **Scenario:** <a real player or a hacked client does X → they are charged Y and get Z>.
- **Fix:** <the suggested fix>. <If the obvious fix is farmable or harmful, say why and give the
  safer one.>

## 🟡 Should fix

### N. <title>
- **Kind:** less | more | free | policy
- **Where:** …
- **Scenario:** …
- **Fix:** …

(Decisions the developer has to make, like policy grey areas, go here as "Decide:" items.)

## 🟢 Fine (traced and working)

- **<area>** (`file:line`): <what you checked and why it holds>. ✅

## Not verified

- <what you couldn't check and why: no Studio, no live purchase, an API behavior you can't
  confirm>.

## All items

| Item | Kind | R$ | Gives | Status |
|---|---|---|---|---|
| <name> | Product / Pass | <price> | <what the code grants> | ✅ / ⚠️ #n / ❌ #n |

## Fix order (quick wins first)

1. <copy fixes, flags: minutes>
2. …
```
