import SwiftUI
import Charts

// MARK: - Donut Chart
struct DonutChartView: View {
    let breakdowns: [AppViewModel.CategoryBreakdown]
    let centerLabel: String
    let centerValue: String

    var body: some View {
        ZStack {
            Chart(breakdowns) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(AppColors.categoryColor(item.category))
            }
            .frame(width: 200, height: 200)

            // Center text
            VStack(spacing: 2) {
                Text(centerLabel)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.secondaryLabel)
                    .textCase(.uppercase)
                    .kerning(0.5)

                Text(centerValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.label)
            }
        }
    }
}
