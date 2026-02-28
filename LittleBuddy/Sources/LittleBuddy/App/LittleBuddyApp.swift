import SwiftUI

@main
struct LittleBuddyApp: App {
    @StateObject private var characterStore = CharacterStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(characterStore)
        }
    }
}
