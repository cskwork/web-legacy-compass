# Web flow record — {{SLUG}}

- Date: {{DATE}}
- Status: `investigating | implementing | verifying | complete`
- Work type: `bug | feature | refactor-support`
- Environment:
- Entry URL:
- User role / tenant:
- Owner:
- Browser evidence tool:
- Trace / HAR / evidence location:

## 1. Goal and boundaries

### User-observed symptom or desired outcome

<!-- State what the user sees or needs, not the presumed root cause. -->

### Expected behavior

### Safety constraints

- Destructive actions authorized: `no | scoped approval: ...`
- Production writes authorized: `no | scoped approval: ...`
- Sensitive fields requiring redaction:

### Evidence access

| Source | Available | Scope / location | Limitation |
|---|---|---|---|
| Runnable web app |  |  |  |
| Authenticated role/state |  |  |  |
| Frontend source |  |  |  |
| Backend source |  |  |  |
| Browser network/trace |  |  |  |
| Frontend console |  |  |  |
| Backend logs/APM |  |  |  |
| DB schema/read access |  |  |  |
| Approved production query |  |  |  |
| API docs/tests |  |  |  |

## 2. Reproduction

### Starting state

| Item | Value | Evidence level / pointer |
|---|---|---|
| URL and route parameters |  |  |
| Selected entity / business key |  |  |
| Relevant visible state |  |  |
| Relevant client/store state |  |  |
| Relevant storage/cookie state |  |  |
| Relevant database before state |  |  |
| Pre-existing console/backend errors |  |  |

### Exact replay steps

1. 
2. 
3. 

## 3. Canonical flow sequence

Use one row per user action or meaningful automatic trigger. Put multiple ordered requests in the same row or reference the API table.

| Seq | User action / trigger | UI or client state before | Ordered request(s) | Result / state transition | Evidence |
|---|---|---|---|---|---|
| S01 |  |  |  |  |  |

## 4. API request and response map

Record only important payload/response fields. Redact authorization, cookies, tokens, passwords, secrets, and unnecessary personal data.

| Request ID | Seq | Method + endpoint | Trigger | Important request fields | Important response fields | Status / error | Correlation ID | Evidence / source entry |
|---|---|---|---|---|---|---|---|---|
| S01-R1 | S01 |  |  |  |  |  |  |  |

### Request relationships

| Request ID | Relationship | Related request | Meaning / evidence |
|---|---|---|---|
|  | `redirect | retry | poll | duplicate | preflight | follow-up | background` |  |  |

## 5. Client-state transitions

| Seq | State/store/cache | Before | Trigger or response | Intermediate / race behavior | After | Code pointer | Evidence level |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## 6. Backend business path

| Request ID | Entry point | Validation / branch | Service or domain rule | Transaction boundary | Exception / response mapping | Code evidence |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## 7. Data reads, writes, and side effects

Operation notation: `R`, `I`, `U`, `D`, `SD`, `E`, `C`, `A`.

| Request ID | Op | Table / entity / dependency | Key, predicate, join, or ordering | Columns read or written | Before → after | Transaction / side effects | Evidence level + pointer |
|---|---|---|---|---|---|---|---|
|  | R |  |  |  |  |  |  |

### Safe verification queries

```sql
-- Read-only, parameterized, narrow-scope queries only.
```

## 8. Logs and exceptions

| Seq / Request ID | Layer | Type / code | Log or exception summary | Business meaning | Correlation | Transaction outcome | Evidence pointer |
|---|---|---|---|---|---|---|---|
|  | frontend |  |  |  |  |  |  |
|  | backend-business |  |  |  |  |  |  |
|  | backend-technical |  |  |  |  |  |  |

### Observability gaps

| Gap | Diagnosis impact | Minimal safe logging/correlation change | Keep after fix? |
|---|---|---|---|
|  |  |  |  |

## 9. Current versus expected chain

| Seq | Verified current behavior | Expected / desired behavior | First wrong here? | Evidence level |
|---|---|---|---|---|
|  |  |  |  |  |

## 10. Root cause or feature delta

### Observed facts

1. 

### Inference

### Earliest divergence

### Disproof check

### Working comparison case

### Alternatives rejected

| Alternative | Why plausible | Evidence that rejects or deprioritizes it |
|---|---|---|
|  |  |  |

## 11. Implementation map

| Area | Current behavior | Minimal change | Files / symbols | Contract or compatibility risk | Test |
|---|---|---|---|---|---|
| Frontend |  |  |  |  |  |
| API/backend |  |  |  |  |  |
| Data/schema |  |  |  |  |  |
| Logging/observability |  |  |  |  |  |

## 12. Verification

### Automated checks

| Command / test | Result | Evidence |
|---|---|---|
|  |  |  |

### Browser replay comparison

| Verification item | Before | After | Pass criteria | Result / evidence |
|---|---|---|---|---|
| User-visible outcome |  |  |  |  |
| Request count/order |  |  |  |  |
| Important payload fields |  |  |  |  |
| Important response fields |  |  |  |  |
| Client state/render |  |  |  |  |
| Frontend console |  |  |  |  |
| Backend business exceptions |  |  |  |  |
| DB rows/columns |  |  |  |  |
| Event/cache/audit/downstream effects |  |  |  |  |
| Duplicate/retry/idempotency behavior |  |  |  |  |

## 13. Changed files and final risks

### Changed files

| File | Reason |
|---|---|
|  |  |

### Remaining assumptions and unavailable evidence

| Item | Label | Risk | Follow-up evidence |
|---|---|---|---|
|  | `assumed | unavailable | code inferred` |  |  |

### Final completion gate

- [ ] Every user action maps to ordered requests or explicitly to no request.
- [ ] Important payload/response fields are captured and secrets are redacted.
- [ ] Relevant client-state changes are mapped.
- [ ] Frontend console and backend business/technical exception evidence are separated.
- [ ] Selection reads, writes, transactions, and side effects are mapped or marked unavailable.
- [ ] The earliest divergence is evidenced and has a disproof check.
- [ ] Implementation is minimal and regression-tested.
- [ ] The exact browser flow was replayed after the change.
- [ ] Before/after evidence proves the desired behavior.
- [ ] This record reflects the final implementation.
