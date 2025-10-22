# BE foundation prompt

- **Goal:** Establish consistent API contracts, error models, and environments for mobile FE integration.
- **API base:** /api/v1/
- **Error model:** RFC7807 Problem+JSON (`type`, `title`, `status`, `detail`, `instance`)
- **Auth:** Bearer JWT (RS256), `Authorization: Bearer <token>`
- **Tracing:** Include `X-Request-Id` echoing, FE should attach it per request.
- **Pagination:** Query `page`, `size`, `sort`; response `items`, `total`, `page`, `size`.
- **Rate limiting:** FE must handle 429 with backoff and user feedback.
- **Idempotency:** For POST transactions, FE must send `X-Idempotency-Key` (UUID v4).
- **Security headers:** FE sets `X-Device-Id`, `X-App-Version`, `X-Platform` for risk signals.
- **Env:** Local dev uses SQLite; prod uses Postgres; FE toggles base URL via env.

Checklist FE:
- **DI & theming** ready
- **Secure HTTP client** with TLS pinning (if applicable), timeouts, retries for 5xx only
- **Global interceptors** for auth, request-id, idempotency
- **Unified error handler** for Problem+JSON
- **Logging** of non-PII metadata only
