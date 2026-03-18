import Foundation
import SwiftUI

// MARK: - Currency Service
@Observable
final class CurrencyService {

    var rates: [String: Double] = ["USD": 1.0]
    var lastUpdated: Date? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    static let supportedCurrencies: [String] = [
        "USD", "EUR", "GBP", "TRY", "JPY", "CAD", "AUD", "CHF",
        "CNY", "KRW", "BRL", "INR", "MXN", "SGD", "SEK", "NOK",
        "DKK", "PLN", "CZK", "HUF", "RON", "BGN", "HRK", "RUB",
        "UAH", "AED", "SAR", "ILS", "THB", "MYR", "IDR", "PHP", "VND"
    ]

    static let currencySymbols: [String: String] = [
        "USD": "$",   "EUR": "€",    "GBP": "£",   "TRY": "₺",  "JPY": "¥",
        "CAD": "CA$", "AUD": "A$",   "CHF": "Fr",  "CNY": "¥",  "KRW": "₩",
        "BRL": "R$",  "INR": "₹",   "MXN": "MX$", "SGD": "S$", "SEK": "kr",
        "NOK": "kr",  "DKK": "kr",   "PLN": "zł",  "CZK": "Kč", "HUF": "Ft",
        "RON": "lei", "BGN": "лв",   "HRK": "kn",  "RUB": "₽",  "UAH": "₴",
        "AED": "د.إ", "SAR": "﷼",   "ILS": "₪",   "THB": "฿",  "MYR": "RM",
        "IDR": "Rp",  "PHP": "₱",   "VND": "₫"
    ]

    init() {
        loadCachedRates()
    }

    // MARK: - Fetch
    func fetchRatesIfNeeded() async {
        // Refresh if no rates or last update > 6 hours ago
        if let lastUpdated, Date().timeIntervalSince(lastUpdated) < 6 * 3600, rates.count > 1 {
            return
        }
        await fetchRates()
    }

    func fetchRates() async {
        isLoading = true
        errorMessage = nil
        do {
            let url = URL(string: "https://open.er-api.com/v6/latest/USD")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            rates = response.rates
            rates["USD"] = 1.0
            lastUpdated = Date()
            saveRatesToCache()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Conversion
    func convert(amount: Double, from: String, to: String) -> Double {
        guard from != to else { return amount }
        let fromRate = rates[from] ?? 1.0
        let toRate = rates[to] ?? 1.0
        return amount / fromRate * toRate
    }

    func convertToUSD(amount: Double, from currency: String) -> Double {
        convert(amount: amount, from: currency, to: "USD")
    }

    // Format an amount with its currency symbol
    func formatted(amount: Double, currency: String) -> String {
        let symbol = Self.currencySymbols[currency] ?? currency
        if amount == 0 { return "\(symbol)0" }
        if amount < 10 {
            return String(format: "\(symbol)%.2f", amount)
        }
        return String(format: "\(symbol)%.2f", amount)
    }

    // MARK: - Cache
    private let cacheKey = "currency_rates_cache"
    private let cacheDateKey = "currency_rates_date"

    private func saveRatesToCache() {
        if let data = try? JSONEncoder().encode(rates) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheDateKey)
        }
    }

    private func loadCachedRates() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            rates = decoded
            lastUpdated = UserDefaults.standard.object(forKey: cacheDateKey) as? Date
        }
    }
}

// MARK: - API Response Model
private struct ExchangeRateResponse: Decodable {
    let rates: [String: Double]
}

// MARK: - Currency Display Helper
extension CurrencyService {
    static let currencyNames: [String: String] = [
        "USD": "US Dollar",        "EUR": "Euro",             "GBP": "British Pound",
        "TRY": "Turkish Lira",     "JPY": "Japanese Yen",     "CAD": "Canadian Dollar",
        "AUD": "Australian Dollar","CHF": "Swiss Franc",      "CNY": "Chinese Yuan",
        "KRW": "South Korean Won", "BRL": "Brazilian Real",   "INR": "Indian Rupee",
        "MXN": "Mexican Peso",     "SGD": "Singapore Dollar", "SEK": "Swedish Krona",
        "NOK": "Norwegian Krone",  "DKK": "Danish Krone",     "PLN": "Polish Złoty",
        "CZK": "Czech Koruna",     "HUF": "Hungarian Forint", "RON": "Romanian Leu",
        "BGN": "Bulgarian Lev",    "HRK": "Croatian Kuna",    "RUB": "Russian Ruble",
        "UAH": "Ukrainian Hryvnia","AED": "UAE Dirham",       "SAR": "Saudi Riyal",
        "ILS": "Israeli Shekel",   "THB": "Thai Baht",        "MYR": "Malaysian Ringgit",
        "IDR": "Indonesian Rupiah","PHP": "Philippine Peso",  "VND": "Vietnamese Dong"
    ]

    static func symbol(for currency: String) -> String {
        currencySymbols[currency] ?? currency
    }

    static func flagEmoji(for currency: String) -> String {
        let flags: [String: String] = [
            "USD": "🇺🇸", "EUR": "🇪🇺", "GBP": "🇬🇧", "TRY": "🇹🇷",
            "JPY": "🇯🇵", "CAD": "🇨🇦", "AUD": "🇦🇺", "CHF": "🇨🇭",
            "CNY": "🇨🇳", "KRW": "🇰🇷", "BRL": "🇧🇷", "INR": "🇮🇳",
            "MXN": "🇲🇽", "SGD": "🇸🇬", "SEK": "🇸🇪", "NOK": "🇳🇴",
            "DKK": "🇩🇰", "PLN": "🇵🇱", "CZK": "🇨🇿", "HUF": "🇭🇺",
            "RON": "🇷🇴", "BGN": "🇧🇬", "HRK": "🇭🇷", "RUB": "🇷🇺",
            "UAH": "🇺🇦", "AED": "🇦🇪", "SAR": "🇸🇦", "ILS": "🇮🇱",
            "THB": "🇹🇭", "MYR": "🇲🇾", "IDR": "🇮🇩", "PHP": "🇵🇭",
            "VND": "🇻🇳"
        ]
        return flags[currency] ?? "🌍"
    }
}
