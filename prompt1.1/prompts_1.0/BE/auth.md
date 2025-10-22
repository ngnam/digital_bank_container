# BE auth prompt

Flows:
- **Login/password** → access + refresh tokens; optional biometric binding after success.
- **Login/OTP** → request, verify; throttle requests; cooldown on failures.
- **Refresh** → rotate access; refresh revocation on device unbind or risk events.
- **Device trust** → bind on successful auth; list, remove; enforce per-user max devices.

API contracts:
- POST `/api/v1/auth/login` `{ identity, password }` → `{ accessToken, refreshToken, expiresIn }`
- POST `/api/v1/auth/login/otp` `{ identity }` → `{ challengeId, channel }`
- POST `/api/v1/auth/login/otp/verify` `{ challengeId, otp }` → tokens
- POST `/api/v1/auth/token/refresh` `{ refreshToken }` → new tokens
- POST `/api/v1/auth/register` `{ phone/email, password, profile, ekycToken }` → `{ userId }`
- POST `/api/v1/auth/device/bind` `{ deviceId, platform, model }` → `{ deviceId }`
- GET `/api/v1/auth/device` → list
- DELETE `/api/v1/auth/device/{id}` → `{ success: true }`

Security:
- **RS256 JWT** with `kid` header from JWK; `iss`, `aud`, `sub`, `roles`
- **Refresh tokens** stored server-side (revocable), rotate on each refresh
- **Rate limiting**: login 10/5m, OTP 5/5m; lockout policy after threshold
- **Risk signals**: `X-Device-Id`, IP, user agent; trigger step-up auth if anomalous
- **CSRF**: Not required for token APIs; avoid cookies

FE responsibilities:
- Store tokens in **secure storage**
- Use **biometric** as local step-up; never send secrets to BE
- Handle **429** and lockout messages gracefully
- Use **idempotency key** for sensitive POSTs (optional for auth endpoints)

