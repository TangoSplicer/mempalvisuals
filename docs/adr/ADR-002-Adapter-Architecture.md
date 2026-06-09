# ADR 002: Adapter Architecture for MemPalace Engine Integration

## Context
MemPalace is an authoritative, terminal-centric engine. The Flutter frontend must not replicate its logic, but rather serve as a visual projection. The communication method between the Flutter app and the MemPalace engine may change depending on the platform (e.g., FFI on desktop, Process execution, or REST API).

## Alternatives Considered
- Direct SQLite bindings to MemPalace DB: Rejected. Bypasses the engine's logic and risks data corruption.
- FFI exclusively: Rejected. May limit Web (PWA) compatibility or complicate initial Android/Termux development.

## Decision
We implement a strict **Adapter Pattern** (`IMemPalaceAdapter`). The frontend application layer will only depend on this interface. 

## Consequences
- Requires mapping raw data maps from the adapter to strongly-typed Freezed models in the repository layer.
- Enables the immediate creation of a `MockMemPalaceAdapter` to unblock UI development (Phase 3+) without requiring a compiled core engine on the mobile device.
