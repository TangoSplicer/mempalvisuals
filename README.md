# MemPalace Visuals

A high-performance, offline-first visual frontend for the MemPalace knowledge graph system. Built with Flutter, Riverpod, and Drift.

## Core Features
* **Knowledge Graph Canvas:** Force-directed layout for navigating vast, interconnected concepts.
* **Memory Palace Builder:** Drag-and-drop spatial organization for locking abstract nodes into visual loci.
* **Timeline Explorer:** Horizontal chronological mapping of events and forensic discoveries.
* **Offline Discovery:** Instant, full-text search against the local SQLite database.

## Architecture
This project strictly enforces **Clean Architecture**:
* `Presentation`: Riverpod state management and Flutter views.
* `Application`: Physics engines and use-case orchestrators.
* `Domain`: Immutable `Freezed` entities (`Node`, `Edge`, `Palace`).
* `Infrastructure`: `Drift` persistence and core MemPalace adapters.

All dependency injection is handled via `riverpod_generator`.

## Development (Termux/Mobile Workflow)
This repository relies heavily on GitHub Actions for compilation and code generation. 
If developing locally on constrained hardware (like Termux):
1.  Write code and commit.
2.  Push to `main`.
3.  Allow the CI pipeline to run `build_runner` and `dart format`.
4.  Run `git pull` to sync the generated `.g.dart` files back to your local environment.
