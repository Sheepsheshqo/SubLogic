import SwiftUI
import SwiftData
import RevenueCat
import UserNotifications

@main
struct SubLogicApp: App {

    @State private var appViewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Subscription.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_FJEDkBSNfHbvIkUHFfaaiqnXjqw")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environment(appViewModel)
                .preferredColorScheme(appViewModel.appearanceMode.colorScheme)
                .task {
                    await appViewModel.refreshPremiumStatus()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}
