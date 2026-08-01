---
name: web-legacy-compass
description: Trace real legacy-web user flows before changing code. Use when request order and DB reads/writes must be correlated.
---

# Web Legacy Compass

## Prime directive

**Observe the real user flow before modifying code.**

Do not start implementation until the current behavior is represented by evidence, or every unavailable evidence source is explicitly marked. At minimum, establish:

1. the ordered user actions and browser requests;
2. the request fields that select or change business behavior;
3. the relevant client-state transitions;
4. the frontend console and backend business-exception evidence;
5. the database reads used for selection and the writes or side effects caused by the flow.

Create the investigation record immediately and update it throughout the work. Use the repository's existing documentation convention; otherwise create:

```text
docs/web-flows/YYYY-MM-DD-<feature-or-bug>.md
```

Start from `templates/FLOW-RECORD.md`.

## Operating constraints

- Prefer the smallest maintainable change that explains and fixes the observed divergence.
- Reproduce in the safest available environment. Default to read-only actions until mutation is necessary and authorized.
- Never trigger destructive actions, payments, messages, deletes, bulk changes, or production writes without explicit authorization.
- Never store passwords, cookies, tokens, authorization headers, secrets, or unnecessary personal data in the record.
- Record important payload fields, not indiscriminate full payload dumps.
- Distinguish **runtime verified**, **code inferred**, **assumed**, and **unavailable** evidence.
- Do not infer database behavior from endpoint names alone. Trace repository/query code or runtime data evidence.
- Do not treat a successful HTTP status as proof of correct business behavior.

## Workflow

### 1. Frame the flow and open the record

Write the target outcome, user role, environment, entry URL, known symptom or desired behavior, safety boundaries, and available evidence sources.

Inventory access without blocking progress:

- runnable application and authentication state;
- browser automation or inspection tool;
- frontend and backend source;
- frontend console output;
- backend application/business-exception logs;
- database schema, read replica, development database, or approved query execution;
- API documentation, traces, metrics, and correlation identifiers.

Mark missing access in the record and continue with the strongest available evidence.

### 2. Capture the baseline before the first action

Record the initial URL, visible state, user/tenant/role when relevant, selected entity, filters, browser storage relevant to the behavior, and any pre-existing console errors.

Start network and trace capture **before** reproducing the flow. Use the routing rules in `references/BROWSER-TOOL-ROUTING.md`.

### 3. Reproduce the exact user journey

Perform one deliberate action at a time. For each action:

1. note visible and client state before the action;
2. perform the action;
3. capture every resulting request in chronological order, including redirects, retries, polling, preflight, and background requests that affect interpretation;
4. inspect important request and response fields;
5. record the visible/client state after the action;
6. collect relevant console messages and correlation identifiers.

Use sequence numbers shared by all evidence tables. One user action may map to zero, one, or many requests.

### 4. Build the browser-to-data chain

Trace the complete path where evidence permits:

```text
user action
→ DOM event / handler
→ validation and client state/store
→ API client
→ gateway/controller
→ application/domain service
→ business rule or exception
→ transaction
→ repository/query
→ database reads/writes
→ event, cache, audit, or downstream side effect
→ response
→ client state/render
```

For every state-changing or selection-critical request, identify:

- the code entry points;
- the branch-driving request fields;
- the business rule and exception path;
- the tables/entities read to make the selection;
- the tables/entities inserted, updated, or deleted;
- transaction boundaries and secondary effects.

Use `references/EVIDENCE-MODEL.md` for payload, data, and log rules.

### 5. Parallelize analysis without corrupting browser state

For non-trivial flows, split independent code analysis after creating a shared reproduction packet. Use one browser owner only.

Recommended roles:

- **Browser owner:** reproduces the flow and owns the canonical request/console trace.
- **Frontend analyst:** traces event → validation/store → API client → response handling → render.
- **Backend analyst:** traces controller → service/domain rule → business exception → transaction → repository.
- **Data analyst:** maps queries, predicates, joins, tables, columns, keys, writes, locks, events, caches, and audit effects.
- **Adversarial reviewer:** tests whether the claimed first divergence and proposed change are actually supported.

