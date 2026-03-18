import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - App Colors
struct AppColors {
    // Semantic system colors (auto-adapt to light/dark)
    static var background: Color { Color(UIColor.systemBackground) }
    static var secondaryBackground: Color { Color(UIColor.secondarySystemBackground) }
    static var groupedBackground: Color { Color(UIColor.systemGroupedBackground) }
    static var label: Color { Color(UIColor.label) }
    static var secondaryLabel: Color { Color(UIColor.secondaryLabel) }
    static var tertiaryLabel: Color { Color(UIColor.tertiaryLabel) }
    static var separator: Color { Color(UIColor.separator) }
    static var fill: Color { Color(UIColor.systemFill) }

    // Higher contrast secondary — darker in light mode for better readability
    static var secondaryLabelStrong: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.secondaryLabel
                : UIColor(white: 0.28, alpha: 1)
        })
    }

    // Brand colors
    static let accent = Color(hex: "4A9EFF")
    static let success = Color(hex: "30D158")
    static let warning = Color(hex: "FF9F0A")
    static let danger = Color(hex: "FF453A")
    static let premium = Color(hex: "FFD60A")

    // Category colors
    static func categoryColor(_ category: SubscriptionCategory) -> Color {
        switch category {
        case .entertainment: return Color(hex: "BF5AF2")
        case .software:      return Color(hex: "4A9EFF")
        case .health:        return Color(hex: "32D74B")
        case .music:         return Color(hex: "FF9F0A")
        case .aiTools:       return Color(hex: "FF375F")
        case .cloudStorage:  return Color(hex: "64D2FF")
        case .newsMedia:     return Color(hex: "FF6961")
        case .education:     return Color(hex: "30D158")
        case .gaming:        return Color(hex: "FF6B35")
        case .productivity:  return Color(hex: "00C7BE")
        case .finance:       return Color(hex: "34C759")
        case .other:         return Color(hex: "8E8E93")
        }
    }

    static let chartPalette: [Color] = [
        Color(hex: "4A9EFF"), Color(hex: "BF5AF2"), Color(hex: "32D74B"),
        Color(hex: "FF9F0A"), Color(hex: "FF375F"), Color(hex: "64D2FF"),
        Color(hex: "FF6961"), Color(hex: "30D158"), Color(hex: "FF6B35"),
        Color(hex: "00C7BE")
    ]
}

// MARK: - Spacing & Radius
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 28
}

// MARK: - Card Modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
