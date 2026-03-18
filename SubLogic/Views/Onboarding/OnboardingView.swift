import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable {
    let id: Int
    let emoji: String
    let emojiBackground: Color
    let title: String
    let subtitle: String
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage: Int = 0
    @State private var showLanguagePicker = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            emoji: "🔐",
            emojiBackground: Color(hex: "4A9EFF"),
            title: NSLocalizedString("onboarding.page0.title", comment: ""),
            subtitle: NSLocalizedString("onboarding.page0.subtitle", comment: "")
        ),
        OnboardingPage(
            id: 1,
            emoji: "📋",
            emojiBackground: Color(hex: "32D74B"),
            title: NSLocalizedString("onboarding.page1.title", comment: ""),
            subtitle: NSLocalizedString("onboarding.page1.subtitle", comment: "")
        ),
        OnboardingPage(
            id: 2,
            emoji: "💱",
            emojiBackground: Color(hex: "FF9F0A"),
            title: NSLocalizedString("onboarding.page2.title", comment: ""),
            subtitle: NSLocalizedString("onboarding.page2.subtitle", comment: "")
        ),
        OnboardingPage(
            id: 3,
            emoji: "🔔",
            emojiBackground: Color(hex: "BF5AF2"),
            title: NSLocalizedString("onboarding.page3.title", comment: ""),
            subtitle: NSLocalizedString("onboarding.page3.subtitle", comment: "")
        ),
        OnboardingPage(
            id: 4,
            emoji: "🚀",
            emojiBackground: Color(hex: "FF375F"),
            title: NSLocalizedString("onboarding.page4.title", comment: ""),
            subtitle: NSLocalizedString("onboarding.page4.subtitle", comment: "")
        ),
    ]

    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack {
            AppColors.groupedBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Skip / Language button
                HStack {
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(NSLocalizedString("onboarding.language", comment: ""))
                        }
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                    }

                    Spacer()

                    if !isLastPage {
                        Button(NSLocalizedString("onboarding.skip", comment: "")) {
                            completeOnboarding()
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.accent : AppColors.fill)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, AppSpacing.lg)

                // Bottom Buttons
                VStack(spacing: AppSpacing.md) {
                    // Last page: Currency picker
                    if isLastPage {
                        currencyPickerSection
                    }

                    Button {
                        if isLastPage {
                            requestNotificationAndComplete()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    } label: {
                        Text(isLastPage
                             ? NSLocalizedString("onboarding.getStarted", comment: "")
                             : NSLocalizedString("onboarding.next", comment: ""))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.accent, Color(hex: "6B4EFF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
                            .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            NavigationStack {
                List {
                    Section {
                        Button {
                            showLanguagePicker = false
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label(
                                NSLocalizedString("settings.language.openSettings", comment: ""),
                                systemImage: "gear"
                            )
                            .foregroundStyle(AppColors.accent)
                        }
                    } footer: {
                        Text(NSLocalizedString("settings.language.footer", comment: ""))
                            .font(.system(size: 13, design: .rounded))
                    }
                }
                .navigationTitle(NSLocalizedString("onboarding.language", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(NSLocalizedString("common.done", comment: "")) {
                            showLanguagePicker = false
                        }
                        .foregroundStyle(AppColors.accent)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Currency Picker (Last Page)
    private var currencyPickerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(NSLocalizedString("onboarding.selectCurrency", comment: ""))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(["USD", "EUR", "GBP", "TRY", "JPY", "CAD", "AUD"], id: \.self) { currency in
                        let isSelected = appViewModel.displayCurrency == currency
                        Button {
                            appViewModel.displayCurrency = currency
                        } label: {
                            HStack(spacing: 4) {
                                Text(CurrencyService.flagEmoji(for: currency))
                                Text(currency)
                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? AppColors.accent.opacity(0.15) : AppColors.secondaryBackground)
                            .foregroundStyle(isSelected ? AppColors.accent : AppColors.label)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 1.5)
                            }
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }

    // MARK: - Actions
    private func requestNotificationAndComplete() {
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                appViewModel.notificationsEnabled = granted
                completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        appViewModel.onboardingDone = true
    }
}

// MARK: - Single Onboarding Page
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            // Emoji Circle
            ZStack {
                Circle()
                    .fill(page.emojiBackground.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.emojiBackground.opacity(0.25))
                    .frame(width: 120, height: 120)

                Text(page.emoji)
                    .font(.system(size: 64))
            }

            // Text
            VStack(spacing: AppSpacing.md) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)

                Text(page.subtitle)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
    }
}