Give each analyst the same sequence IDs, endpoint list, important payload fields, timestamps/correlation IDs, and scoped question. Tell subagents not to delegate recursively. The main agent must verify findings against source code or runtime evidence; do not merely concatenate reports.

When parallel agents are unavailable, perform the roles sequentially in the same order. See `references/SUBAGENT-PATTERN.md`.

### 6. Find the earliest meaningful divergence

For a bug, compare expected and observed behavior at each sequence step. Stop at the earliest point where one of these first becomes wrong:

- event or client input;
- request order, duplication, omission, or payload;
- server branch or business validation;
- database selection or mutation;
- response mapping;
- client state or rendering.

Later errors may be consequences, not root causes.

For a feature, describe the smallest delta from the verified current chain to the desired chain. Identify compatibility constraints for API contracts, legacy callers, schema, transactions, and logs.

### 7. Form a testable explanation

Write:

- **Observed fact:** directly supported by trace, log, code, test, or query.
- **Inference:** the explanation connecting facts.
- **Disproof check:** the evidence that would make the inference false.
- **Proposed change:** the smallest code/config/data-contract change addressing the first divergence.

Do not implement a hypothesis that has no practical disproof check.

### 8. Implement incrementally

Before changing behavior, add or preserve a failing regression test when feasible. Change only the files necessary for the verified chain.

Logging changes must improve future diagnosis rather than add noise:

- frontend logs should identify the user action, relevant client state transition, request/correlation ID, and business-validation branch;
- backend business exceptions should include a stable error code, business condition, safe entity/tenant/actor identifiers, correlation ID, and transaction outcome;
- technical exceptions should retain stack/cause information;
- never log secrets or raw sensitive payloads;
- remove temporary debug output or convert it to appropriately leveled structured logging.

Update the Markdown record when implementation changes the proposed flow or reveals that an earlier inference was wrong.

### 9. Replay the same flow

Run the same user journey using the same role, inputs, and starting state. Compare before and after:

- request count, order, method, endpoint, important payload fields, status, and important response fields;
- client state and rendered result;
- frontend console errors and business messages;
- backend business exceptions and transaction outcome;
- database rows, columns, side effects, and idempotency behavior;
- regression and adjacent tests.

A passing unit test alone does not complete a browser-observed legacy-web change.

### 10. Finalize the evidence record

The record must state:

- verified current flow;
- desired or corrected flow;
- first divergence and root-cause evidence;
- files and contracts changed;
- tests and exact replay performed;
- before/after evidence;
- remaining assumptions, unavailable evidence, and risks.

## Completion gate

Do not declare completion until all applicable statements are true:

- [ ] Each user action is mapped to its zero-or-more ordered requests.
- [ ] Redirects, retries, polling, duplicate calls, and background calls that affect behavior are accounted for.
- [ ] Important request and response fields are recorded and secrets are redacted.
- [ ] Relevant client-state transitions and console evidence are mapped to sequence IDs.
- [ ] Backend business exceptions and technical failures are separated and correlated to the flow.
- [ ] Every selection-critical database read and state-changing operation is mapped to code/runtime evidence or marked unavailable.
- [ ] Transaction boundaries and relevant cache/event/audit/downstream side effects are documented.
- [ ] Runtime-verified facts are distinguishable from code inference and assumptions.
- [ ] The earliest divergence is supported by evidence and has a disproof check.
- [ ] The implementation is minimal, regression-tested, and replayed through the actual browser flow.
- [ ] The final Markdown record matches the implemented behavior.

## Reference loading

Read only the reference needed for the current stage:

- browser selection and commands: `references/BROWSER-TOOL-ROUTING.md`
- payload, database, state, and logging evidence: `references/EVIDENCE-MODEL.md`
- parallel-agent handoff and verification: `references/SUBAGENT-PATTERN.md`
- investigation/output document: `templates/FLOW-RECORD.md`
