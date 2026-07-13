# BiblioBook — The Learning Journal

*A living document. Update me whenever you fix a gnarly bug, make an architectural call, or learn something the hard way.*

---

## 1. The Big Picture

Imagine you're the kind of person who owns more books than shelf space (aren't we all?). You lend *Dune* to a friend and never see it again. You buy a second copy of *The Name of the Wind* because you forgot you already owned one. BiblioBook is the fix: a personal librarian that lives on your iPhone and iPad.

Every book gets a full record — who wrote it, where it lives in your house, what condition it's in, what you paid, who's borrowed it and when it's due back, how many stars you'd give it, plus a cover shot and up to four photos. You can generate sample data to play with, and back the whole library up to iCloud Drive as a JSON file you can actually read.

## 2. Architecture Deep Dive

Think of the app as a small library building:

- **The card catalog** is SwiftData. There's exactly one kind of card — `Book` — and every drawer query in the app (`@Query`) reads from the same catalog. No view model layer stands between the cards and the reading room; SwiftUI views bind *directly* to the model objects with `@Bindable`, and SwiftData's autosave files everything the moment you stop typing. It's like a librarian who re-shelves the card the instant you put your pen down.
- **The reading room** is a `NavigationSplitView`: the sidebar is the shelf (the book list), the detail pane is the reading desk where one book lies open, fully editable.
- **The photo lab** (`ImageCompressor`) is in the basement — literally off the main actor via `@concurrent` — so developing a 12-megapixel camera photo down to a 200 KB JPEG never freezes the front desk.
- **The shipping dock** (Import/Export) doesn't own a truck. Instead of iCloud entitlements and CloudKit plumbing, it hands your JSON parcel to the system's Files picker and says "deliver this wherever the user points" — which includes iCloud Drive for free.
- **The forgery detector**: every book carries a SHA256 checksum of its content fields (`bChecksum`). On import, if an incoming book's fingerprint matches one already on the shelf, it's turned away at the door. No duplicate copies of *The Great Gatsby* sneaking in through repeated imports.

The one deliberately asymmetric piece: `Book` is `Encodable` but **not** `Decodable`. Exports encode the real model; imports decode into a plain struct (`BookImportRecord`) and then mint fresh `Book` objects. Why? Making a SwiftData `@Model` decodable is fighting the framework (models want to be born inside a context), while a dumb struct decodes anywhere, forgives missing fields, and can't accidentally half-initialize a database object.

## 3. The Codebase Map

```
BiblioBook/
├── BiblioBookApp.swift        # @main — WindowGroup + .modelContainer(for: Book.self)
├── ContentView.swift          # NavigationSplitView: sidebar + detail
├── Models/
│   ├── Book.swift             # The @Model. Fields, Encodable, SHA256 checksum ext.
│   ├── BookImportRecord.swift # Decodable mirror used only for JSON import
│   └── SampleBookFactory.swift# 20 realistic seed books + randomized copy details
├── Views/
│   ├── BookListView.swift     # @Query list, selection, toolbar, sheets, delete
│   ├── BookRowView.swift      # Thumbnail + title/author + "lent to" badge
│   ├── TitleIndexBar.swift    # The #/A–Z tap-to-jump index (Contacts-style)
│   ├── BookDetailView.swift   # Directly editable Form bound with @Bindable
│   ├── BookAddView.swift      # Staging area: local @State, inserts on Save
│   ├── BookPhotosSection.swift# Cover + 4 photo sections for the detail form
│   ├── BookPhotoSlot.swift    # One image slot: library/camera/rotate/remove
│   ├── CameraPicker.swift     # UIImagePickerController wrapper (the one UIKit bit)
│   ├── StarRatingView.swift   # 5 tappable stars; tap current rating to clear
│   ├── OptionalDateRow.swift  # Toggle + DatePicker for Date? fields
│   ├── UtilitiesView.swift    # Sample data generator (1–20 books)
│   ├── ImportExportView.swift # fileExporter / fileImporter + dedup logic
│   ├── JSONDocument.swift     # Tiny FileDocument wrapping Data
│   ├── ShareSheet.swift       # UIActivityViewController wrapper (share by email)
│   └── HelpView.swift         # In-app user guide
└── Utilities/
    ├── ImageCompressor.swift  # ≤200 KB JPEG pipeline, @concurrent
    └── BookSharing.swift      # .bibliobook UTType + one-book export/import
```

