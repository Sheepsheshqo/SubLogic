import SwiftUI

struct ServicePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (ServiceTemplate) -> Void

    @State private var searchText = ""
    @State private var selectedCategory: SubscriptionCategory? = nil

    private var filtered: [ServiceTemplate] {
        var results = ServiceTemplatesData.all
        if let cat = selectedCategory {
            results = results.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            results = results.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return results.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                categoryFilterBar
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.secondaryBackground)

                Divider()

                // Results
                if filtered.isEmpty {
                    emptyState
                } else {
                    serviceList
                }
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(NSLocalizedString("servicePicker.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: NSLocalizedString("servicePicker.search", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.secondaryLabel)
                }
            }
        }
    }

    // MARK: - Category Filter
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                // All
                categoryChip(nil)

                ForEach(SubscriptionCategory.allCases) { cat in
                    categoryChip(cat)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private func categoryChip(_ category: SubscriptionCategory?) -> some View {
        let isSelected = selectedCategory == category
        let label = category?.localizedName ?? NSLocalizedString("category.all", comment: "")
        let color = category.map { AppColors.categoryColor($0) } ?? AppColors.accent

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedCategory = isSelected ? nil : category
            }
        } label: {
            HStack(spacing: 4) {
                if let cat = category {
                    Image(systemName: cat.icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.2) : AppColors.fill)
            .foregroundStyle(isSelected ? color : AppColors.secondaryLabel)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Service List
    private var serviceList: some View {
        List(filtered) { template in
            Button {
                onSelect(template)
                dismiss()
            } label: {
                ServiceTemplateRow(template: template)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.tertiaryLabel)
                .padding(.top, AppSpacing.xxl)
            Text(NSLocalizedString("servicePicker.noResults", comment: ""))
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Template Row
struct ServiceTemplateRow: View {
    let template: ServiceTemplate

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(template.emoji)
                .font(.system(size: 24))
                .frame(width: 48, height: 48)
                .background(Color(hex: template.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: 3) {
                Text(template.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.label)
                Text(template.category.localizedName)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            if let plan = template.defaultPlan {
                VStack(alignment: .trailing, spacing: 1) {
                    let symbol = CurrencyService.currencySymbols[plan.currency] ?? plan.currency
                    Text("\(symbol)\(String(format: "%.2f", plan.price))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.label)
                    Text(plan.billingCycle.localizedName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.secondaryLabel)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.tertiaryLabel)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}
