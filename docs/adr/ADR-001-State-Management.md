# ADR 001: State Management Selection

## Context
The MemPalace visual frontend requires a robust state management solution capable of handling highly interactive, offline-first data, specifically complex knowledge graphs and spatial memory canvases. The solution must provide compile-time safety, strict dependency injection, and minimal boilerplate.

## Alternatives Considered
- **Provider:** Too permissive, prone to runtime `ProviderNotFoundException`.
- **Bloc:** High boilerplate, excessive verbosity for simple state synchronizations.
- **GetX:** Anti-pattern for Clean Architecture; couples UI tightly to business logic and routing.
- **Riverpod:** Offers compile-time safety, unidirectional data flow, and seamless integration with immutable state (Freezed).

## Decision
We will use **Riverpod** (specifically `flutter_riverpod` with `riverpod_generator`) for state management and dependency injection across the entire application.

## Consequences
- Requires running `build_runner` for code generation.
- Strict unidirectional data flow will be enforced.
- UI components will be completely decoupled from concrete implementation classes via Provider injection.
