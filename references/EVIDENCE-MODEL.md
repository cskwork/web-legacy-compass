# Evidence model

Use one sequence vocabulary across browser actions, requests, logs, code paths, and database effects. This prevents separate frontend/backend/data narratives from drifting apart.

## Evidence levels

Label consequential claims with one of these levels:

| Level | Meaning | Acceptable basis |
|---|---|---|
| Runtime verified | Observed in the reproduced flow | Browser trace, console, backend log, approved query, trace/APM |
| Test verified | Reproduced by an automated test | Test output and inspected assertions |
| Code inferred | Strongly implied by executed code path | Source path, symbol, SQL/repository mapping |
| Assumed | Plausible but not verified | Explicit assumption plus disproof check |
| Unavailable | Required source cannot be accessed | Missing-access note and alternate evidence used |

Never present code inference as proof that a production row actually changed.

## Important payload rule

Do not copy payloads indiscriminately. Record a field when it does at least one of these:

- identifies the user, tenant, organization, entity, parent, version, or business date;
- selects a business branch, mode, type, status, feature flag, or permission path;
- controls filtering, sorting, pagination, joins, or the chosen record;
- supplies a value inserted or updated;
- participates in optimistic locking, idempotency, deduplication, retry, or correlation;
- explains validation, an exception, or a downstream side effect;
- differs between the working and failing case.

Usually omit presentation-only noise, unchanged defaults, generated UI metadata, analytics unrelated to the flow, and large blobs. Redact secrets and unnecessary personal data.

Represent important fields compactly:

```text
studentId=4832
lessonId=91
publishYn=N
version=7
filter.status=[ACTIVE,READY]
```

For nested payloads, use stable paths:

```text
selection.courseId
items[*].questionId
options.forceReplace
```

## API evidence

For each relevant request capture:

- chronological position and trigger;
- method and normalized path;
- query/path parameters and important body paths;
- content type and authentication mode without secret values;
- status and important response fields;
- redirect/retry/poll/duplicate relationship;
- correlation/request/trace ID;
- frontend call site and backend entry point;
- whether it is selection-only, validation, mutation, or side effect.

A request is relevant when it changes state, decides what the user sees, gates a later action, or explains the failure. Do not let analytics calls obscure the business sequence.

## Client-state evidence

Capture only state that can affect or explain behavior:

- route and route parameters;
- selected entity/tab/row;
- form values and validation state;
- store/query-cache keys and relevant values;
- pending/loading/disabled flags;
- optimistic update and rollback state;
- local/session storage keys involved in the branch;
- stale response suppression, cancellation, debounce, retry, or race behavior.

Map the transition explicitly:

```text
before → trigger → intermediate → response/error → after
```

Examples of meaningful divergences:

- stale selected ID survives a route change;
- a double click creates duplicate mutations;
- response B arrives before response A but A overwrites newer state;
- a successful mutation does not invalidate the list cache;
- frontend validation uses a different rule than the backend domain service.

## Database and data-state mapping

Map both **selection reads** and **state-changing writes**.

For each read, identify where applicable:

- table/view/entity;
- primary/foreign/business key;
- predicates, tenant scope, status filters, soft-delete filters;
- joins and ordering that determine the selected row;
- version/effective-date conditions;
- lock/isolation behavior;
- columns that drive the business branch.

For each write, identify:

- operation: insert, update, delete, soft delete, merge/upsert;
- target key and columns changed;
- before/after values when safely observable;
- transaction boundary and rollback behavior;
- optimistic-lock/version update;
- audit/history table;
- outbox/event/message;
- cache invalidation;
- file/object-store or downstream-service effect;
- idempotency/deduplication mechanism.

Preferred operation notation:

```text
R = read/selection
I = insert
U = update
D = delete
SD = soft delete
E = emitted event/message
C = cache change
A = audit/history write
```

Do not assume one endpoint equals one transaction. Legacy flows commonly contain multiple commits, stored procedures, triggers, asynchronous consumers, or frontend follow-up calls.

## Query validation

When database access is available:

- default to parameterized, read-only queries;
- query the narrowest keys and columns needed;
- include tenant and soft-delete predicates;
- capture before state before the mutating flow and after state immediately after;
- avoid broad production scans;
- do not execute mutation SQL unless explicitly authorized;
- note replica lag or eventual consistency when applicable.

When direct access is unavailable, triangulate with repository SQL, ORM mappings, migrations/schema, backend logs, API responses, tests/fixtures, and approved user-run queries. Mark the result `code inferred` or `unavailable`, not runtime verified.

## Frontend console evidence

Relevant evidence includes:

- uncaught errors and rejected promises;
- framework errors and source-mapped stacks;
- failed resource/network messages;
- business validation and state-transition messages;
- request/correlation IDs;
- retry, cancellation, debounce, and race indicators.

Quality standard for retained frontend logging:

```text
event=<stable-name>
flowStep=<Sxx>
requestId=<safe-id>
entityId=<safe-id>
state=<small business-relevant summary>
outcome=<success|rejected|failed|rolled-back>
```

Avoid dumping stores, entire payloads, tokens, cookies, or personal data. Temporary console debugging must be removed or converted into controlled structured logging before completion.

## Backend log and exception evidence

Separate two categories:

### Business exception

A known domain condition preventing or redirecting an operation, for example invalid state transition, insufficient entitlement, duplicate business key, version conflict, or unavailable publication state.

Capture:

- stable error code and exception type;
- business condition and safe contextual identifiers;
- actor/tenant/role when needed;
- state or status that caused the rejection;
- correlation/trace/request ID;
- transaction outcome: not started, committed, or rolled back;
- user-visible mapping and HTTP status;
- source symbol and log location.

### Technical exception

An unexpected infrastructure/programming failure, for example timeout, null dereference, connection failure, serialization error, or downstream outage.

Capture:

- exception type, cause chain, stack/source location;
- dependency and operation;
- correlation ID;
- retry/timeout/circuit-breaker behavior;
- transaction outcome and partial side effects;
- business operation interrupted.

Do not convert every technical failure into a generic business exception; doing so hides the cause and corrupts observability.

## Correlation strategy

Prefer an existing end-to-end trace or request ID. When absent and safe to change:

1. generate or propagate a request/correlation ID at the edge;
2. include it in frontend diagnostic context and response headers where appropriate;
3. bind it to backend structured logs;
4. include it in downstream calls/events when supported;
5. record it in the flow table, not sensitive payload data.

Do not introduce a new public contract solely for temporary debugging without evaluating compatibility.

## First-divergence test

For each candidate root cause, ask:

1. Is this the earliest incorrect state or only a later symptom?
2. Does the same evidence explain every observed symptom?
3. Is there a working comparison case that differs at this point?
4. Can one targeted test or replay disprove it?
5. Does the proposed fix alter only this divergence without masking another one?

## Required record tables

The template supplies six canonical tables:

1. flow sequence;
2. API details;
3. client state;
4. data operations;
5. logs and exceptions;
6. implementation and verification.

Keep rows compact and use links/code pointers for detail. The document is a navigation map, not a raw evidence dump.
