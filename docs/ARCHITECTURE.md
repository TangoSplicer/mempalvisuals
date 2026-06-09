# MemPalace Architecture

This document defines the architectural constraints for the MemPalace visual frontend.

## Core Philosophy
1. **Separation of Concerns:** The UI is a projection of the data. Logic belongs in the Domain/Application layers.
2. **Offline-First:** All operations must function locally. Networking is a secondary enhancement.
3. **Adapter-Based:** The UI does not know if it is talking to a Mock, a CLI process, or an API.

## Layer Structure
- **Presentation:** Widgets, Screens, Providers (Riverpod).
- **Application:** Use Cases, Business Logic.
- **Domain:** Pure Entities, Repository Interfaces.
- **Infrastructure:** Adapters, Persistence (Drift/SQLite), Network (Dio).

## ADRs
- All architectural changes must include an ADR in `docs/adr/`.
