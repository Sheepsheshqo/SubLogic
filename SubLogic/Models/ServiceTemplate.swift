import Foundation

// MARK: - Service Plan
struct ServicePlan: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Double
    let currency: String
    let region: String      // e.g. "US", "TR", "EU"
    let billingCycle: BillingCycle

    init(id: String? = nil, name: String, price: Double, currency: String, region: String, billingCycle: BillingCycle = .monthly) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.price = price
        self.currency = currency
        self.region = region
        self.billingCycle = billingCycle
    }
}

// MARK: - Service Template
struct ServiceTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SubscriptionCategory
    let emoji: String
    let colorHex: String
    let websiteURL: String
    let plans: [ServicePlan]
    let cancelURL: String
    let howToCancel: String

    // Returns plans for a given region (falls back to "US")
    func plans(forRegion region: String) -> [ServicePlan] {
        let regional = plans.filter { $0.region == region }
        if regional.isEmpty {
            return plans.filter { $0.region == "US" }
        }
        return regional
    }

    // Default (cheapest US monthly) plan
    var defaultPlan: ServicePlan? {
        plans
            .filter { $0.region == "US" && $0.billingCycle == .monthly }
            .sorted { $0.price < $1.price }
            .first ?? plans.first
    }
}
