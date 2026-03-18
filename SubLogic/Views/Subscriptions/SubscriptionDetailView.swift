import SwiftUI
import SwiftData
import PhotosUI

struct SubscriptionDetailView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let subscription: Subscription

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {

                // MARK: - Header
                headerSection

                // MARK: - Details Card
                detailsCard

                // MARK: - Remaining Periods
                if subscription.trackRemainingPeriods {
                    remainingPeriodsCard
                }

                // MARK: - Notes
                if !subscription.notes.isEmpty {
                    notesCard
                }

                // MARK: - Management
                managementCard

                // MARK: - Delete Button
                deleteButton
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColors.groupedBackground)
        .navigationTitle(NSLocalizedString("detail.title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(NSLocalizedString("common.edit", comment: "")) {
                    showEditSheet = true
                }
                .foregroundStyle(AppColors.accent)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditSubscriptionView(subscription: subscription)
        }
        .confirmationDialog(
            NSLocalizedString("detail.delete.confirm.title", comment: ""),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("detail.delete", comment: ""), role: .destructive) {
                deleteSubscription()
            }
            Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("detail.delete.confirm.message", comment: ""))
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            SubscriptionIconView(
                emoji: subscription.iconEmoji,
                colorHex: subscription.colorHex,
                imageData: subscription.customImageData,
                size: 90,
                cornerRadius: AppRadius.xxl
            )

            VStack(spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)

                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColors.categoryColor(subscription.category))
                        .frame(width: 6, height: 6)
                    Text(subscription.category.localizedName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(AppColors.fill)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.md)
    }

    // MARK: - Details Card
    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(
                icon: "dollarsign.circle.fill",
                iconColor: AppColors.success,
                label: NSLocalizedString("detail.price", comment: ""),
                value: "\(CurrencyService.currencySymbols[subscription.currency] ?? subscription.currency)\(String(format: "%.2f", subscription.amount))/\(subscription.billingCycle.localizedName)"
            )

            Divider().padding(.leading, AppSpacing.md + 36 + AppSpacing.md)

            detailRow(
                icon: "calendar.badge.clock",
                iconColor: AppColors.warning,
                label: NSLocalizedString("detail.nextBilling", comment: ""),
                value: subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted)
            )

            Divider().padding(.leading, AppSpacing.md + 36 + AppSpacing.md)

            detailRow(
                icon: "arrow.triangle.2.circlepath",
                iconColor: AppColors.accent,
                label: NSLocalizedString("detail.cycle", comment: ""),
                value: subscription.billingCycle.localizedName
            )

            Divider().padding(.leading, AppSpacing.md + 36 + AppSpacing.md)

            detailRow(
                icon: "calendar",
                iconColor: Color(hex: "BF5AF2"),
                label: NSLocalizedString("detail.startDate", comment: ""),
                value: subscription.startDate.formatted(date: .abbreviated, time: .omitted)
            )

            Divider().padding(.leading, AppSpacing.md + 36 + AppSpacing.md)

            // Monthly equivalent in display currency
            let monthly = appViewModel.currencyService.convert(
                amount: subscription.monthlyAmount,
                from: subscription.currency,
                to: appViewModel.displayCurrency
            )
            detailRow(
                icon: "chart.bar.fill",
                iconColor: AppColors.accent,
                label: NSLocalizedString("detail.monthlyEquiv", comment: ""),
                value: appViewModel.formatted(monthly)
            )
        }
        .cardStyle()
    }

    private func detailRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))

            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.label)
                .multilineTextAlignment(.trailing)
        }
        .padding(AppSpacing.md)
    }

    // MARK: - Remaining Periods Card
    private var remainingPeriodsCard: some View {
        VStack(spacing: 0) {
            // Remaining count row
            detailRow(
                icon: "hourglass",
                iconColor: AppColors.warning,
                label: NSLocalizedString("detail.remainingPeriods", comment: ""),
                value: String(format: NSLocalizedString("detail.remainingCount", comment: ""), subscription.remainingPeriods)
            )

            if subscription.remainingPeriods > 0 {
                Divider().padding(.leading, AppSpacing.md + 36 + AppSpacing.md)

                // Estimated end date
                let estimatedEnd = computeEstimatedEnd()
                if let endDate = estimatedEnd {
                    detailRow(
                        icon: "calendar.badge.checkmark",
                        iconColor: AppColors.success,
                        label: NSLocalizedString("detail.estimatedEnd", comment: ""),
                        value: endDate.formatted(date: .abbreviated, time: .omitted)
                    )
                }

                // Progress bar
                let totalPaid = max(1, totalPeriodsElapsed())
                let totalAll = Double(totalPaid + subscription.remainingPeriods)
                let progress = Double(totalPaid) / totalAll
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.fill).frame(height: 6)
                        Capsule()
                            .fill(AppColors.warning)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
            }
        }
        .cardStyle()
    }

    private func computeEstimatedEnd() -> Date? {
        guard subscription.remainingPeriods > 0 else { return nil }
        let calendar = Calendar.current
        var date = subscription.nextBillingDate
        for _ in 0..<(subscription.remainingPeriods - 1) {
            switch subscription.billingCycle {
            case .weekly:    date = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
            case .monthly:   date = calendar.date(byAdding: .month, value: 1, to: date) ?? date
            case .quarterly: date = calendar.date(byAdding: .month, value: 3, to: date) ?? date
            case .yearly:    date = calendar.date(byAdding: .year, value: 1, to: date) ?? date
            }
        }
        return date
    }

    private func totalPeriodsElapsed() -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: subscription.startDate, to: Date()).day ?? 0
        return max(1, days / max(1, subscription.billingCycle.daysInterval))
    }

    // MARK: - Notes
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label(NSLocalizedString("detail.notes", comment: ""), systemImage: "note.text")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
                .textCase(.uppercase)

            HStack {
                Text(subscription.notes)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppColors.label)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }

    // MARK: - Management
    private var managementCard: some View {
        VStack(spacing: 0) {
            // Open website
            if let url = URL(string: subscription.websiteURL), !subscription.websiteURL.isEmpty {
                Link(destination: url) {
                    HStack {
                        Text(NSLocalizedString("detail.manageSubscription", comment: ""))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.accent)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(AppColors.accent)
                    }
                    .padding(AppSpacing.md)
                }

                Divider().padding(.leading, AppSpacing.md)
            }

            // Cancel link
            if let templateID = subscription.serviceTemplateID,
               let template = ServiceTemplatesData.template(for: templateID),
               let cancelURL = URL(string: template.cancelURL), !template.cancelURL.isEmpty {
                Link(destination: cancelURL) {
                    HStack {
                        Text(NSLocalizedString("detail.cancelSubscription", comment: ""))
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppColors.danger)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.tertiaryLabel)
                    }
                    .padding(AppSpacing.md)
                }
            } else {
                Button {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        Text(NSLocalizedString("detail.cancelSubscription", comment: ""))
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppColors.danger)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.tertiaryLabel)
                    }
                    .padding(AppSpacing.md)
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
    }

    // MARK: - Delete
    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Text(NSLocalizedString("detail.delete", comment: ""))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppColors.danger.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
    }

    // MARK: - Actions
    private func deleteSubscription() {
        NotificationService.shared.cancelReminder(for: subscription.id)
        modelContext.delete(subscription)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Edit Subscription View
struct EditSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppViewModel.self) private var appViewModel


    let subscription: Subscription

    @State private var name: String
    @State private var amount: String
    @State private var currency: String
    @State private var billingCycle: BillingCycle
    @State private var category: SubscriptionCategory
    @State private var startDate: Date
    @State private var colorHex: String
    @State private var iconEmoji: String
    @State private var notes: String
    @State private var reminderDaysBefore: Int
    @State private var remindOnPaymentDay: Bool
    @State private var websiteURL: String
    @State private var trackRemainingPeriods: Bool
    @State private var remainingPeriods: Int
    @State private var showEmojiPicker = false
    @State private var customImageData: Data?
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showIconOptions = false
    @State private var showPhotoPicker = false

    init(subscription: Subscription) {
        self.subscription = subscription
        _name = State(initialValue: subscription.name)
        _amount = State(initialValue: String(format: "%.2f", subscription.amount))
        _currency = State(initialValue: subscription.currency)
        _billingCycle = State(initialValue: subscription.billingCycle)
        _category = State(initialValue: subscription.category)
        _startDate = State(initialValue: subscription.startDate)
        _colorHex = State(initialValue: subscription.colorHex)
        _iconEmoji = State(initialValue: subscription.iconEmoji)
        _notes = State(initialValue: subscription.notes)
        _reminderDaysBefore = State(initialValue: subscription.reminderDaysBefore)
        _remindOnPaymentDay = State(initialValue: subscription.remindOnPaymentDay)
        _websiteURL = State(initialValue: subscription.websiteURL)
        _customImageData = State(initialValue: subscription.customImageData)
        _trackRemainingPeriods = State(initialValue: subscription.trackRemainingPeriods)
        _remainingPeriods = State(initialValue: max(1, subscription.remainingPeriods))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Button {
                            showIconOptions = true
                        } label: {
                            SubscriptionIconView(
                                emoji: iconEmoji,
                                colorHex: colorHex,
                                imageData: customImageData,
                                size: 60,
                                cornerRadius: AppRadius.lg
                            )
                        }
                        .buttonStyle(.plain)
                        .confirmationDialog(NSLocalizedString("add.icon.chooseTitle", comment: ""), isPresented: $showIconOptions, titleVisibility: .visible) {
                            Button(NSLocalizedString("add.icon.emoji", comment: "")) { showEmojiPicker = true }
                            Button(NSLocalizedString("add.icon.photo", comment: "")) { showPhotoPicker = true }
                            if customImageData != nil {
                                Button(NSLocalizedString("add.icon.removePhoto", comment: ""), role: .destructive) { customImageData = nil }
                            }
                        }
                        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
                        .onChange(of: photoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    customImageData = resizedImageData(data, maxSide: 200)
                                }
                            }
                        }

                        TextField(NSLocalizedString("add.name.placeholder", comment: ""), text: $name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                }

                Section {
                    HStack {
                        Text(CurrencyService.currencySymbols[currency] ?? currency)
                            .foregroundStyle(AppColors.secondaryLabel)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    NavigationLink {
                        BindableCurrencyPickerView(selection: $currency)
                    } label: {
                        HStack {
                            Text(NSLocalizedString("add.currency", comment: ""))
                                .foregroundStyle(AppColors.label)
                            Spacer()
                            HStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.secondaryBackground)
                                        .frame(width: 38, height: 28)
                                    Text(CurrencyService.flagEmoji(for: currency))
                                        .font(.system(size: 18))
                                }
                                Text(currency)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppColors.label)
                                Text(CurrencyService.currencySymbols[currency] ?? "")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppColors.secondaryLabel)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(AppColors.fill)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    Picker(NSLocalizedString("add.billingCycle", comment: ""), selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) {
                            Text($0.localizedName).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: { Text(NSLocalizedString("add.section.pricing", comment: "")) }

                Section {
                    DatePicker(NSLocalizedString("add.firstBill", comment: ""), selection: $startDate, displayedComponents: .date)
                    Picker(NSLocalizedString("add.category", comment: ""), selection: $category) {
                        ForEach(SubscriptionCategory.allCases) { cat in
                            Label(cat.localizedName, systemImage: cat.icon).tag(cat)
                        }
                    }
                } header: { Text(NSLocalizedString("add.section.details", comment: "")) }

                Section {
                    Toggle(NSLocalizedString("add.reminders", comment: ""), isOn: Binding(
                        get: { reminderDaysBefore > 0 },
                        set: { reminderDaysBefore = $0 ? 3 : 0 }
                    ))
                    .tint(AppColors.accent)
                    if reminderDaysBefore > 0 {
                        Stepper(String(format: NSLocalizedString("add.reminderDays", comment: ""), reminderDaysBefore),
                                value: $reminderDaysBefore, in: 1...14)
                    }
                    Toggle(NSLocalizedString("add.remindOnPaymentDay", comment: ""), isOn: $remindOnPaymentDay)
                        .tint(AppColors.accent)
                } header: { Text(NSLocalizedString("add.section.reminders", comment: "")) }

                Section {
                    Toggle(NSLocalizedString("detail.trackRemaining", comment: ""), isOn: $trackRemainingPeriods)
                        .tint(AppColors.accent)
                    if trackRemainingPeriods {
                        Stepper(String(format: NSLocalizedString("detail.remainingCount", comment: ""), remainingPeriods),
                                value: $remainingPeriods, in: 1...360)
                    }
                } header: { Text(NSLocalizedString("detail.remainingPeriods", comment: "")) }

                Section {
                    TextField(NSLocalizedString("add.notes.placeholder", comment: ""), text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    TextField(NSLocalizedString("add.website", comment: ""), text: $websiteURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                } header: { Text(NSLocalizedString("add.section.notes", comment: "")) }
            }
            .navigationTitle(NSLocalizedString("edit.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                        .foregroundStyle(AppColors.secondaryLabel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("common.save", comment: "")) { saveChanges() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiColorPickerView(selectedEmoji: $iconEmoji, selectedColorHex: $colorHex)
            }
        }
    }

    private func saveChanges() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        subscription.name = name
        subscription.amount = amountValue
        subscription.currency = currency
        subscription.billingCycle = billingCycle
        subscription.category = category
        subscription.startDate = startDate
        subscription.nextBillingDate = Subscription.computeNextBillingDate(from: startDate, cycle: billingCycle)
        subscription.colorHex = colorHex
        subscription.iconEmoji = iconEmoji
        subscription.customImageData = customImageData
        subscription.notes = notes
        subscription.reminderDaysBefore = reminderDaysBefore
        subscription.remindOnPaymentDay = remindOnPaymentDay
        subscription.websiteURL = websiteURL
        subscription.trackRemainingPeriods = trackRemainingPeriods
        subscription.remainingPeriods = trackRemainingPeriods ? remainingPeriods : 0
        try? modelContext.save()

        if appViewModel.notificationsEnabled {
            NotificationService.shared.scheduleReminder(for: subscription)
        }
        dismiss()
    }
}
