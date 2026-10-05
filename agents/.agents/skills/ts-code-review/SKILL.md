---
name: ts-code-review
description: 'Review TypeScript code for enterprise quality. Use when reviewing TS/TSX diffs, PRs, files, or modules for TSDoc coverage, @example usage, TypeScript conventions, naming, readability, maintainability, extensibility, and performance. Triggers: "review TS", "code review typescript", "review this PR", "check TSDoc", "review diff".'
argument-hint: 'Files, folder, diff, or PR to review'
---
 
# TypeScript Code Review
 
Review TypeScript code against enterprise standards. Report findings first, then offer to fix them.
 
## When to Use
 
- Review a TypeScript diff, PR, file, or module.
- Audit TSDoc coverage and quality.
- Assess readability, maintainability, and extensibility before merge.
 
## Procedure
 
1. Identify scope: the changed files in a diff or PR, or the files the user named. Skip generated code, `dist/`, and lockfiles.
2. Read surrounding code and project config (`tsconfig*.json`, ESLint config) to learn local conventions. Local conventions take precedence over the checklist.
3. Check each file against the [Review Checklist](#review-checklist).
4. Report findings using the [Output Format](#output-format).
5. End with a short verdict: approve, approve with nits, or request changes.
6. Offer to fix findings and ask which severity groups to apply, for example Must Fix only or all groups. Do not edit any file until the user confirms.
 
## Review Checklist
 
### TSDoc
 
- Every exported function, class, method, type, interface, and constant must have TSDoc.
- TSDoc must be concise: a one-line summary, then `@param`, `@returns`, and `@throws` where applicable.
- TSDoc must describe intent and contract, not restate the signature.
- Public APIs with non-obvious usage should include an `@example`.
- Flag stale TSDoc that no longer matches the code.
 
### TypeScript Standards
 
- Do not use `any`. Use `unknown` with narrowing, generics, or precise types.
- Do not use non-null assertions (`!`) or unchecked casts (`as`) without a justifying comment.
- Exported functions must declare explicit return types.
- Every `Promise` must be awaited or returned; flag floating promises.
- Use `import type` for type-only imports.
- Flag code that relies on loose checks that `strict` compiler mode would reject.
- Prefer `readonly`, `as const`, and immutable data where mutation is not needed.
- Prefer discriminated unions over boolean flags or loose string types.
 
### Naming and Readability
 
- Names must state intent: `fetchUserById`, not `getData`; `isExpired`, not `flag`.
- Use `camelCase` for values, `PascalCase` for types and classes, and `UPPER_SNAKE_CASE` for true constants.
- Each function should have one responsibility. Flag functions that are long, deeply nested, or take many parameters; suggest an options object for many parameters.
- Prefer early returns over nested conditionals.
- Replace magic numbers and strings with named constants.
- Comments should explain why, not what.
 
### Clarity Over Cleverness
 
- Flag tricks that obscure intent: nested ternaries, comma operators, bitwise coercion such as `~~x`, unexplained `!!x` coercion, and dense one-liner chains.
- Prefer explicit code even when it is slightly longer.
- Flag error suppression (`@ts-ignore`, `eslint-disable`) without a stated reason.
 
### Maintainability and Extensibility
 
- Depend on abstractions such as interfaces at module boundaries.
- Flag duplicated or copy-pasted logic.
- Flag premature abstraction, such as helpers used only once.
- Keep the public API surface minimal; do not export internals.
- Errors must be typed or descriptive and must never be swallowed silently.
- New behavior must have tests; flag untested branches.
 
### Performance
 
Readability must not cost measurable performance. Flag these patterns:
 
- Sequential `await` in loops where `Promise.all` is safe.
- Repeated work inside loops, such as lookups, regex compilation, or allocations.
- O(n^2) searches where a `Map` or `Set` fits.
- Unbounded caches, listeners, or timers that can leak memory.
 
### Security
 
- Validate external input at system boundaries.
- Do not put secrets, tokens, or credentials in code or logs.
- Flag injection risks: SQL, shell, path traversal, and unsafe `eval`.
 
## Output Format
 
Group findings by severity and omit empty groups. Write one line per finding with the location, the problem, and the fix.
 
- Must Fix: bugs, security issues, `any`, missing TSDoc on public APIs, and swallowed errors.
- Should Fix: naming, readability, maintainability, and performance.
- Nit: style, optional `@example`, and minor wording.
 
```markdown
### Must Fix
 
- [src/user.ts](src/user.ts#L42): `any` return type - type as `Promise<User>`.
 
### Should Fix
 
- [src/user.ts](src/user.ts#L10): `getData` is vague - rename to `fetchUserById`.
 
### Nit
 
- [src/user.ts](src/user.ts#L5): missing `@example` on public `parseUser`.
 
### Verdict
 
Request changes: 1 must fix, 1 should fix, 1 nit.
```