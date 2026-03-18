import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Query private var subscriptions: [Subscription]

    @State private var selectedPeriod: StatsPeriod = .monthly
    @State private var selectedSlice: SubscriptionCategory? = nil

    enum StatsPeriod: String, CaseIterable {
        case monthly = "monthly"
        case yearly  = "yearly"
        var localizedName: String { NSLocalizedString("stats.period.\(rawValue)", comment: "") }
    }

    private var active: [Subscription] { subscriptions.filter(\.isActive) }
    private var monthlyTotal: Double { appViewModel.totalMonthlySpend(subscriptions: active) }
    private var yearlyTotal: Double  { appViewModel.totalYearlySpend(subscriptions: active) }
    private var totalForPeriod: Double { selectedPeriod == .monthly ? monthlyTotal : yearlyTotal }
    private var breakdowns: [AppViewModel.CategoryBreakdown] { appViewModel.categoryBreakdown(subscriptions: active) }
    private var cycleBreakdowns: [AppViewModel.CycleBreakdown] { appViewModel.cycleBreakdown(subscriptions: active) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {

                    Picker("", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases, id: \.self) { Text($0.localizedName).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)

                    summaryCard

                    if !active.isEmpty { quickStatsRow }
                    if !breakdowns.isEmpty { categoryDonutCard }
                    if cycleBreakdowns.count > 1 { billingCycleCard }
                    if !active.isEmpty { upcomingSpendCard }
                    if !active.isEmpty { mostExpensiveCard }

                    currencyConverterSection
                }
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(NSLocalizedString("tab.statistics", comment: ""))
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text(selectedPeriod == .monthly
                     ? NSLocalizedString("stats.monthlyTotal", comment: "")
                     : NSLocalizedString("stats.yearlyTotal", comment: ""))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
                Spacer()
                Text(String(format: NSLocalizedString("stats.subsCount", comment: ""), active.count))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
            HStack(alignment: .bottom) {
                Text(appViewModel.formatted(totalForPeriod))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Spacer()
            }
            HStack(spacing: AppSpacing.md) {
                statPill(label: NSLocalizedString("stats.monthlyTotal", comment: ""),
                         value: appViewModel.formatted(monthlyTotal),
                         color: AppColors.accent, isSelected: selectedPeriod == .monthly)
                statPill(label: NSLocalizedString("stats.yearlyTotal", comment: ""),
                         value: appViewModel.formatted(yearlyTotal),
                         color: Color(hex: "BF5AF2"), isSelected: selectedPeriod == .yearly)
            }
        }
        .padding(AppSpacing.lg)
        .cardStyle()
        .padding(.horizontal, AppSpacing.md)
    }

    private func statPill(label: String, value: String, color: Color, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(label)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? color : AppColors.label)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? color.opacity(0.08) : AppColors.fill)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        let sorted = active.sorted {
            appViewModel.currencyService.convert(amount: $0.monthlyAmount, from: $0.currency, to: appViewModel.displayCurrency) >
            appViewModel.currencyService.convert(amount: $1.monthlyAmount, from: $1.currency, to: appViewModel.displayCurrency)
        }
        let avgMonthly = active.isEmpty ? 0.0 : monthlyTotal / Double(active.count)
        let mostVal = sorted.first.map {
            appViewModel.currencyService.convert(
                amount: selectedPeriod == .monthly ? $0.monthlyAmount : $0.yearlyAmount,
                from: $0.currency, to: appViewModel.displayCurrency)
        } ?? 0.0
        let cheapVal = sorted.last.map {
            appViewModel.currencyService.convert(
                amount: selectedPeriod == .monthly ? $0.monthlyAmount : $0.yearlyAmount,
                from: $0.currency, to: appViewModel.displayCurrency)
        } ?? 0.0

        return HStack(spacing: AppSpacing.sm) {
            quickStatCard(icon: "divide.circle.fill", iconColor: AppColors.accent,
                          label: NSLocalizedString("stats.avgPerSub", comment: ""),
                          value: appViewModel.formatted(selectedPeriod == .monthly ? avgMonthly : avgMonthly * 12))
            quickStatCard(icon: "arrow.up.circle.fill", iconColor: AppColors.danger,
                          label: NSLocalizedString("stats.mostExpensive", comment: ""),
                          value: appViewModel.formatted(mostVal))
            quickStatCard(icon: "arrow.down.circle.fill", iconColor: AppColors.success,
                          label: NSLocalizedString("stats.cheapest", comment: ""),
                          value: appViewModel.formatted(cheapVal))
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func quickStatCard(icon: String, iconColor: Color, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .lineLimit(1)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    // MARK: - Category Donut Chart
    private var categoryDonutCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(NSLocalizedString("stats.byCategory", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .padding(.horizontal, AppSpacing.md)

            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Chart(breakdowns) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(AppColors.categoryColor(item.category))
                        .opacity(selectedSlice == nil || selectedSlice == item.category ? 1 : 0.3)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .animation(.easeInOut(duration: 0.3), value: selectedSlice)

                    VStack(spacing: 2) {
                        if let sel = selectedSlice,
                           let item = breakdowns.first(where: { $0.category == sel }) {
                            let amount = selectedPeriod == .monthly ? item.amount : item.amount * 12
                            Text(appViewModel.formatted(amount))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.label)
                            Text(String(format: "%.0f%%", item.percentage))
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        } else {
                            Text(appViewModel.formatted(totalForPeriod))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.label)
                            Text(NSLocalizedString("stats.total", comment: ""))
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }
                    }
                }

                VStack(spacing: 0) {
                    ForEach(breakdowns) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedSlice = selectedSlice == item.category ? nil : item.category
                            }
                        } label: {
                            categoryRow(item)
                        }
                        .buttonStyle(.plain)
                        if item.id != breakdowns.last?.id {
                            Divider().padding(.leading, AppSpacing.md)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private func categoryRow(_ item: AppViewModel.CategoryBreakdown) -> some View {
        let isSelected = selectedSlice == item.category
        return VStack(spacing: AppSpacing.sm) {
            HStack {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.categoryColor(item.category))
                        .frame(width: 30, height: 30)
                        .background(AppColors.categoryColor(item.category).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.category.localizedName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.label)
                        Text(String(format: NSLocalizedString("stats.subCount", comment: ""), item.count))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    let amount = selectedPeriod == .monthly ? item.amount : item.amount * 12
                    Text(appViewModel.formatted(amount))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? AppColors.categoryColor(item.category) : AppColors.label)
                    Text(String(format: "%.0f%%", item.percentage))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.categoryColor(item.category))
                        .padding(.leading, 4)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColors.fill).frame(height: 4)
                    Capsule()
                        .fill(AppColors.categoryColor(item.category))
                        .frame(width: geo.size.width * (item.percentage / 100), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(AppSpacing.md)
        .background(isSelected ? AppColors.categoryColor(item.category).opacity(0.05) : Color.clear)
    }

    // MARK: - Billing Cycle Breakdown
    private var billingCycleCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(NSLocalizedString("stats.byCycle", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .padding(.horizontal, AppSpacing.md)

            VStack(spacing: AppSpacing.md) {
                Chart(cycleBreakdowns) { item in
                    BarMark(
                        x: .value("Cycle", item.cycle.localizedName),
                        y: .value("Amount", selectedPeriod == .monthly ? item.monthlyAmount : item.monthlyAmount * 12)
                    )
                    .foregroundStyle(cycleColor(item.cycle))
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        Text(appViewModel.formatted(selectedPeriod == .monthly ? item.monthlyAmount : item.monthlyAmount * 12))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                    }
                }
                .frame(height: 160)
                .chartYAxis(.hidden)

                HStack(spacing: AppSpacing.md) {
                    ForEach(cycleBreakdowns) { item in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cycleColor(item.cycle))
                                .frame(width: 10, height: 10)
                            Text("\(item.cycle.localizedName) (\(item.count))")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }
                    }
                    Spacer()
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private func cycleColor(_ cycle: BillingCycle) -> Color {
        switch cycle {
        case .weekly:    return Color(hex: "64D2FF")
        case .monthly:   return AppColors.accent
        case .quarterly: return Color(hex: "BF5AF2")
        case .yearly:    return AppColors.success
        }
    }

    // MARK: - Upcoming Spend
    private var upcomingSpendCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(NSLocalizedString("stats.upcoming", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .padding(.horizontal, AppSpacing.md)

            HStack(spacing: AppSpacing.sm) {
                upcomingPill(days: 7,  labelKey: "stats.next7d",  color: AppColors.success)
                upcomingPill(days: 30, labelKey: "stats.next30d", color: AppColors.warning)
                upcomingPill(days: 90, labelKey: "stats.next90d", color: AppColors.danger)
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private func upcomingPill(days: Int, labelKey: String, color: Color) -> some View {
        let amount = appViewModel.projectedSpend(subscriptions: active, days: days)
        return VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(labelKey, comment: ""))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
            Text(appViewModel.formatted(amount))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(amount > 0 ? color : AppColors.tertiaryLabel)
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(amount > 0 ? 0.08 : 0.03))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(color.opacity(amount > 0 ? 0.2 : 0.05), lineWidth: 1))
    }

    // MARK: - Most Expensive
    private var mostExpensiveCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(NSLocalizedString("stats.mostExpensive", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .padding(.horizontal, AppSpacing.md)

            let sorted = active.sorted {
                appViewModel.currencyService.convert(amount: $0.monthlyAmount, from: $0.currency, to: appViewModel.displayCurrency) >
                appViewModel.currencyService.convert(amount: $1.monthlyAmount, from: $1.currency, to: appViewModel.displayCurrency)
            }

            VStack(spacing: 0) {
                ForEach(sorted.prefix(5).indices, id: \.self) { index in
                    let sub = sorted[index]
                    expensiveRow(sub, rank: index + 1)
                    if index < min(4, sorted.count - 1) {
                        Divider().padding(.leading, AppSpacing.md)
                    }
                }
            }
            .cardStyle()
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private func expensiveRow(_ sub: Subscription, rank: Int) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(rank == 1 ? AppColors.premium.opacity(0.15) : AppColors.fill)
                    .frame(width: 26, height: 26)
                Text("\(rank)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(rank == 1 ? AppColors.premium : AppColors.secondaryLabel)
            }
            SubscriptionIconView(emoji: sub.iconEmoji, colorHex: sub.colorHex,
                                 imageData: sub.customImageData, size: 36, cornerRadius: AppRadius.sm)
            VStack(alignment: .leading, spacing: 1) {
                Text(sub.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Text(sub.billingCycle.localizedName)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                let monthly = appViewModel.currencyService.convert(
                    amount: sub.monthlyAmount, from: sub.currency, to: appViewModel.displayCurrency)
                let display = selectedPeriod == .monthly ? monthly : monthly * 12
                Text(appViewModel.formatted(display))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                let pct = totalForPeriod > 0 ? (display / totalForPeriod) * 100 : 0
                Text(String(format: "%.0f%%", pct))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
        }
        .padding(AppSpacing.md)
    }

    // MARK: - Currency Converter
    private var currencyConverterSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(NSLocalizedString("stats.currencyConverter", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
            CurrencyConverterWidget()
        }
        .padding(.horizontal, AppSpacing.md)
    }
}

// MARK: - Currency Converter Widget
struct CurrencyConverterWidget: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var amount: String = "100"
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"

    private var convertedAmount: Double {
        let value = Double(amount) ?? 0
        return appViewModel.currencyService.convert(amount: value, from: fromCurrency, to: toCurrency)
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                TextField("100", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(AppSpacing.sm)
                    .background(AppColors.fill)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                currencyPicker($fromCurrency)
            }
            Button {
                swap(&fromCurrency, &toCurrency)
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title2).foregroundStyle(AppColors.accent)
            }
            HStack {
                Text(appViewModel.currencyService.formatted(amount: convertedAmount, currency: toCurrency))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Spacer()
                currencyPicker($toCurrency)
            }
        }
        .padding(AppSpacing.lg)
        .cardStyle()
    }

    private func currencyPicker(_ binding: Binding<String>) -> some View {
        Picker("", selection: binding) {
            ForEach(CurrencyService.supportedCurrencies, id: \.self) { currency in
                HStack { Text(CurrencyService.flagEmoji(for: currency)); Text(currency) }.tag(currency)
            }
        }
        .pickerStyle(.menu)
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .tint(AppColors.accent)
    }
}
