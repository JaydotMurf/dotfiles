# Fix: keywords-everywhere MCP connector missing

_Diagnosed 2026-07-13. Status: action needed (account-side)._

## Symptom
`keywords-everywhere` no longer appears in the MCP server list, even inside
`~/dev/portfolio` and its subdirectories.

## Root cause
It is **not** a local config problem. `keywords-everywhere` is a **claude.ai
cloud connector**, not a locally-registered MCP server, and it has been
**removed from the claude.ai account entirely** — not merely disabled.

Evidence: in a `~/dev/portfolio` session the connector list shows other
claude.ai connectors both connected (Open Brain, Google Calendar) and disabled
(Gmail, Google Drive, Ideabrowser, Notion). A *disabled* connector still
appears in the list. `keywords-everywhere` is **absent**, which means it was
disconnected/removed account-side, not toggled off.

Local config is already correct and needs no change:
- The `claude()` wrapper in `zsh/.zshrc` correctly enables claude.ai connectors
  in `~/dev/portfolio` and `~/dev/chief-of-staff` (connectors *do* load there).
- `~/.claude/settings.json` line ~51 grants the `mcp__keywords-everywhere`
  permission — but that only allows the tool; it does not register the server.
- Nothing in dotfiles / `.claude.json` / `.zsh_modules` registers the server,
  so no uncommitted file could restore it.

Also noticed: the `.zshrc` connector comment was stale — `Gamma` is gone and
`Notion` is new. Comment updated in the same change.

## Fix (do this on claude.ai, not this machine)
1. Open **claude.ai → Settings → Connectors**.
2. Find `keywords-everywhere`:
   - If present but disconnected → reconnect / re-authenticate.
   - If gone → **Add custom connector** with its MCP server URL + API key.
3. Before re-adding, confirm the **keywordseverywhere.com API key is still
   valid** (a lapsed key/subscription can cause auto-removal).
4. Restart Claude Code from `~/dev/portfolio` and confirm it shows in `/mcp`.

## Open item
~~The MCP server URL/endpoint is not stored anywhere on this machine.~~
Resolved 2026-07-17 from the official docs (keywordseverywhere.com/mcp.html):

- **Server URL:** `https://mcp.keywordseverywhere.com/mcp`
- **Auth:** OAuth-style — when adding the connector you're prompted to sign in
  with the Keywords Everywhere API key; token refresh is automatic after that.
- **Prerequisites:** a valid API key and a paid plan with credits (any plan,
  Bronze up; no separate MCP fee — uses the same credits as the extension/API).
  A lapsed plan is consistent with the connector's silent account-side removal.

Remaining action is unchanged and account-side: add it at claude.ai →
Settings → Connectors with the URL above, then verify in `/mcp` from
`~/dev/portfolio`.
