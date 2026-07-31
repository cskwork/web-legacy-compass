# Browser tool routing

Research date: 2026-07-31

## Recommendation

Use two core tools:

1. **Playwright CLI — default capture and replay tool**
2. **Chrome DevTools MCP — deep inspection and escalation tool**

The recommendation optimizes for compact agent context, deterministic automation, ordered request inspection, browser-state access, console evidence, and the ability to escalate to exact DevTools data.

Do not run multiple agents against the same mutable browser session. One browser owner captures the canonical evidence; other agents analyze exported evidence and source code.

## Decision table

| Criterion | Playwright CLI | Chrome DevTools MCP | Ego Lite | agent-browser |
|---|---|---|---|---|
| Primary fit | Compact scripted reproduction and trace | Exact live DevTools inspection | Human/agent shared browser with inherited login | Compact browser automation |
| Ordered network list | First-class `requests` command | First-class network-request tools | Possible through raw CDP/event handling | First-class request log/HAR, with current caveats |
| Request detail | `request <index>` | Exact request/response detail and bodies | Custom CDP work | Request detail/HAR |
| Console evidence | First-class `console` command and traces | Console list/detail with stack/source information | Event/CDP based | Console command/raw CDP args |
| Browser storage/state | Cookies, local/session storage, saved state | Live JS and DevTools inspection | Inherits real login state; isolated Spaces | State and storage commands |
| Agent context cost | Lowest of the four for normal flows | Higher tool-schema/output cost; use selectively | Compact snapshots, but custom capture logic adds work | Compact snapshots |
| Cross-navigation inspection | Trace and request history; attach/replay options | Preserved requests/messages across navigations | Depends on custom CDP capture | Navigation/document capture has reported gaps |
| Parallel-session confidence | Named sessions; still keep one owner per session | Separate Chrome profiles/targets required | Strong isolated-space concept | Reported cross-session interference issue |
| Portability/maturity for this task | Recommended default | Recommended escalation | Useful optional fallback; current quick-start is Mac-first | Useful optional fallback, not canonical capture |

### Why Playwright CLI is first

Playwright CLI is designed for coding-agent use and compact output. It gives the agent a small command vocabulary for browser actions, ordered requests, individual request inspection, console messages, traces, screenshots, cookies, local storage, session storage, and saved authentication state. Named sessions make repeated flows reproducible without forcing the full MCP schema into every turn.

Use it for:

- normal feature reproduction;
- deterministic bug replay;
- capturing request order and important payloads;
- collecting console output and browser storage;
- saving trace artifacts for later review;
- regression replay after implementation.

### Why Chrome DevTools MCP is second

Chrome DevTools MCP exposes the browser's live DevTools model. It is the escalation path when the compact CLI evidence is not enough, particularly for exact request/response bodies, preserved requests across navigation, source-mapped console details, live JavaScript evaluation, service workers, performance traces, or a browser state that is difficult to recreate.

Use it selectively because loading and invoking broad MCP tools generally consumes more agent context than a narrow CLI command sequence.

### Why Ego Lite is optional, not core

Ego Lite is attractive when the user must share a logged-in browser with an agent or when isolated browser Spaces materially simplify parallel work. It exposes compact snapshots and raw CDP, but the legacy-flow evidence required here is assembled through lower-level CDP/event operations rather than a dedicated, standardized request-inspection workflow. Its current public quick-start is also Mac-oriented.

Use it as an environment bridge when inherited login state is the hard constraint, not as the canonical evidence format.

### Why agent-browser is optional, not core

agent-browser offers compact snapshots, network commands, HAR export, console access, storage, and state management. However, current project issues report incomplete capture for some full-page navigation/redirect/form-submission requests and session interference when multiple agents run concurrently. Those gaps are material for redirect-heavy authentication and older form-based applications.

Use it only when already standardized in the repository and validate that navigation/document requests and session isolation work for the target flow.

## Playwright CLI operating sequence

Use a stable session name derived from the flow slug.

```bash
# Open visibly when user observation or login is relevant.
playwright-cli -s=<flow> open <url> --headed

# Begin before the first user action.
playwright-cli -s=<flow> tracing-start

# Inspect baseline state.
playwright-cli -s=<flow> console debug
playwright-cli -s=<flow> cookie-list
playwright-cli -s=<flow> localstorage-list
playwright-cli -s=<flow> sessionstorage-list

# Perform one deliberate action at a time with normal CLI actions.
# After each action, inspect requests and relevant detail.
playwright-cli -s=<flow> requests
playwright-cli -s=<flow> request <index>
playwright-cli -s=<flow> console debug

# Finish and preserve trace evidence.
playwright-cli -s=<flow> tracing-stop
```

Additional operating rules:

- Start capture before navigation/action that may trigger redirects.
- Use snapshot/find/depth controls rather than dumping the entire page repeatedly.
- Use raw/compact output where available.
- Save and load authentication state only in an approved, ignored location.
- Treat cookies, storage state, and traces as sensitive artifacts.
- Attach to an existing Chrome/Edge session only when required; otherwise prefer an isolated profile for repeatability.
- Record request indexes and sequence IDs immediately because later background calls may shift the list.
- Capture the exact user input and starting entity/version needed to replay the flow.

## Chrome DevTools MCP escalation sequence

Tool names may vary slightly by installed version. Prefer this evidence order:

```text
take_snapshot
→ list_network_requests(includePreservedRequests=true)
→ get_network_request(reqid=<relevant request>)
→ list_console_messages(includePreservedMessages=true)
→ get_console_message(msgid=<relevant message>)
→ evaluate_script(...) only for a scoped state question
```

Escalate when any of these is true:

- exact request or response body is missing from compact capture;
- a navigation or redirect chain is ambiguous;
- requests/messages must be retained across navigation;
- console objects, stacks, or source maps are needed;
- service-worker/cache behavior may explain the divergence;
- a performance/race condition requires timeline evidence;
- the authenticated live Chrome session is the only reproducible state.

Security rules:

- Prefer a dedicated Chrome profile.
- Never expose a remote debugging port beyond the local trusted boundary.
- Do not copy credentials, cookies, authorization headers, or raw personal data into the Markdown record.
- Save full response bodies only when necessary, in a protected temporary location, and summarize/redact them in the record.

## Evidence normalization

Regardless of browser tool, normalize output into the same record fields:

| Field | Required representation |
|---|---|
| Sequence | Monotonic flow step such as `S01`, `S02` |
| Trigger | Exact user action, page lifecycle event, timer, retry, or background cause |
| Request | Method, normalized endpoint, chronological order |
| Important request data | Branch-driving identifiers, flags, filters, versions, idempotency/correlation values |
| Result | Status, important response fields, redirect, error, client transition |
| Evidence | Tool, request index/ID, timestamp, trace/log/file pointer |

## Primary sources

- Playwright CLI guide: https://playwright.dev/docs/getting-started-cli
- Playwright CLI repository: https://github.com/microsoft/playwright-cli
- Playwright trace viewer: https://playwright.dev/docs/trace-viewer
- Chrome DevTools MCP repository: https://github.com/ChromeDevTools/chrome-devtools-mcp
- Chrome DevTools MCP tool reference: https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md
- Ego Lite browser documentation: https://lite.ego.app/document/en/docs/ego-browser
- agent-browser navigation-capture issue: https://github.com/vercel-labs/agent-browser/issues/555
- agent-browser concurrent-session issue: https://github.com/vercel-labs/agent-browser/issues/326
