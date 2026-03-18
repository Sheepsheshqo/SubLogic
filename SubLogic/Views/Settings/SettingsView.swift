import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]

    @State private var showDeleteConfirmation = false
    @State private var showExportConfirmation = false
    @State private var exportedCSV = ""
    @State private var showShareSheet = false
    @State private var exportedItems: [Any] = []

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Privacy & Security
                Section {
                    // End-to-End Encryption (always on - local data)
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("settings.encryption", comment: ""))
                                    .font(.system(size: 15, design: .rounded))
                                Text(NSLocalizedString("settings.encryption.subtitle", comment: ""))
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(AppColors.success)
                            }
                        } icon: {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(AppColors.success)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.success)
                    }

                    // App Lock (FaceID)
                    HStack {
                        Label {
                            Text(NSLocalizedString("settings.faceID", comment: ""))
                                .font(.system(size: 15, design: .rounded))
                        } icon: {
                            Image(systemName: "faceid")
                                .foregroundStyle(AppColors.accent)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { appViewModel.faceIDEnabled },
                            set: { appViewModel.faceIDEnabled = $0 }
                        ))
                        .labelsHidden()
                        .tint(AppColors.accent)
                    }
                } header: {
                    Text(NSLocalizedString("settings.section.privacy", comment: ""))
                } footer: {
                    Text(NSLocalizedString("settings.privacy.footer", comment: ""))
                        .font(.system(size: 12, design: .rounded))
                }

                // MARK: - Cloud Backup (Premium)
                Section {
                    premiumFeatureRow(
                        icon: "icloud.fill",
                        iconColor: AppColors.accent,
                        title: NSLocalizedString("settings.icloudSync", comment: ""),
                        isOn: Binding(
                            get: { appViewModel.iCloudSyncEnabled },
                            set: { newVal in
                                if appViewModel.isPremium { appViewModel.iCloudSyncEnabled = newVal }
                                else { appViewModel.showPremiumPaywall = true }
                            }
                        )
                    )
                } header: {
                    Text(NSLocalizedString("settings.section.backup", comment: ""))
                }

                // MARK: - General
                Section {
                    // Currency
                    NavigationLink {
                        CurrencyPickerView()
                    } label: {
                        HStack {
                            Label {
                                Text(NSLocalizedString("settings.currency", comment: ""))
                                    .font(.system(size: 15, design: .rounded))
                            } icon: {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(AppColors.success)
                            }
                            Spacer()
                            Text(appViewModel.displayCurrency)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }
                    }

                    // Language
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        HStack {
                            Label {
                                Text(NSLocalizedString("settings.language", comment: ""))
                                    .font(.system(size: 15, design: .rounded))
                            } icon: {
                                Image(systemName: "globe")
                                    .foregroundStyle(Color(hex: "5E5CE6"))
                            }
                            Spacer()
                            Text(NSLocalizedString("settings.language.system", comment: ""))
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }
                    }

                    // Appearance
                    NavigationLink {
                        AppearancePickerView()
                    } label: {
                        HStack {
                            Label {
                                Text(NSLocalizedString("settings.appearance", comment: ""))
                                    .font(.system(size: 15, design: .rounded))
                            } icon: {
                                Image(systemName: "moon.circle.fill")
                                    .foregroundStyle(Color(hex: "5E5CE6"))
                            }
                            Spacer()
                            Text(appViewModel.appearanceMode.localizedName)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }
                    }

                    // Notifications
                    HStack {
                        Label {
                            Text(NSLocalizedString("settings.notifications", comment: ""))
                                .font(.system(size: 15, design: .rounded))
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(AppColors.warning)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { appViewModel.notificationsEnabled },
                            set: { newVal in
                                appViewModel.notificationsEnabled = newVal
                                if newVal {
                                    Task {
                                        let granted = await NotificationService.shared.requestAuthorization()
                                        if !granted { appViewModel.notificationsEnabled = false }
                                    }
                                }
                            }
                        ))
                        .labelsHidden()
                        .tint(AppColors.accent)
                    }

                } header: {
                    Text(NSLocalizedString("settings.section.general", comment: ""))
                }

                // MARK: - Premium
                if !appViewModel.isPremium {
                    Section {
                        Button {
                            appViewModel.showPremiumPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(AppColors.premium)
                                Text(NSLocalizedString("settings.upgradePremium", comment: ""))
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppColors.premium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.secondaryLabel)
                            }
                        }
                    }
                }

                // MARK: - Data Management
                Section {
                    // CSV export (free)
                    Button {
                        exportedCSV = generateCSV()
                        exportedItems = [exportedCSV]
                        showShareSheet = true
                    } label: {
                        Label(
                            NSLocalizedString("settings.exportCSV", comment: ""),
                            systemImage: "arrow.down.circle.fill"
                        )
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                    }

                    // PDF export (premium)
                    Button {
                        if appViewModel.isPremium {
                            if let pdfURL = generatePDF() {
                                exportedItems = [pdfURL]
                                showShareSheet = true
                            }
                        } else {
                            appViewModel.showPremiumPaywall = true
                        }
                    } label: {
                        HStack {
                            Label(
                                NSLocalizedString("settings.exportPDF", comment: ""),
                                systemImage: "doc.richtext.fill"
                            )
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppColors.danger)
                            if !appViewModel.isPremium {
                                Spacer()
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppColors.premium)
                            }
                        }
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label(
                            NSLocalizedString("settings.deleteAll", comment: ""),
                            systemImage: "trash.fill"
                        )
                        .font(.system(size: 15, design: .rounded))
                    }
                } header: {
                    Text(NSLocalizedString("settings.section.data", comment: ""))
                }

                // MARK: - About
                Section {
                    Link(destination: URL(string: "https://Sheepsheshqo.github.io/SubLogic/privacy.html")!) {
                        HStack {
                            Label(NSLocalizedString("settings.privacyPolicy", comment: ""),
                                  systemImage: "hand.raised.fill")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColors.accent)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.tertiaryLabel)
                        }
                    }

                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        HStack {
                            Label(NSLocalizedString("settings.termsOfUse", comment: ""),
                                  systemImage: "doc.text.fill")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColors.accent)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.tertiaryLabel)
                        }
                    }

                    HStack {
                        Text(NSLocalizedString("settings.version", comment: ""))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                        Spacer()
                        Text("SubLogic v1.0.0")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColors.tertiaryLabel)
                    }
                    HStack {
                        Text(NSLocalizedString("settings.madeWith", comment: ""))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColors.tertiaryLabel)
                        Spacer()
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab.settings", comment: ""))
            .confirmationDialog(
                NSLocalizedString("settings.deleteAll.confirm.title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("settings.deleteAll", comment: ""), role: .destructive) {
                    deleteAllData()
                }
                Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("settings.deleteAll.confirm.message", comment: ""))
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: exportedItems)
            }
        }
    }

    // MARK: - Premium Feature Row
    private func premiumFeatureRow(icon: String, iconColor: Color, title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Label {
                HStack {
                    Text(title)
                        .font(.system(size: 15, design: .rounded))
                    if !appViewModel.isPremium {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.premium)
                    }
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColors.accent)
        }
    }

    // MARK: - Data Operations
    private func deleteAllData() {
        for sub in subscriptions {
            modelContext.delete(sub)
        }
        try? modelContext.save()
    }

    // MARK: - PDF Generation (Premium)
    private func generatePDF() -> URL? {
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat = 40
        let contentWidth = pageWidth - 2 * margin

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SubLogic_Export.pdf")

        try? renderer.writePDF(to: url) { ctx in
            ctx.beginPage()
            var y: CGFloat = margin

            // -- Title
            let titleAtts: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let title = "SubLogic — Subscription Report"
            title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAtts)
            y += 32

            // -- Date
            let subAtts: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(white: 0.45, alpha: 1)
            ]
            "Generated: \(dateFormatter.string(from: Date()))".draw(at: CGPoint(x: margin, y: y), withAttributes: subAtts)
            y += 22

            // -- Separator line
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: margin, y: y))
            linePath.addLine(to: CGPoint(x: pageWidth - margin, y: y))
            UIColor(white: 0.75, alpha: 1).setStroke()
            linePath.lineWidth = 0.5
            linePath.stroke()
            y += 16

            // -- Summary
            let sectionAtts: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let bodyAtts: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let secondaryAtts: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(white: 0.45, alpha: 1)
            ]

            "SUMMARY".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAtts)
            y += 18

            let active = subscriptions.filter { $0.isActive }
            let monthlyTotal = appViewModel.totalMonthlySpend(subscriptions: active)
            let yearlyTotal = appViewModel.totalYearlySpend(subscriptions: active)

            "Total subscriptions: \(active.count)".draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAtts)
            y += 16
            "Monthly spend: \(appViewModel.formatted(monthlyTotal))".draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAtts)
            y += 16
            "Yearly spend: \(appViewModel.formatted(yearlyTotal))".draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAtts)
            y += 28

            // -- Subscriptions header
            let sep2 = UIBezierPath()
            sep2.move(to: CGPoint(x: margin, y: y))
            sep2.addLine(to: CGPoint(x: pageWidth - margin, y: y))
            UIColor(white: 0.75, alpha: 1).setStroke()
            sep2.lineWidth = 0.5
            sep2.stroke()
            y += 12

            "SUBSCRIPTIONS".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAtts)
            y += 20

            // Column headers
            let col0 = margin, col1 = margin + 170.0, col2 = margin + 300.0, col3 = margin + 400.0
            "Name".draw(at: CGPoint(x: col0, y: y), withAttributes: secondaryAtts)
            "Amount".draw(at: CGPoint(x: col1, y: y), withAttributes: secondaryAtts)
            "Cycle".draw(at: CGPoint(x: col2, y: y), withAttributes: secondaryAtts)
            "Next Bill".draw(at: CGPoint(x: col3, y: y), withAttributes: secondaryAtts)
            y += 18

            // -- Subscription rows
            for sub in subscriptions where sub.isActive {
                if y > pageHeight - margin - 30 {
                    ctx.beginPage()
                    y = margin
                }

                let converted = appViewModel.formattedIn(amount: sub.amount, fromCurrency: sub.currency)
                "\(sub.iconEmoji) \(sub.name)".draw(at: CGPoint(x: col0, y: y), withAttributes: bodyAtts)
                "\(converted) / \(sub.currency)".draw(at: CGPoint(x: col1, y: y), withAttributes: bodyAtts)
                sub.billingCycle.rawValue.draw(at: CGPoint(x: col2, y: y), withAttributes: bodyAtts)
                dateFormatter.string(from: sub.nextBillingDate).draw(at: CGPoint(x: col3, y: y), withAttributes: bodyAtts)
                y += 18

                if !sub.notes.isEmpty {
                    let noteText = "  Note: \(sub.notes)"
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineBreakMode = .byTruncatingTail
                    let noteAtts: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: UIColor(white: 0.45, alpha: 1),
                        .paragraphStyle: paragraphStyle
                    ]
                    noteText.draw(in: CGRect(x: col0 + 10, y: y, width: contentWidth - 10, height: 14), withAttributes: noteAtts)
                    y += 14
                }
                y += 4
            }

            // -- Category breakdown
            y += 12
            if y > pageHeight - margin - 80 {
                ctx.beginPage()
                y = margin
            }

            let sep3 = UIBezierPath()
            sep3.move(to: CGPoint(x: margin, y: y))
            sep3.addLine(to: CGPoint(x: pageWidth - margin, y: y))
            UIColor(white: 0.75, alpha: 1).setStroke()
            sep3.lineWidth = 0.5
            sep3.stroke()
            y += 12

            "CATEGORY BREAKDOWN".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAtts)
            y += 20

            let breakdown = appViewModel.categoryBreakdown(subscriptions: subscriptions)
            for item in breakdown {
                if y > pageHeight - margin - 20 { ctx.beginPage(); y = margin }
                let line = String(format: "%@ %@   %@   %.1f%%  (%d subs)",
                    item.category.icon, item.category.localizedName,
                    appViewModel.formatted(item.amount),
                    item.percentage, item.count)
                line.draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAtts)
                y += 18
            }

            // -- Footer
            y = pageHeight - margin - 14
            "SubLogic • Privacy-First Subscription Manager".draw(at: CGPoint(x: margin, y: y), withAttributes: secondaryAtts)
        }

        return url
    }

    private func generateCSV() -> String {
        var csv = "Name,Amount,Currency,Billing Cycle,Category,Next Billing Date,Notes\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        for sub in subscriptions {
            let row = [
                sub.name,
                String(sub.amount),
                sub.currency,
                sub.billingCycle.rawValue,
                sub.category.rawValue,
                formatter.string(from: sub.nextBillingDate),
                sub.notes.replacingOccurrences(of: ",", with: ";")
            ].joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }
}

