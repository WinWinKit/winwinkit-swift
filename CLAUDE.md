# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

WinWinKit Swift SDK — the official client for [WinWinKit](https://winwinkit.com) affiliates & referrals platform. Distributed as a Swift Package (`WinWinKit` library). Targets iOS 16+ / macOS 13+, Swift tools 6.0 with language mode v5.

## Commands

Build and test via Swift Package Manager:

```sh
swift build
swift test
swift test --filter WinWinKitTests.ReferralsTests/<testName>   # single test
```

Regenerate the OpenAPI client from the live spec at `https://api.winwinkit.com/openapi-yaml` (requires `openapi-generator` from openapi-generator.tech):

```sh
./openapi.generate
```

This script overwrites `Sources/WinWinKit/Generated/OpenAPI/` — do not hand-edit files under that directory. The script also reshuffles the generated tree into `Public/` (models/utils) and `Internal/` (requests, responses, API classes) and rewrites `open`/`public` visibility to `internal` on the Internal side so only models are exposed from the package.

Dependencies / references:
- https://openapi-generator.tech/
- https://openapi-generator.tech/docs/generators/swift5/

Formatting uses SwiftFormat; config in `.swiftformat`.

## Architecture

The SDK's single entry point is `Referrals` (`Sources/WinWinKit/Referrals.swift`), exposed as a configured singleton (`Referrals.configure(apiKey:)` → `Referrals.shared`). A `ReferralsDelegate` and `ReferralsObservableObject` sit next to it for callback- and SwiftUI-style consumers.

Layering (public → private):

1. **`Referrals`** — public façade. Holds the `UserService`, manages App Store `Transaction.updates` / `currentEntitlements` observation, and forwards state changes to the delegate / observable object. Errors surface as `ReferralsError`.
2. **`UserService`** (`Internal/Service`) — orchestrates all backend interactions for the current `appUserId`. Owns a `UserCacheType` for local persistence and talks to the backend only through the `Providers` bundle.
3. **Providers** (`Internal/Providers`) — thin wrappers (`UsersProvider`, `ClaimActionsProvider`, `RewardActionsProvider`, `AppStoreTransactionsProvider`) that call the generated OpenAPI request types. This is the seam between SDK logic and generated code; mocks in tests live at this layer.
4. **Generated OpenAPI client** (`Sources/WinWinKit/Generated/OpenAPI`) — split into `Public/Models` (exposed as part of the SDK's public surface, e.g. `ErrorObject`, user/reward models) and `Internal/` (request/response DTOs and `*API` classes). Never edit; re-run `./openapi.generate`.

Supporting pieces: `Cache/KeyValueCacheType` (public protocol, default-backed by `UserDefaults`) + `Internal/Cache/UserCache` for typed access, `Internal/Network/NetworkReachability`, `Internal/Logging/Logger` (wraps swift-log), `Internal/Utils/Atomic`, and `Internal/Extensions` for `ReferralsError` and `Date` helpers.

StoreKit integration: `Referrals` starts a `Transaction.updates` task and also walks `Transaction.currentEntitlements` on startup so previously-purchased transactions get registered with the backend exactly once (dedup via `UserCache.registeredAppStoreTransactionIds`). A public `syncTransactions()` lets callers force this after a purchase. Transaction handling error paths must dispatch delegate callbacks on `@MainActor`.

## Tests

`Tests/WinWinKitTests` uses hand-written mocks under `Tests/WinWinKitTests/Mock` that conform to the provider protocols, so tests exercise `UserService` / `Referrals` without touching the network or StoreKit.
