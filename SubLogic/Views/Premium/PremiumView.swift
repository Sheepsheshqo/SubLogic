import SwiftUI
import RevenueCat

struct PremiumView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var currentOffering: Offering? = nil
    @State private var errorMessage: String? = nil

    enum PremiumPlan: CaseIterable {
        case monthly
        case yearly

        var localizedName: String {
            switch self {
            case .monthly: return NSLocalizedString("billing.monthly", comment: "")
            case .yearly:  return NSLocalizedString("billing.yearly", comment: "")
            }
        }

        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly:  return NSLocalizedString("premium.save17", comment: "")
            }
        }
    }

    // RevenueCat package for each plan
    var monthlyPackage: Package? { currentOffering?.monthly }
    var annualPackage:  Package? { currentOffering?.annual }

    var selectedPackage: Package? {
        selectedPlan == .yearly ? annualPackage : monthlyPackage
    }

    // Formatted price strings — fall back to App Store prices if offerings not loaded yet
    func priceText(for plan: PremiumPlan) -> String {
        switch plan {
        case .monthly: return monthlyPackage?.storeProduct.localizedPriceString ?? "$2.99"
        case .yearly:  return annualPackage?.storeProduct.localizedPriceString  ?? "$29.99"
        }
    }

    func pricePerMonthText(for plan: PremiumPlan) -> String {
        switch plan {
        case .monthly:
            return (monthlyPackage?.storeProduct.localizedPriceString ?? "$2.99") + "/mo"
        case .yearly:
            // Divide annual price by 12 for per-month display
            if let price = annualPackage?.storeProduct.price as Decimal?,
               let formatted = annualPackage?.storeProduct.priceFormatter?.string(for: (price / 12) as NSDecimalNumber) {
                return formatted + "/mo"
            }
            return "$2.50/mo"
        }
    }

    let features: [(icon: String, color: Color, title: String, subtitle: String)] = [
        ("infinity",                  AppColors.accent,              "premium.feature.unlimited.title",  "premium.feature.unlimited.subtitle"),
        ("icloud.fill",               Color(hex: "64D2FF"),          "premium.feature.backup.title",     "premium.feature.backup.subtitle"),
        ("arrow.triangle.2.circlepath", AppColors.success,           "premium.feature.currency.title",   "premium.feature.currency.subtitle"),
        ("rectangle.stack.fill",      AppColors.warning,             "premium.feature.widget.title",     "premium.feature.widget.subtitle"),
        ("bell.badge.fill",           Color(hex: "BF5AF2"),          "premium.feature.reminders.title",  "premium.feature.reminders.subtitle"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {

                    // MARK: - Header
                    premiumHeader

                    // MARK: - Features
                    featuresSection

                    // MARK: - Plan Picker
                    planPicker

                    // MARK: - Error / No Offerings Info
                    if currentOffering == nil && errorMessage != nil {
                        // Offerings not yet configured in RevenueCat dashboard
                        VStack(spacing: 6) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.warning)
                            Text(NSLocalizedString("premium.setupPending", comment: ""))
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    // MARK: - CTA
                    ctaSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(NSLocalizedString("premium.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("common.close", comment: "")) {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.secondaryLabel)
                }
            }
            .task {
                await loadOfferings()
            }
        }
    }

    // MARK: - Header
    private var premiumHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.premium, AppColors.warning],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.premium.opacity(0.4), radius: 20, x: 0, y: 8)

                Image(systemName: "star.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.top, AppSpacing.lg)

            Text(NSLocalizedString("premium.tagline", comment: ""))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("premium.description", comment: ""))
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(features.indices, id: \.self) { index in
                let feature = features[index]
                featureRow(
                    icon: feature.icon,
                    color: feature.color,
                    title: NSLocalizedString(feature.title, comment: ""),
                    subtitle: NSLocalizedString(feature.subtitle, comment: "")
                )
                if index < features.count - 1 {
                    Divider().padding(.leading, AppSpacing.md + 40 + AppSpacing.md)
                }
            }
        }
        .cardStyle()
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.success)
                .font(.system(size: 16))
        }
        .padding(AppSpacing.md)
    }

    // MARK: - Plan Picker
    private var planPicker: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(PremiumPlan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: PremiumPlan) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: AppSpacing.sm) {
                if let savings = plan.savings {
                    Text(savings)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppColors.success)
                        .clipShape(Capsule())
                } else {
                    Spacer().frame(height: 22)
                }

                Text(plan.localizedName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.label)

                Text(priceText(for: plan))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)

                Text(pricePerMonthText(for: plan))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.accent.opacity(0.1) : AppColors.secondaryBackground)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA
    private var ctaSection: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                handlePurchase()
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(NSLocalizedString("premium.cta", comment: ""))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [AppColors.accent, Color(hex: "6B4EFF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
                .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(isPurchasing || isRestoring || selectedPackage == nil)

            Button {
                handleRestore()
            } label: {
                if isRestoring {
                    ProgressView()
                } else {
                    Text(NSLocalizedString("premium.restore", comment: ""))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                }
            }
            .disabled(isPurchasing || isRestoring)

            Text(NSLocalizedString("premium.terms", comment: ""))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(AppColors.tertiaryLabel)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(NSLocalizedString("premium.privacyPolicy", comment: ""),
                     destination: URL(string: "https://burhanbisgin.github.io/SubLogic/privacy.html")!)
                Text("·")
                    .foregroundStyle(AppColors.tertiaryLabel)
                Link(NSLocalizedString("premium.termsOfUse", comment: ""),
                     destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            }
            .font(.system(size: 12, design: .rounded))
            .foregroundStyle(AppColors.accent)
        }
    }

    // MARK: - Actions

    private func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handlePurchase() {
        guard let package = selectedPackage else { return }
        errorMessage = nil
        isPurchasing = true

        Task {
            do {
                let result = try await Purchases.shared.purchase(package: package)
                if !result.userCancelled {
                    appViewModel.isPremium = result.customerInfo.entitlements["SubLogic Pro"]?.isActive == true
                    if appViewModel.isPremium { dismiss() }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isPurchasing = false
        }
    }

    private func handleRestore() {
        errorMessage = nil
        isRestoring = true

        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                appViewModel.isPremium = customerInfo.entitlements["SubLogic Pro"]?.isActive == true
                if appViewModel.isPremium { dismiss() }
            } catch {
                errorMessage = error.localizedDescription
            }
            isRestoring = false
        }
    }
}