Navigation rule of thumb: anything that *shows* books starts in `BookListView`; anything that *changes what a Book is* lives in `Models/`.

## 4. Tech Stack & Why

- **SwiftUI** — because the whole app is forms, lists, and sheets, which SwiftUI does in a tenth of the code. UIKit appears exactly once (`CameraPicker`), because SwiftUI still has no native camera-capture view. That's the "no UIKit unless absolutely necessary" clause, exercised.
- **SwiftData** — one model class, no relationships, autosave on. This is SwiftData's happy path; Core Data would be scaffolding for a problem we don't have.
- **`NavigationSplitView`** — books-and-detail is the textbook master/detail shape. On iPad you get two panes; on iPhone it degrades gracefully to a stack. One API, both devices.
- **`@Bindable` direct-to-model editing** — no view models, no "save" button in the detail view. The model *is* the source of truth; SwiftData persists mutations automatically. Fewer moving parts, no state that can drift out of sync.
- **`fileExporter`/`fileImporter` over CloudKit** — "store a JSON file in iCloud Drive" doesn't need entitlements, sync conflict resolution, or a schema deploy. The Files picker gives users iCloud Drive, On My iPhone, and every third-party file provider, free.
- **`@concurrent` for image work** — Approachable Concurrency's way to say "run this async function on a background thread" without spawning detached tasks by hand. The compiler checks the data crossing the boundary (`UIImage` and `Data` are both `Sendable`).
- **CryptoKit SHA256** — content-fingerprint dedup. Cheap, deterministic, and it makes import idempotent: importing the same file twice adds nothing.

## 5. The Journey

**⚡ The @State macro plot twist (SDK 27).** The biggest "stop and read the manual" moment of the build. As of the 2027 SDKs, `@State` is a *macro*, not a property wrapper. Two consequences bit into the design:
1. You must **not** assign a `@State` property inside an `init` — if it has an initial value at the declaration, the assignment either fails to compile ("variable used before being initialized") or, worse, *silently does nothing* at runtime. Every `@State` in this app gets its value at the declaration, full stop.
2. Views that mix `@State` with other stored properties can lose their synthesized memberwise init. So `BookListView`, `BookAddView`, and `BookPhotoSlot` all declare explicit inits that assign only the non-`@State` properties. If you add a `@State` to a view and the call site suddenly can't find the initializer — this is why. Write the init yourself.

**🐛 The redundant Sendable warning.** The original `Book` spec declared `@unchecked Sendable`. On SDK 27 the `@Model` macro *already* generates a `Sendable` conformance, so the compiler flagged it as redundant (the warning confusingly points into generated macro code at a path like `@__swiftmacro_…`). Fix: drop `@unchecked Sendable` from the declaration. Lesson: when a warning points into macro-generated source, the cause is usually a collision between what *you* declared and what the *macro* declares.

**🧱 The pbxproj is lava.** Attempted to add `INFOPLIST_KEY_NSCameraUsageDescription` by editing `project.pbxproj` directly — blocked, and rightly so: editing the project file while Xcode has it open risks crashing Xcode. Build-setting changes go through the Xcode UI, always.

**📐 The rotating photo geometry trick.** Photo rotations are stored as degrees and applied with `.rotationEffect()` at display time — the pixels are never rewritten, so rotation is instant, lossless, and survives export/import as a simple `Double`. The subtle bit: a rotated rectangle wants to overflow its row. The fix is to fit the image inside a *square* frame **before** rotating — a rectangle fitted into a 200×200 square still fits in that square after any 90° turn. Order of modifiers is everything: `scaledToFit → frame(square) → rotationEffect`.

