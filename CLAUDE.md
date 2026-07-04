# BiblioBook — Project Memory

## Overview

BiblioBook is an iOS/iPadOS SwiftUI app that maintains a personal database of books. It tracks bibliographic details (title, author, ISBN, publisher, series, genre), a physical copy's condition and location, lending status with dates, ratings/reviews, acquisition cost/source, plus a cover image and four photos per book.

- **Minimum deployment:** iOS 27.0
- **Persistence:** SwiftData (`Book` is the single `@Model` class)
- **UI:** 100% SwiftUI, `NavigationSplitView` (list sidebar + editable detail pane)
- **Concurrency:** Approachable Concurrency enabled, default actor isolation is `MainActor` (see build settings)

## Key Architecture Decisions

- **`Book` is `Encodable` only.** Imports decode into `BookImportRecord` (a plain `Decodable` struct mirror) and convert to `Book` via `makeBook(batchNumber:)`. This keeps the model class exactly as specified while still supporting JSON import.
- **Checksum-based dedup.** `Book.bookChecksum()` (SHA256 over content fields, in `Models/Book.swift`) is refreshed on export and when a detail view disappears; import skips records whose checksum already exists.
- **Images stored inline as `Data`**, compressed to ≤ 200 KB by `Utilities/ImageCompressor.swift` (`@concurrent` — runs off the main actor). Photo rotations are stored as degrees (`imageRotation1...4`), applied at display time with `rotationEffect`, never baked into pixels.
- **Export/import uses the Files document picker** (`fileExporter`/`fileImporter` with a small `JSONDocument: FileDocument`) rather than direct iCloud entitlements — the user picks iCloud Drive (or anywhere) in the picker. JSON uses ISO-8601 dates; image data is base64 (JSON default).
- **Direct editing:** `BookDetailView` binds straight to the model with `@Bindable`; an explicit `modelContext.save()` in `onDisappear` guarantees persistence (autosave alone proved unreliable). `BookAddView` stages everything in local `@State` and only inserts on Save.

## Conventions & Patterns

- One type per file; folders: `Models/`, `Views/`, `Utilities/`.
- `@Observable`/`@Bindable`, never `ObservableObject`.
- Views that mix `@State` with other stored properties define **explicit initializers** — on SDK 27 `@State` is a macro and memberwise-init synthesis is unreliable (see Journal.md).
- Sample/import/manual entries are stamped via `batchNumber` (`sample-…`, `import-…`, `manual`).

## Quirks & Gotchas

- **SDK 27 `@State` macro:** never assign a `@State` property inside an `init` — give it its initial value at the declaration only. Assigning in `init` is either a compile error or silently ignored.
- **`@Model` already generates `Sendable`** on SDK 27 — do not also declare `@unchecked Sendable` on `Book` (redundant-conformance warning).
- **Do not edit `project.pbxproj` directly** (crashes Xcode while open). Build-setting changes must be made in the Xcode UI.
- Two settings must exist in target build settings for full functionality:
  - `INFOPLIST_KEY_NSCameraUsageDescription` — required before the camera button is used on a device.
  - `ENABLE_USER_SELECTED_FILES = readwrite` — the template default `readonly` can block `fileExporter` from writing the user-selected file.
- The A–Z index bar overlays the list's trailing edge; `BookRowView` adds trailing padding so content clears it.

## Build / Run

Open `BiblioBook.xcodeproj` in Xcode 27+, select the BiblioBook scheme, build & run on an iOS 27 simulator or device. No external dependencies, no package resolution needed. Camera capture only works on a physical device (the button hides itself when no camera is available).