// MARK: - Currency Picker View
struct CurrencyPickerView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var searchText = ""

    private var filtered: [String] {
        if searchText.isEmpty { return CurrencyService.supportedCurrencies }
        let q = searchText.uppercased()
        return CurrencyService.supportedCurrencies.filter {
            $0.contains(q) ||
            (CurrencyService.currencyNames[$0]?.uppercased().contains(q) == true)
        }
    }

    var body: some View {
        List(filtered, id: \.self) { currency in
            Button {
                appViewModel.displayCurrency = currency
            } label: {
                HStack(spacing: 14) {
                    // Flag badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.secondaryBackground)
                            .frame(width: 46, height: 34)
                        Text(CurrencyService.flagEmoji(for: currency))
                            .font(.system(size: 22))
                    }

                    // Code + name
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(currency)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.label)
                            Text(CurrencyService.currencySymbols[currency] ?? "")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.fill)
                                .clipShape(Capsule())
                        }
                        Text(CurrencyService.currencyNames[currency] ?? currency)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                    }

                    Spacer()

                    if appViewModel.displayCurrency == currency {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.accent)
                            .font(.system(size: 18))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $searchText, prompt: "USD, EUR, TRY...")
        .navigationTitle(NSLocalizedString("settings.currency", comment: ""))
    }
}

