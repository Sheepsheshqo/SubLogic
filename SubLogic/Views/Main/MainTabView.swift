import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Query private var subscriptions: [Subscription]

    var body: some View {
        @Bindable var vm = appViewModel

        TabView(selection: $vm.selectedTab) {
            DashboardView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.dashboard", comment: ""),
                        systemImage: "square.grid.2x2.fill"
                    )
                }
                .tag(0)

            TimelineView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.timeline", comment: ""),
                        systemImage: "calendar"
                    )
                }
                .tag(1)

            StatisticsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.statistics", comment: ""),
                        systemImage: "chart.bar.fill"
                    )
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.settings", comment: ""),
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(3)
        }
        .tint(AppColors.accent)
        .onAppear {
            appViewModel.currentSubscriptionCount = subscriptions.count
            appViewModel.advanceStaleBillingDates(subscriptions)
            updateWidget()
        }
        .onChange(of: subscriptions) { _, _ in
            appViewModel.currentSubscriptionCount = subscriptions.count
            updateWidget()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                appViewModel.advanceStaleBillingDates(subscriptions)
                updateWidget()
            }
        }
        .sheet(isPresented: $vm.showAddSubscription) {
            AddSubscriptionView()
        }
        .sheet(isPresented: $vm.showPremiumPaywall) {
            PremiumView()
        }
    }

    private func updateWidget() {
        WidgetDataService.write(
            subscriptions: subscriptions,
            currencyService: appViewModel.currencyService,
            displayCurrency: appViewModel.displayCurrency
        )
    }
}