**🎭 The menu inside a menu (Russian-doll toolbar).** Tapping the list's ellipsis button opened a menu containing just "More" — which you then had to tap *again* to reach Utilities, Import & Export, and Help. The cause: we placed a hand-rolled `Menu` in a `ToolbarItem(placement: .secondaryAction)`, but on iPhone the system *already* collapses secondary actions into its own ellipsis menu — so our menu got nested inside the system's. SDK 27's fix is purpose-built: `ToolbarOverflowMenu { … }` takes plain buttons and puts them directly inside the system overflow menu, one tap away. Lesson: if the system draws the ellipsis for you, don't draw another one inside it.

**🕵️ The Encodable-only model.** `Book` conforms to `Encodable` but not `Decodable`, which sounds like half a job until you try to `init(from:)` a `@Model` class — SwiftData models really want to be created whole and inserted into a context. The `BookImportRecord` struct mirror (with `decodeIfPresent` + defaults on every field) turned out nicer anyway: hand-edited or partial JSON files import without a single crash.

**💾 The autosave that didn't.** `BookDetailView` edits bind straight to the `@Model` via `@Bindable`, and the original design trusted SwiftData's autosave to persist them. In practice, edits were getting lost — autosave batches writes on its own schedule, and if the app is suspended or killed before the batch flushes, the changes evaporate. The fix is one explicit `try modelContext.save()` in `onDisappear`, right after the checksum refresh that was already there. Lesson: SwiftData autosave is a convenience, not a contract — at any natural "commit point" in the UI (leaving an edit screen, backgrounding), save explicitly and treat autosave as a bonus.

**🔍 Search that reads the whole card, not just the spine.** The list's search bar (`.searchable` on `BookListView`) filters across *every* user-facing text field — title, author, comment, format, genre, series, ISBN, location, condition, progress, lent-to, review, source, publisher, copyright date — using `localizedCaseInsensitiveContains`, so "hemingway" matches whether it's the author or buried in a review. Two internal strings (`bChecksum`, `batchNumber`) are deliberately excluded: matching on a SHA256 hex string would be pure noise. The subtle part wasn't the filter, it was the *plumbing*: everything downstream of the list — the A–Z index bar's active keys, index-tap scrolling, and swipe-to-delete offsets — had to switch from `books` to `filteredBooks`, or a swipe-delete during a search would delete the wrong book (offsets index into what's *displayed*, not what's *stored*). Bonus: `ContentUnavailableView.search(text:)` gives a free, properly-worded "No results for…" state.

**🎠 The photo carousel (borrowed with pride).** The detail view's four photos moved from four stacked form rows into a paging carousel at the top of the form — a pattern lifted straight from the sibling BooksRUs app. The modern SwiftUI recipe needs no `TabView(.page)` hacks: `ScrollView(.horizontal)` + `containerRelativeFrame(.horizontal)` on each page (each photo claims exactly one screen-width), `.scrollTargetLayout()` + `.scrollTargetBehavior(.viewAligned)` (snap to pages), and `.scrollPosition(id:)` (a plain `@State Int?` that both *reports* the visible page and *drives* it — tap an indicator dot, set the ID, the scroll view animates over). A `.scrollTransition` shrinking/fading non-current pages sells the carousel feel for free. One bug dodged from the original: BooksRUs iterated `0..<4` and indexed rotations positionally, which desyncs the dots when a middle photo slot is empty — BiblioBook instead builds an `occupiedSlots: [Int]` array and uses the *slot number* as the scroll ID, so photo 3 alone still gets exactly one accurate dot. The rotate button writes to the same stored `imageRotationN` the edit slots use, so the two UIs can't disagree.

**✂️ The 200 KB diet.** Compression strategy: try JPEG qualities from 0.85 down to 0.4; if still too big, scale the image to 70% and repeat (up to 10 rounds). Quality-first beats resize-first because JPEG quality is cheap fidelity to spend, while resolution loss is forever. A 48 MP camera shot lands under 200 KB in a few iterations.

