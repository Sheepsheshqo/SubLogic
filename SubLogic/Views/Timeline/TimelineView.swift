import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]

    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()

    private var calendar: Calendar { Calendar.current }

    // Subscriptions for the selected day
    private var subscriptionsForSelectedDay: [Subscription] {
        subscriptions.filter {
            $0.isActive && calendar.isDate($0.nextBillingDate, inSameDayAs: selectedDate)
        }
    }

    // Subscriptions grouped by next billing date (within 60 days) — used for dot indicators
    private var groupedByDay: [(date: Date, subscriptions: [Subscription])] {
        let cutoff = calendar.date(byAdding: .day, value: 60, to: Date()) ?? Date()
        let upcoming = subscriptions.filter {
            $0.isActive && $0.nextBillingDate >= calendar.startOfDay(for: Date()) && $0.nextBillingDate <= cutoff
        }

        var dict: [Date: [Subscription]] = [:]
        for sub in upcoming {
            let day = calendar.startOfDay(for: sub.nextBillingDate)
            dict[day, default: []].append(sub)
        }

        return dict.keys.sorted().map { date in
            (date: date, subscriptions: (dict[date] ?? []).sorted { $0.amount > $1.amount })
        }
    }

    // All cells for the displayed month grid (nil = padding from prev/next month)
    private var monthGridDays: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }

        // weekday of first day (0=Sun ... 6=Sat), adjust for Mon-first
        var firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 2 // Mon=0
        if firstWeekday < 0 { firstWeekday += 7 }

        var cells: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                cells.append(d)
            }
        }
        // pad to complete the last row
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }

    // Dates that have subscriptions (for dot indicators)
    private var datesWithPayments: Set<Date> {
        Set(groupedByDay.map { calendar.startOfDay(for: $0.date) })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation + full calendar
                monthCalendar
                    .background(AppColors.secondaryBackground)

                Divider()

                // Subscription list grouped by date
                subscriptionList
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(NSLocalizedString("tab.timeline", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation { selectedDate = Date() }
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(AppColors.accent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if appViewModel.canAddMoreSubscriptions {
                            appViewModel.showAddSubscription = true
                        } else {
                            appViewModel.showPremiumPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
        }
    }

    // MARK: - Full Month Calendar
    private var monthCalendar: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        selectedDate = displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 36, height: 36)
                }

                Spacer()

                Text(monthYearString(displayedMonth))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        selectedDate = displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 36, height: 36)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)

            // Weekday labels (Mon–Sun)
            HStack(spacing: 0) {
                ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, label in
                    Text(label)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.tertiaryLabel)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.top, 6)
            .padding(.bottom, 2)

            // Day grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(monthGridDays.enumerated()), id: \.offset) { _, optDate in
                    if let date = optDate {
                        monthDayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.sm)
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if value.translation.width < -40 {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        } else if value.translation.width > 40 {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        }
                    }
                }
        )
    }

    private func monthDayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasPayment = datesWithPayments.contains(calendar.startOfDay(for: date))
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? AppColors.accent :
                            isToday ? AppColors.accent.opacity(0.15) : Color.clear
                        )
                        .frame(width: 32, height: 32)

                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 14, weight: isSelected || isToday ? .bold : .regular, design: .rounded))
                        .foregroundStyle(
                            isSelected ? .white :
                            isToday ? AppColors.accent :
                            isCurrentMonth ? AppColors.label : AppColors.tertiaryLabel
                        )
                }

                Circle()
                    .fill(hasPayment ? (isSelected ? Color.white.opacity(0.9) : AppColors.accent) : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subscription List
    private var subscriptionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                timelineSectionHeader(
                    selectedDate,
                    total: subscriptionsForSelectedDay.isEmpty ? nil : totalForDay(subscriptionsForSelectedDay)
                )

                if subscriptionsForSelectedDay.isEmpty {
                    emptyDayView
                } else {
                    ForEach(subscriptionsForSelectedDay) { sub in
                        NavigationLink {
                            SubscriptionDetailView(subscription: sub)
                        } label: {
                            TimelineRowView(subscription: sub)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                        }
                        .buttonStyle(.plain)

                        Divider()
                    }
                }
            }
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private var emptyDayView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.tertiaryLabel)
                .padding(.top, AppSpacing.xxl)
            Text(NSLocalizedString("timeline.noPayments", comment: ""))
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }

    private func timelineSectionHeader(_ date: Date, total: String?) -> some View {
        HStack {
            Text(dayHeaderString(date))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .textCase(.uppercase)
                .kerning(0.5)

            Spacer()

            if let total {
                Text(total)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.groupedBackground)
    }


    // MARK: - Helpers
    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dayHeaderString(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return NSLocalizedString("timeline.today", comment: "")
        }
        if calendar.isDateInTomorrow(date) {
            return NSLocalizedString("timeline.tomorrow", comment: "")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func totalForDay(_ subs: [Subscription]) -> String {
        let total = subs.reduce(0.0) { sum, sub in
            sum + appViewModel.currencyService.convert(
                amount: sub.amount,
                from: sub.currency,
                to: appViewModel.displayCurrency
            )
        }
        return appViewModel.formatted(total)
    }
}

// MARK: - Timeline Row
struct TimelineRowView: View {
    @Environment(AppViewModel.self) private var appViewModel
    let subscription: Subscription

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            SubscriptionIconView(
                emoji: subscription.iconEmoji,
                colorHex: subscription.colorHex,
                imageData: subscription.customImageData
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Text("\(subscription.billingCycle.localizedName) · \(subscription.category.localizedName)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(appViewModel.formattedIn(amount: subscription.amount, fromCurrency: subscription.currency))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)

                Image(systemName: subscription.daysUntilNextBilling == 0 ? "checkmark.circle.fill" : "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(subscription.daysUntilNextBilling == 0 ? AppColors.success : AppColors.secondaryLabel)
            }
        }
    }
}
