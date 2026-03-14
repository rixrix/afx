---
name: afx-security-audit
description: Conduct structured security audits — build threat models, review code for vulnerabilities, assess dependency risks, and produce remediation reports with priority rankings
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "security,audit,threat-modeling,vulnerability,remediation"
---

# AFX Security Audit

A structured security audit workflow that traces findings back to spec requirements and design decisions.

## Activation

Use this skill when you need to:

- Run a structured security audit — _"Run a security audit on this feature"_
- Perform threat modeling — _"Help me threat model this"_
- Get hardening recommendations — _"What should I harden?"_

## Instructions

### Audit Workflow

1. **Scope** — identify the feature boundary from `docs/specs/{feature}/spec.md`
2. **Threat Model** — enumerate threats per component (authentication, data flow, APIs)
3. **Review** — check code against known vulnerability patterns
4. **Report** — document findings with severity, location, and remediation

### Audit Report Format

For each finding, document:

```markdown
### Finding: {title}

- **Severity**: Critical / High / Medium / Low
- **Category**: OWASP A01–A10
- **Location**: `path/to/file.ts:line`
- **Spec Reference**: @see docs/specs/{feature}/spec.md#NFR-{n}
- **Description**: {what the vulnerability is}
- **Remediation**: {how to fix it}
- **Verification**: {how to confirm it's fixed}
```

### Security Checklist

- [ ] Authentication: tokens expire, sessions invalidated on logout
- [ ] Authorization: role checks on every route, deny by default
- [ ] Input validation: all user input sanitized at system boundary
- [ ] Data protection: secrets in env vars, PII encrypted at rest
- [ ] Dependencies: no known CVEs, lockfile committed
- [ ] Error handling: no stack traces in production, generic error messages
- [ ] Logging: audit trail for sensitive operations, no credentials in logs

### AFX Integration

- Link findings to spec NFR requirements with `@see` annotations
<!-- @afx:provider-commands -->
- Use `/afx-check path` to trace data flow for attack surface analysis
<!-- @afx:/provider-commands -->
- Record audit results in `docs/specs/{feature}/journal.md`
- Follow two-stage verification: agent flags issues, human validates fixes

## Output

Always end your response with:
> AFX skill: `afx-security-audit`
