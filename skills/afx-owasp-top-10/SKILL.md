# AFX OWASP Top 10

Security review checklist based on the OWASP Top 10, integrated with AFX spec-driven traceability.

## Activation

This skill activates when the user asks about:

- Security review or audit
- OWASP Top 10 compliance
- Vulnerability assessment
- Secure coding practices

## Instructions

### OWASP Top 10 Checklist

When reviewing code for security, check against all 10 categories:

1. **A01 Broken Access Control** — verify authorization on every endpoint, deny by default
2. **A02 Cryptographic Failures** — no plaintext secrets, proper key management, TLS everywhere
3. **A03 Injection** — parameterized queries, input validation, no string concatenation in queries
4. **A04 Insecure Design** — threat modeling, secure design patterns, defense in depth
5. **A05 Security Misconfiguration** — no default credentials, minimal permissions, hardened configs
6. **A06 Vulnerable Components** — check dependencies, known CVEs, update policy
7. **A07 Authentication Failures** — strong passwords, MFA, session management
8. **A08 Data Integrity Failures** — verify signatures, CI/CD security, serialization safety
9. **A09 Logging Failures** — audit trails, no sensitive data in logs, tamper-proof logging
10. **A10 SSRF** — validate URLs, allowlist outbound destinations, block internal network access

### AFX Integration

- Link findings to spec requirements with `@see` annotations:
```
@see docs/specs/{feature}/spec.md#NFR-{n}
```
- Add `FIXME @see` annotations for vulnerabilities found in code
<!-- @afx:provider-commands -->
- Use `/afx:check path` to trace data flow through the application
<!-- @afx:/provider-commands -->
- Document security decisions in `docs/specs/{feature}/journal.md`

### Severity Classification

- **Critical**: Remote code execution, authentication bypass, data exfiltration
- **High**: Privilege escalation, SQL injection, XSS with session theft
- **Medium**: Information disclosure, CSRF, insecure defaults
- **Low**: Missing headers, verbose errors, minor misconfigurations