**📨 Share one book, tap to shelve it.** New feature: send a single book to another BiblioBook user by email; they tap the attachment and it lands in their library. The whole thing rides on machinery the app already had — `Book: Encodable` for the outbound JSON, `BookImportRecord` + `bookChecksum()` dedup for the inbound side. `BookSharing.exportFile(for:)` writes one book (not the export's *array*) to a temp `.bibliobook` file; the detail view's Share button hands that URL to a `UIActivityViewController` (wrapped as `ShareSheet`) so Mail attaches it. On the receiving end, `ContentView.onOpenURL` decodes the file, skips it if the checksum already exists, otherwise inserts and selects it. The importer even tolerates an array-shaped file (takes the first record) so a full export can be "shared" too.

**🧨 The synchronized-group landmine.** The one real fight was the Info.plist. To make a tapped attachment *launch BiblioBook*, the app must **own** a document type — which means `CFBundleDocumentTypes` + `UTExportedTypeDeclarations` for a custom `com.catalpa.bibliobook.book` UTI (extension `.bibliobook`, conforming to `public.json`). The project has no Info.plist file (it's `GENERATE_INFOPLIST_FILE = YES`), so I created one. First build: **"Multiple commands produce … Info.plist."** Cause: this project uses Xcode's *file-system-synchronized groups* — every file physically inside the `BiblioBook/` source folder is auto-added to the target, so my new plist got compiled *as a bundle resource*, colliding with the generated one. Fix: move `Info.plist` **out** of the synchronized folder, up to the project root next to the `.xcodeproj`, where nothing auto-adopts it. Then it's referenced only when `INFOPLIST_FILE` points at it. Lesson: in a synchronized-group project, config files that must *not* be a build input belong outside the synced folder. And with `GENERATE_INFOPLIST_FILE = YES`, a partial Info.plist is fine — Xcode merges the generated keys (camera usage, etc.) on top of your file, so you only list what the generator can't express (nested dict arrays like document types).

## 6. Engineer's Wisdom

- **Bind to the model, skip the middleman.** With SwiftData + `@Bindable`, a directly-editable detail view needs zero glue code. Add view models when you have *logic*, not out of habit.
- **Stage risky input, commit atomically.** `BookAddView` deliberately does *not* touch the database until Save — local `@State` is the scratchpad, `insert` is the commit. Cancel costs nothing. (Contrast with the detail view, where edits to an *existing* record should persist live.)
- **Make imports idempotent.** Anything a user can do twice, they will do twice. The checksum dedup means "oops, imported the backup again" is a no-op instead of 40 duplicate books.
- **Store transformations, not transformed data.** Rotation-as-a-`Double` (vs. rotating pixels) keeps the original photo intact and makes undo trivial. Same principle as non-destructive editing in Photos.
- **Let the system UI do the heavy lifting.** The Files picker *is* the iCloud integration. The PhotosPicker *is* the permission flow (it's out-of-process — no photo-library permission string needed). The best privacy prompt is the one you never have to show.
- **When a macro-heavy SDK changes, read the release notes before "fixing" the obvious way.** The intuitive fix for the `@State` init error (reorder assignments) compiles in some cases and then misbehaves at runtime. New-SDK compile errors deserve a documentation check, not a reflexive patch.

## 7. If I Were Starting Over...

- **Enums-as-strings.** `format`, `bookCondition`, and `progress` are free-text `String`s per the original spec. Real-world data entry will produce "Hardcover", "hardcover", and "Hard cover". I'd define enums (or at least a suggestion picker) while keeping the stored type `String` for JSON compatibility.
- **A `photos` value array.** `image1Data...image4Data` + `imageRotation1...4` as eight parallel properties works, but a single array of a small codable struct (`[BookPhoto]`) would collapse `BookPhotosSection` and the slot plumbing dramatically. Kept as-is to honor the specified schema.
- **Search.** A `.searchable` filter on the list is the most-missed feature after ~50 books. It composes cleanly with the existing `@Query` — good first enhancement.
- **Checksum lifecycle.** Refreshing `bChecksum` on detail-view disappear + export works, but a computed-on-demand approach (always call `bookChecksum()` when comparing, never store) would eliminate staleness bugs at the cost of a little CPU during import.
- **Externalize image storage.** If libraries grow into the thousands, `@Attribute(.externalStorage)` on the five `Data` properties would keep the SQLite store lean. Not needed at hobbyist scale; worth remembering.
