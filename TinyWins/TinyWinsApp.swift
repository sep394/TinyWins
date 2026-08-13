import SwiftUI

@main
struct TinyWinsApp: App {
    @StateObject private var store = WinStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
