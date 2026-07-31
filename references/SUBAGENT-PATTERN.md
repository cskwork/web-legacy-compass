# Parallel-agent pattern

Browser-to-database tracing can consume substantial context. Parallelize independent source-code analysis, not control of the same browser session.

## Invariant

**Exactly one browser owner controls one mutable session.**

Multiple agents may inspect immutable exports, traces, screenshots, HAR files, request summaries, logs, and source code. They must not click, navigate, authenticate, or mutate the same session concurrently.

## Shared reproduction packet

The browser owner prepares this packet before parallel analysis:

```text
Goal or symptom:
Environment and user role:
Entry URL and starting state:
Safety limits:
Sequence table:
Relevant request list:
Important payload/response fields:
Console evidence:
Timestamps and correlation IDs:
Trace/HAR/log pointers:
Known working comparison, if any:
Open questions assigned by role:
```

Use stable sequence IDs such as `S01`, `S02`, and request IDs such as `S02-R1`. Every agent must reference these IDs.

## Recommended assignments

### Browser owner

Question:

> What exactly happened in the real user flow, in chronological order?

Outputs:

- canonical sequence and request tables;
- baseline and resulting visible/client state;
- request detail, console evidence, trace pointers;
- gaps requiring DevTools escalation;
- replay steps.

### Frontend analyst

Question:

> For sequence IDs `<scope>`, which frontend code turns the user action into these requests and then maps responses/errors into client state and rendering?

Trace:

```text
route/component
→ event handler
→ validation
→ store/query cache
→ API client/interceptor
→ request construction
→ response/error mapping
→ state/render
```

Output only source-backed findings with paths and symbols. Highlight request duplication, stale state, races, retries, cancellation, cache invalidation, and console logging gaps.

### Backend analyst

Question:

> For requests `<scope>`, which backend path selects the business branch, raises business exceptions, controls transactions, and calls persistence/downstream components?

Trace:

```text
edge/filter
→ controller/handler
→ DTO validation
→ application service
→ domain rule
→ transaction
→ repository/query
→ event/downstream
→ exception mapper/response
```

Output paths, symbols, branch conditions, transaction boundaries, exception codes, and correlation/logging behavior.

### Data analyst

Question:

> For requests `<scope>`, which tables/entities and exact predicates determine selection, and what rows/columns/side effects can change?

Output:

- R/I/U/D/SD/E/C/A operation map;
- keys, joins, filters, ordering, tenant/soft-delete/version conditions;
- before/after query suggestions;
- runtime-verified vs code-inferred labels;
- triggers, procedures, audit, outbox, cache, and eventual-consistency risks.

### Adversarial reviewer

Question:

> Does the evidence prove the claimed earliest divergence, or is the proposal solving a downstream symptom or already-solved problem?

Challenge:

- wrong flow or user role;
- missing redirect/retry/background request;
- frontend/backend contract mismatch;
- stale or wrong selected database row;
- hidden transaction/event/cache effect;
- unsafe logging or sensitive evidence;
- unnecessary refactor or compatibility break;
- verification that does not replay the real flow.

## Agent prompt contract

Each delegated prompt should contain:

```text
You are one scoped analyst. Do not control the browser and do not delegate further.
Use only the supplied sequence IDs and repository evidence.
Return:
1. findings;
2. evidence: file path + symbol/line or runtime pointer;
3. confidence label: runtime verified, test verified, code inferred, assumed, unavailable;
4. contradictions/gaps;
5. one disproof check per root-cause claim.
Do not propose unrelated refactoring.
```

## Main-agent merge procedure

The main agent must not paste reports together. Merge them as follows:

1. normalize every finding to a sequence/request ID;
2. reject findings without evidence pointers;
3. resolve frontend/backend/data contradictions by reopening primary evidence;
4. distinguish runtime facts from code inference;
5. identify the earliest shared divergence;
6. run the adversarial review;
7. update the canonical Markdown record;
8. derive the minimal implementation plan;
9. replay the browser flow after implementation.

## Parallelization boundary

Good parallel work:

- independent frontend, backend, and SQL/source tracing;
- searching separate modules for correlation/business exception behavior;
- reviewing tests and analogous flows;
- adversarial verification after a proposed root cause.

Bad parallel work:

- two agents clicking the same session;
- duplicate broad repository scans with no scoped question;
- agents independently redefining sequence IDs;
- recursive delegation;
- implementing competing fixes before evidence is merged;
- accepting majority agreement as proof.

## Small-flow fallback

For a one-request, single-module flow, do not create agent overhead. Perform the roles sequentially and preserve the same evidence labels and completion gate.
