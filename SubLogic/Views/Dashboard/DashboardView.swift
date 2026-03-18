import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
    @State private var showAllSubscriptions = false

    private var breakdowns: [AppViewModel.CategoryBreakdown] {
        appViewModel.categoryBreakdown(subscriptions: subscriptions)
    }

    private var monthlyTotal: Double {
        appViewModel.totalMonthlySpend(subscriptions: subscriptions)
    }

    private var upcoming: [Subscription] {
        appViewModel.upcomingPayments(subscriptions: subscriptions, days: 30)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {

                    // MARK: - Donut Chart Card
                    chartCard

                    // MARK: - Total Expenses Card
                    totalExpensesCard

                    // MARK: - Upcoming Payments
                    upcomingSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(NSLocalizedString("dashboard.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        handleAddTap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
            .navigationDestination(isPresented: $showAllSubscriptions) {
                AllSubscriptionsView()
            }
        }
    }

    // MARK: - Chart Card
    private var chartCard: some View {
        VStack(spacing: AppSpacing.lg) {
            if subscriptions.isEmpty {
                emptyStateChart
            } else {
                DonutChartView(
                    breakdowns: breakdowns,
                    centerLabel: NSLocalizedString("dashboard.monthly", comment: ""),
                    centerValue: appViewModel.formatted(monthlyTotal)
                )
                .padding(.top, AppSpacing.sm)

                if !breakdowns.isEmpty {
                    categoryLegend
                }
            }
        }
        .padding(AppSpacing.lg)
        .cardStyle()
        .padding(.top, AppSpacing.sm)
    }

    private var emptyStateChart: some View {
        VStack(spacing: AppSpacing.md) {
            Circle()
                .stroke(AppColors.fill, lineWidth: 18)
                .frame(width: 160, height: 160)
                .overlay {
                    VStack(spacing: 4) {
                        Text(NSLocalizedString("dashboard.monthly", comment: ""))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                            .textCase(.uppercase)
                        Text(appViewModel.formatted(0))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.label)
                    }
                }
                .padding(.top, AppSpacing.sm)

            Text(NSLocalizedString("dashboard.empty.hint", comment: ""))
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
    }

    private var categoryLegend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                ForEach(breakdowns.prefix(5)) { item in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(AppColors.categoryColor(item.category))
                            .frame(width: 8, height: 8)
                        Text(item.category.localizedName)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                        Text(String(format: "%.0f%%", item.percentage))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.label)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Total Expenses Card
    private var totalExpensesCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("dashboard.totalExpenses", comment: ""))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)

                Text(appViewModel.formatted(monthlyTotal))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)
            }

            Spacer()

            // Subscription count badge
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.success)
                        .font(.caption)
                    Text(String(format: NSLocalizedString("dashboard.activeCount", comment: ""), subscriptions.filter(\.isActive).count))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.success)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppColors.success.opacity(0.12))
                .clipShape(Capsule())

                Text(NSLocalizedString("dashboard.perMonth", comment: ""))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(AppColors.tertiaryLabel)
            }
        }
        .padding(AppSpacing.lg)
        .cardStyle()
    }

    // MARK: - Upcoming Payments
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(NSLocalizedString("dashboard.upcomingPayments", comment: ""))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Spacer()
                Button(NSLocalizedString("dashboard.seeAll", comment: "")) {
                    showAllSubscriptions = true
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.accent)
            }

            if upcoming.isEmpty {
                noUpcomingView
            } else {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(upcoming.prefix(5)) { sub in
                        NavigationLink {
                            SubscriptionDetailView(subscription: sub)
                        } label: {
                            SubscriptionRowView(subscription: sub)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var noUpcomingView: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(AppColors.success)
            Text(NSLocalizedString("dashboard.noUpcoming", comment: ""))
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .cardStyle()
    }

    // MARK: - Actions
    private func handleAddTap() {
        if appViewModel.canAddMoreSubscriptions {
            appViewModel.showAddSubscription = true
        } else {
            appViewModel.showPremiumPaywall = true
        }
    }
}

// MARK: - Subscription Row
struct SubscriptionRowView: View {
    @Environment(AppViewModel.self) private var appViewModel
    let subscription: Subscription

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Icon
            SubscriptionIconView(
                emoji: subscription.iconEmoji,
                colorHex: subscription.colorHex,
                imageData: subscription.customImageData
            )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.label)
                Text(subscription.category.localizedName)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabelStrong)
            }

            Spacer()

            // Amount + Due
            VStack(alignment: .trailing, spacing: 3) {
                Text(appViewModel.formattedIn(amount: subscription.amount, fromCurrency: subscription.currency))
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.label)

                dueBadge
            }
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }

    @ViewBuilder
    private var dueBadge: some View {
        let days = subscription.daysUntilNextBilling
        if days == 0 {
            Text(NSLocalizedString("due.today", comment: ""))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.danger)
                .clipShape(Capsule())
        } else if days == 1 {
            Text(NSLocalizedString("due.tomorrow", comment: ""))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.warning)
                .clipShape(Capsule())
        } else {
            Text(String(format: NSLocalizedString("due.inDays", comment: ""), days))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabelStrong)
        }
    }
}

// MARK: - All Subscriptions View
struct AllSubscriptionsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
    @State private var searchText = ""

    private var filtered: [Subscription] {
        if searchText.isEmpty { return subscriptions }
        return subscriptions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filtered) { sub in
                NavigationLink {
                    SubscriptionDetailView(subscription: sub)
                } label: {
                    SubscriptionRowView(subscription: sub)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: NSLocalizedString("search.placeholder", comment: ""))
        .navigationTitle(NSLocalizedString("allSubscriptions.title", comment: ""))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if appViewModel.canAddMoreSubscriptions {
                        appViewModel.showAddSubscription = true
                    } else {
                        appViewModel.showPremiumPaywall = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
