import Foundation
import SwiftUI

enum SubscriptionCategory: String, CaseIterable, Codable, Identifiable {
    case entertainment = "entertainment"
    case software      = "software"
    case health        = "health"
    case music         = "music"
    case aiTools       = "aiTools"
    case cloudStorage  = "cloudStorage"
    case newsMedia     = "newsMedia"
    case education     = "education"
    case gaming        = "gaming"
    case productivity  = "productivity"
    case finance       = "finance"
    case other         = "other"

    var id: String { rawValue }

    var localizedName: String {
        NSLocalizedString("category.\(rawValue)", comment: "")
    }

    var icon: String {
        switch self {
        case .entertainment: return "tv.fill"
        case .software:      return "laptopcomputer"
        case .health:        return "heart.fill"
        case .music:         return "music.note"
        case .aiTools:       return "cpu.fill"
        case .cloudStorage:  return "icloud.fill"
        case .newsMedia:     return "newspaper.fill"
        case .education:     return "book.fill"
        case .gaming:        return "gamecontroller.fill"
        case .productivity:  return "briefcase.fill"
        case .finance:       return "creditcard.fill"
        case .other:         return "square.grid.2x2.fill"
        }
    }
}

enum BillingCycle: String, CaseIterable, Codable {
    case weekly    = "weekly"
    case monthly   = "monthly"
    case quarterly = "quarterly"
    case yearly    = "yearly"

    var localizedName: String {
        NSLocalizedString("billing.\(rawValue)", comment: "")
    }

    var monthlyMultiplier: Double {
        switch self {
        case .weekly:    return 52.0 / 12.0
        case .monthly:   return 1.0
        case .quarterly: return 1.0 / 3.0
        case .yearly:    return 1.0 / 12.0
        }
    }

    var daysInterval: Int {
        switch self {
        case .weekly:    return 7
        case .monthly:   return 30
        case .quarterly: return 90
        case .yearly:    return 365
        }
    }
}
