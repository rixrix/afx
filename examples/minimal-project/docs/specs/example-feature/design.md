---
afx: true
type: DESIGN
status: Draft
owner: '@your-handle'
version: 1.0
created: 2025-02-01T00:00:00.000Z
tags: [example]
---

# Example Feature - Technical Design

## Architecture Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   UI Layer  │ ──▶ │   Service   │ ──▶ │  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Data Model

### Entity: ExampleItem

| Field       | Type   | Required | Description      |
| ----------- | ------ | -------- | ---------------- |
| id          | string | Yes      | Unique identifier |
| name        | string | Yes      | Item name        |
| description | string | No       | Optional details |
| createdAt   | Date   | Yes      | Creation timestamp |

## API Design

### Create Item

```typescript
async function createItem(data: CreateItemInput): Promise<Item>
```

### Get Item

```typescript
async function getItem(id: string): Promise<Item | null>
```

## Service Layer

### ExampleService

Location: `src/services/example.service.ts`

```typescript
/**
 * Example service for demonstrating AFX patterns
 *
 * @see docs/specs/example-feature/design.md#service-layer
 * @see docs/specs/example-feature/tasks.md#21-create-service
 */
export function getExampleService() {
  return {
    createItem: async (data: CreateItemInput) => { /* ... */ },
    getItem: async (id: string) => { /* ... */ },
  };
}
```

## Error Handling

| Error Code | Description | HTTP Status |
| ---------- | ----------- | ----------- |
| NOT_FOUND  | Item not found | 404 |
| VALIDATION | Invalid input | 400 |