// MARK: - Bindable Currency Picker (for Add/Edit subscription forms)
struct BindableCurrencyPickerView: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filtered: [String] {
        if searchText.isEmpty { return CurrencyService.supportedCurrencies }
        let q = searchText.uppercased()
        return CurrencyService.supportedCurrencies.filter {
            $0.contains(q) ||
            (CurrencyService.currencyNames[$0]?.uppercased().contains(q) == true)
        }
    }

    var body: some View {
        List(filtered, id: \.self) { currency in
            Button {
                selection = currency
                dismiss()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.secondaryBackground)
                            .frame(width: 46, height: 34)
                        Text(CurrencyService.flagEmoji(for: currency))
                            .font(.system(size: 22))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(currency)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.label)
                            Text(CurrencyService.currencySymbols[currency] ?? "")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.fill)
                                .clipShape(Capsule())
                        }
                        Text(CurrencyService.currencyNames[currency] ?? currency)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColors.secondaryLabel)
                    }

                    Spacer()

                    if selection == currency {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.accent)
                            .font(.system(size: 18))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $searchText, prompt: "USD, EUR, TRY...")
        .navigationTitle(NSLocalizedString("add.currency", comment: ""))
    }
}

// MARK: - Appearance Picker
struct AppearancePickerView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        List(AppearanceMode.allCases, id: \.self) { mode in
            Button {
                appViewModel.appearanceMode = mode
            } label: {
                HStack {
                    Label(mode.localizedName, systemImage: iconFor(mode))
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(AppColors.label)
                    Spacer()
                    if appViewModel.appearanceMode == mode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppColors.accent)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings.appearance", comment: ""))
    }

    private func iconFor(_ mode: AppearanceMode) -> String {
        switch mode {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

// MARK: - Language Settings View
struct LanguageSettingsView: View {
    private let supportedLanguages: [(code: String, nativeName: String, englishName: String, flag: String)] = [
        ("en", "English", "English", "🇬🇧"),
        ("tr", "Türkçe", "Turkish", "🇹🇷")
    ]

    private var currentLanguageCode: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    var body: some View {
        List {
            Section {
                ForEach(supportedLanguages, id: \.code) { lang in
                    HStack(spacing: 14) {
                        Text(lang.flag)
                            .font(.system(size: 26))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.nativeName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.label)
                            Text(lang.englishName)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)
                        }

                        Spacer()

                        if currentLanguageCode == lang.code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.accent)
                                .font(.system(size: 18))
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(NSLocalizedString("settings.language.available", comment: ""))
            }

            Section {
                Button {
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
        .navigationTitle(NSLocalizedString("settings.language", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
