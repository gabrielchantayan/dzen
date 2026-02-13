# Update Checker Design

## Summary

Add automatic update checking that fetches `version.json` from GitHub every 12 hours (and on launch), compares against the running app version, and displays a yellow warning link in the footer when an update is available.

## New file: `UpdateChecker.swift`

An `@Observable` class that:
- On init, kicks off an immediate check via `Task`
- Starts a `Timer` firing every 12 hours (43200 seconds)
- Fetches `https://raw.githubusercontent.com/gabrielchantayan/dzen/master/version.json`
- Decodes `{"major":N,"minor":N}` JSON
- Compares against the app's `CFBundleShortVersionString` (parsed as major.minor)
- Exposes `updateAvailable: Bool`
- Silently swallows errors (network failures, decode failures)

## Changes to `dzenApp.swift`

Add `@State private var updateChecker = UpdateChecker()` and pass it to `ContentView`.

## Changes to `ContentView.swift`

- Accept `UpdateChecker` as a new property
- In the footer, between the attribution row and the version/quit row, conditionally show a yellow `Link("Update available", destination:)` pointing to `https://github.com/gabrielchantayan/dzen/releases/latest`
- Styled `.foregroundStyle(.yellow)`, `.font(.caption)`
