---
afx: true
type: JOURNAL
status: Living
tags: [auth, security, mvp]
---

# User Authentication - Session Journal

<!-- prefix: UA -->

## Captures

<!-- Quick notes during active sessions. Clear after recording. -->

## Discussions

<!-- Permanent discussion records with IDs -->

### UA-D001 - Architecture Planning

`status:closed` `2026-03-09T00:00:00.000Z` `[architecture, planning]`

**Context**: Initial design session for user authentication feature
**Summary**: Decided on JWT-based auth with access/refresh token pattern. Considered session cookies but JWT is better for future mobile app support. Auth service uses factory pattern for testability.
**Progress**:
  - [x] Reviewed auth strategies (JWT vs session cookies)
  - [x] Drafted data model for User and RefreshToken
  - [x] Defined API surface (register, login, refresh, logout)
  - [x] Created ADR 0001 for auth strategy decision
**Decisions**: JWT with RS256 signing, bcrypt cost factor 12, refresh token rotation
**Related Files**: spec.md, design.md, research/0001-auth-strategy.md
**Participants**: @rix

### UA-D002 - Token Refresh Edge Cases

`status:active` `2026-03-13T00:00:00.000Z` `[security, edge-cases]`

**Context**: During login form implementation, discovered edge cases in token refresh flow
**Summary**: The silent refresh mechanism needs to handle several edge cases: concurrent requests during refresh, network failures mid-refresh, and the race condition where multiple tabs trigger refresh simultaneously. Currently investigating the best approach.
**Progress**:
  - [x] Identified concurrent refresh race condition
  - [x] Researched mutex/lock patterns for client-side refresh
  - [ ] Implement request queuing during token refresh
  - [ ] Add retry logic for network failures
**Decisions**: Will use a promise-based lock to prevent concurrent refreshes
**Related Files**: auth.service.ts, jwt.ts
**Participants**: @rix

### UA-D003 - Rate Limiting Dependency

`status:blocked` `2026-03-14T00:00:00.000Z` `[security, infrastructure]`

**Context**: Rate limiting for auth endpoints requires a shared Redis instance
**Summary**: The rate limiting middleware for registration and login endpoints needs a Redis backend for distributed rate limiting across multiple server instances. DevOps team hasn't provisioned the Redis instance yet. Blocked until infrastructure is ready.
**Progress**:
  - [x] Designed rate limiting strategy (sliding window, 5 req/min for register, 10 req/min for login)
  - [ ] Waiting for Redis instance provisioning
  - [ ] Implement rate limiting middleware
  - [ ] Add rate limit headers to responses
**Decisions**: Sliding window algorithm chosen over fixed window for smoother rate limiting
**Related Files**: tasks.md#41-security-hardening
**Participants**: @rix, @devops-lead
