import SwiftUI

@main
struct DashApp: App {
    @UIApplicationDelegateAdaptor var delegate: DashAppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
