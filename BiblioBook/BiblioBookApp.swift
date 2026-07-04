import SwiftUI
import SwiftData

@main
struct BiblioBookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self)
    }
}
