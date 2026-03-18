import SwiftUI
import SwiftData
import PhotosUI

struct AddSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppViewModel.self) private var appViewModel

    // Form state
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var currency: String = ""   // initialized onAppear from appViewModel.displayCurrency
    @State private var billingCycle: BillingCycle = .monthly
    @State private var category: SubscriptionCategory = .other
    @State private var startDate: Date = Date()
    @State private var colorHex: String = "4A9EFF"
    @State private var iconEmoji: String = "📦"
    @State private var notes: String = ""
    @State private var reminderDaysBefore: Int = 3
    @State private var remindOnPaymentDay: Bool = false
    @State private var websiteURL: String = ""
    @State private var trackRemainingPeriods: Bool = false
    @State private var remainingPeriods: Int = 12

    // Custom image from gallery
    @State private var customImageData: Data? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showIconOptions = false
    @State private var showPhotoPicker = false

    // Navigation
    @State private var showServicePicker = false
    @State private var showEmojiPicker = false
    @State private var selectedTemplate: ServiceTemplate? = nil

    private var isValid: Bool {
        !name.isEmpty && (Double(amount) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Icon & Name
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

                        VStack(alignment: .leading, spacing: 4) {
                            TextField(NSLocalizedString("add.name.placeholder", comment: ""), text: $name)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))

                            Button(NSLocalizedString("add.pickTemplate", comment: "")) {
                                showServicePicker = true
                            }
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColors.accent)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - Amount
                Section {
                    HStack {
                        Text(CurrencyService.currencySymbols[currency] ?? currency)
                            .font(.system(size: 17, design: .rounded))
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
                    .listRowSeparator(.hidden)
                } header: {
                    Text(NSLocalizedString("add.section.pricing", comment: ""))
                }

                // MARK: - Details
                Section {
                    DatePicker(
                        NSLocalizedString("add.firstBill", comment: ""),
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    Picker(NSLocalizedString("add.category", comment: ""), selection: $category) {
                        ForEach(SubscriptionCategory.allCases) { cat in
                            Label(cat.localizedName, systemImage: cat.icon).tag(cat)
                        }
                    }
                } header: {
                    Text(NSLocalizedString("add.section.details", comment: ""))
                }

                // MARK: - Reminders
                Section {
                    Toggle(NSLocalizedString("add.reminders", comment: ""), isOn: Binding(
                        get: { reminderDaysBefore > 0 },
                        set: { reminderDaysBefore = $0 ? 3 : 0 }
                    ))
                    .tint(AppColors.accent)

                    if reminderDaysBefore > 0 {
                        Stepper(
                            String(format: NSLocalizedString("add.reminderDays", comment: ""), reminderDaysBefore),
                            value: $reminderDaysBefore,
                            in: 1...14
                        )
                    }

                    Toggle(NSLocalizedString("add.remindOnPaymentDay", comment: ""), isOn: $remindOnPaymentDay)
                        .tint(AppColors.accent)
                } header: {
                    Text(NSLocalizedString("add.section.reminders", comment: ""))
                }

                // MARK: - Remaining Periods
                Section {
                    Toggle(NSLocalizedString("detail.trackRemaining", comment: ""), isOn: $trackRemainingPeriods)
                        .tint(AppColors.accent)
                    if trackRemainingPeriods {
                        Stepper(
                            String(format: NSLocalizedString("detail.remainingCount", comment: ""), remainingPeriods),
                            value: $remainingPeriods,
                            in: 1...360
                        )
                    }
                } header: {
                    Text(NSLocalizedString("detail.remainingPeriods", comment: ""))
                }

                // MARK: - Color
                Section {
                    colorPicker
                } header: {
                    Text(NSLocalizedString("add.section.color", comment: ""))
                }

                // MARK: - Notes
                Section {
                    TextField(
                        NSLocalizedString("add.notes.placeholder", comment: ""),
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    if !websiteURL.isEmpty || selectedTemplate != nil {
                        TextField(NSLocalizedString("add.website", comment: ""), text: $websiteURL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                } header: {
                    Text(NSLocalizedString("add.section.notes", comment: ""))
                }

                // MARK: - Cancel Info (from template)
                if let template = selectedTemplate, !template.howToCancel.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(NSLocalizedString("add.howToCancel", comment: ""), systemImage: "xmark.circle.fill")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.danger)

                            Text(template.howToCancel)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(AppColors.secondaryLabel)

                            if let cancelURL = URL(string: template.cancelURL), !template.cancelURL.isEmpty {
                                Link(NSLocalizedString("add.openBillingPortal", comment: ""), destination: cancelURL)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("add.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if currency.isEmpty {
                    currency = appViewModel.displayCurrency
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.secondaryLabel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        saveSubscription()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isValid ? AppColors.accent : AppColors.tertiaryLabel)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showServicePicker) {
                ServicePickerView { template in
                    applyTemplate(template)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiColorPickerView(
                    selectedEmoji: $iconEmoji,
                    selectedColorHex: $colorHex
                )
            }
        }
    }

    // MARK: - Color Picker
    private var colorPicker: some View {
        let colors = [
            "4A9EFF", "BF5AF2", "32D74B", "FF9F0A", "FF375F",
            "64D2FF", "FF6961", "FF6B35", "00C7BE", "8E8E93"
        ]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(colors, id: \.self) { hex in
                    Button {
                        colorHex = hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if colorHex == hex {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Actions
    private func applyTemplate(_ template: ServiceTemplate) {
        selectedTemplate = template
        name = template.name
        iconEmoji = template.emoji
        colorHex = template.colorHex
        category = template.category
        websiteURL = template.websiteURL

        if let plan = template.defaultPlan {
            amount = String(format: "%.2f", plan.price)
            currency = plan.currency
            billingCycle = plan.billingCycle
        }
    }

    private func saveSubscription() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }

        let subscription = Subscription(
            name: name,
            amount: amountValue,
            currency: currency,
            billingCycle: billingCycle,
            category: category,
            startDate: startDate,
            colorHex: colorHex,
            iconEmoji: iconEmoji,
            serviceTemplateID: selectedTemplate?.id,
            notes: notes,
            reminderDaysBefore: reminderDaysBefore,
            remindOnPaymentDay: remindOnPaymentDay,
            websiteURL: websiteURL,
            trackRemainingPeriods: trackRemainingPeriods,
            remainingPeriods: trackRemainingPeriods ? remainingPeriods : 0
        )

        subscription.customImageData = customImageData
        modelContext.insert(subscription)
        try? modelContext.save()

        if appViewModel.notificationsEnabled {
            NotificationService.shared.scheduleReminder(for: subscription)
        }

        dismiss()
    }
}

// MARK: - Emoji & Color Picker Sheet
struct EmojiColorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String
    @Binding var selectedColorHex: String

    let emojis = [
        // Streaming & Entertainment
        "📺", "🎬", "🎭", "🍿", "📡", "🎞️", "🎪", "🎠",
        // Music & Audio
        "🎵", "🎶", "🎸", "🎤", "🎧", "🎷", "🎹", "🥁",
        // Gaming
        "🎮", "🕹️", "👾", "🎯", "🏆", "🎲", "🃏", "🧩",
        // Tech & Software
        "💻", "📱", "🖥️", "⌨️", "🖱️", "🤖", "⚙️", "🔧",
        // Cloud & Storage
        "☁️", "💾", "🗂️", "📂", "🗃️", "💿", "🔌", "🛰️",
        // AI & Productivity
        "🧠", "✨", "⚡", "🔮", "💡", "🎯", "📊", "📈",
        // Design & Creative
        "🎨", "🖌️", "✏️", "📐", "🖼️", "🪄", "🎭", "🌈",
        // News & Reading
        "📰", "📚", "📖", "📜", "🗞️", "📓", "✍️", "🔍",
        // Health & Fitness
        "🏃", "🧘", "💪", "🏋️", "🚴", "🧬", "🩺", "💊",
        // Finance & Business
        "💼", "💰", "💳", "📋", "🏦", "💹", "🤝", "📌",
        // Communication
        "💬", "📧", "📞", "📹", "🔔", "📢", "✉️", "🗣️",
        // General
        "📦", "🌍", "🔐", "🔑", "⭐", "🏠", "🚀", "🌟",
    ]

    let colors = [
        "E50914", "1DB954", "006E99", "FF0000", "5822B4",
        "00A8E1", "000000", "107C10", "003087", "E4000F",
        "4A9EFF", "BF5AF2", "32D74B", "FF9F0A", "FF375F",
        "64D2FF", "FF6961", "FF6B35", "00C7BE", "8E8E93",
        "10A37F", "CC785C", "6E40C9", "0061FF", "D32D27",
        "4285F4", "D83B01", "0A66C2", "F24E1E", "FC4C02",
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(NSLocalizedString("emojiPicker.emoji", comment: "")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(minimum: 44)), count: 8), spacing: 8) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(emoji == selectedEmoji
                                            ? AppColors.accent.opacity(0.18)
                                            : AppColors.secondaryBackground)
                                        .frame(width: 40, height: 40)
                                    if emoji == selectedEmoji {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(AppColors.accent, lineWidth: 1.5)
                                            .frame(width: 40, height: 40)
                                    }
                                    Text(emoji)
                                        .font(.system(size: 24))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(NSLocalizedString("emojiPicker.color", comment: "")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if selectedColorHex == hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(NSLocalizedString("emojiPicker.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("common.done", comment: "")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accent)
                }
            }
        }
    }
}

// MARK: - Subscription Icon View (emoji or custom photo)
struct SubscriptionIconView: View {
    let emoji: String
    let colorHex: String
    let imageData: Data?
    var size: CGFloat = 46
    var cornerRadius: CGFloat = AppRadius.md

    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.52))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: colorHex).opacity(0.15))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            if imageData == nil {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(hex: colorHex).opacity(0.3), lineWidth: 1)
            }
        }
    }
}

// MARK: - Image resize helper
func resizedImageData(_ data: Data, maxSide: CGFloat) -> Data? {
    guard let uiImage = UIImage(data: data) else { return data }
    let scale = min(maxSide / uiImage.size.width, maxSide / uiImage.size.height, 1.0)
    let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let resized = renderer.image { _ in uiImage.draw(in: CGRect(origin: .zero, size: newSize)) }
    return resized.jpegData(compressionQuality: 0.8)
}
