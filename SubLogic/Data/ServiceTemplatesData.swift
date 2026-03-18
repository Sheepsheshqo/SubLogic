import Foundation

// MARK: - All Service Templates
struct ServiceTemplatesData {

    static let all: [ServiceTemplate] = streaming + music + aiTools + cloudStorage +
        productivity + gaming + newsMedia + health + education + developer + other

    // MARK: - Streaming
    static let streaming: [ServiceTemplate] = [
        ServiceTemplate(
            id: "netflix",
            name: "Netflix",
            category: .entertainment,
            emoji: "🎬",
            colorHex: "E50914",
            websiteURL: "https://netflix.com",
            plans: [
                ServicePlan(name: "Standard with Ads", price: 6.99, currency: "USD", region: "US"),
                ServicePlan(name: "Standard", price: 15.49, currency: "USD", region: "US"),
                ServicePlan(name: "Premium 4K", price: 22.99, currency: "USD", region: "US"),
                ServicePlan(name: "Standard with Ads", price: 99.90, currency: "TRY", region: "TR"),
                ServicePlan(name: "Standard", price: 219.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Premium", price: 299.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Standard", price: 13.99, currency: "EUR", region: "EU"),
                ServicePlan(name: "Premium", price: 19.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://netflix.com/cancelplan",
            howToCancel: "Account → Membership → Cancel Membership"
        ),
        ServiceTemplate(
            id: "disney_plus",
            name: "Disney+",
            category: .entertainment,
            emoji: "🏰",
            colorHex: "006E99",
            websiteURL: "https://disneyplus.com",
            plans: [
                ServicePlan(name: "Basic", price: 7.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium", price: 13.99, currency: "USD", region: "US"),
                ServicePlan(name: "Basic Yearly", price: 79.99, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "Standard", price: 109.90, currency: "TRY", region: "TR"),
                ServicePlan(name: "Standard", price: 8.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://disneyplus.com/account",
            howToCancel: "Account → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "hbo_max",
            name: "Max (HBO Max)",
            category: .entertainment,
            emoji: "🎭",
            colorHex: "5822B4",
            websiteURL: "https://max.com",
            plans: [
                ServicePlan(name: "With Ads", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Ad-Free", price: 15.99, currency: "USD", region: "US"),
                ServicePlan(name: "Ultimate 4K", price: 19.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://max.com/account",
            howToCancel: "Account → Subscription → Cancel Plan"
        ),
        ServiceTemplate(
            id: "amazon_prime",
            name: "Amazon Prime",
            category: .entertainment,
            emoji: "📦",
            colorHex: "00A8E1",
            websiteURL: "https://primevideo.com",
            plans: [
                ServicePlan(name: "Monthly", price: 14.99, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 139.00, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "Monthly", price: 69.90, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://amazon.com/mc",
            howToCancel: "Account & Lists → Prime Membership → End Membership"
        ),
        ServiceTemplate(
            id: "apple_tv",
            name: "Apple TV+",
            category: .entertainment,
            emoji: "🍎",
            colorHex: "000000",
            websiteURL: "https://tv.apple.com",
            plans: [
                ServicePlan(name: "Monthly", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Monthly", price: 64.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Monthly", price: 8.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Cancel"
        ),
        ServiceTemplate(
            id: "paramount_plus",
            name: "Paramount+",
            category: .entertainment,
            emoji: "⭐",
            colorHex: "0064FF",
            websiteURL: "https://paramountplus.com",
            plans: [
                ServicePlan(name: "Essential", price: 5.99, currency: "USD", region: "US"),
                ServicePlan(name: "With SHOWTIME", price: 11.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://paramountplus.com/account",
            howToCancel: "Account → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "crunchyroll",
            name: "Crunchyroll",
            category: .entertainment,
            emoji: "🍣",
            colorHex: "F47521",
            websiteURL: "https://crunchyroll.com",
            plans: [
                ServicePlan(name: "Fan", price: 7.99, currency: "USD", region: "US"),
                ServicePlan(name: "Mega Fan", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Ultimate Fan", price: 14.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://crunchyroll.com/account",
            howToCancel: "Account → Membership → Cancel"
        ),
        ServiceTemplate(
            id: "youtube_premium",
            name: "YouTube Premium",
            category: .entertainment,
            emoji: "▶️",
            colorHex: "FF0000",
            websiteURL: "https://youtube.com/premium",
            plans: [
                ServicePlan(name: "Individual", price: 13.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 22.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual", price: 49.90, currency: "TRY", region: "TR"),
                ServicePlan(name: "Individual", price: 11.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://youtube.com/paid_memberships",
            howToCancel: "YouTube → Profile → Paid Memberships → Cancel"
        ),
        ServiceTemplate(
            id: "apple_one",
            name: "Apple One",
            category: .entertainment,
            emoji: "🎵",
            colorHex: "555555",
            websiteURL: "https://apple.com/apple-one",
            plans: [
                ServicePlan(name: "Individual", price: 19.95, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 25.95, currency: "USD", region: "US"),
                ServicePlan(name: "Premier", price: 37.95, currency: "USD", region: "US"),
                ServicePlan(name: "Individual", price: 189.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Apple One → Cancel"
        ),
    ]

    // MARK: - Music
    static let music: [ServiceTemplate] = [
        ServiceTemplate(
            id: "spotify",
            name: "Spotify",
            category: .music,
            emoji: "🎵",
            colorHex: "1DB954",
            websiteURL: "https://spotify.com",
            plans: [
                ServicePlan(name: "Premium Individual", price: 11.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium Duo", price: 16.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium Family", price: 19.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium", price: 49.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Premium", price: 11.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://spotify.com/account",
            howToCancel: "Account → Subscription → Cancel Premium"
        ),
        ServiceTemplate(
            id: "apple_music",
            name: "Apple Music",
            category: .music,
            emoji: "🎶",
            colorHex: "FC3C44",
            websiteURL: "https://music.apple.com",
            plans: [
                ServicePlan(name: "Individual", price: 10.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 16.99, currency: "USD", region: "US"),
                ServicePlan(name: "Student", price: 5.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual", price: 54.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Individual", price: 10.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Apple Music → Cancel"
        ),
        ServiceTemplate(
            id: "tidal",
            name: "TIDAL",
            category: .music,
            emoji: "🌊",
            colorHex: "000000",
            websiteURL: "https://tidal.com",
            plans: [
                ServicePlan(name: "HiFi", price: 10.99, currency: "USD", region: "US"),
                ServicePlan(name: "HiFi Plus", price: 19.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://tidal.com/account",
            howToCancel: "Account → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "youtube_music",
            name: "YouTube Music",
            category: .music,
            emoji: "🎼",
            colorHex: "FF0000",
            websiteURL: "https://music.youtube.com",
            plans: [
                ServicePlan(name: "Premium", price: 10.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 16.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium", price: 39.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://music.youtube.com/paid_memberships",
            howToCancel: "Profile → Paid Memberships → Cancel"
        ),
        ServiceTemplate(
            id: "deezer",
            name: "Deezer",
            category: .music,
            emoji: "🎸",
            colorHex: "A238FF",
            websiteURL: "https://deezer.com",
            plans: [
                ServicePlan(name: "Premium", price: 10.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 17.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium", price: 9.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://deezer.com/account",
            howToCancel: "Account → Subscription → Cancel"
        ),
    ]

    // MARK: - AI & Tools
    static let aiTools: [ServiceTemplate] = [
        ServiceTemplate(
            id: "chatgpt_plus",
            name: "ChatGPT Plus",
            category: .aiTools,
            emoji: "🤖",
            colorHex: "10A37F",
            websiteURL: "https://openai.com/chatgpt",
            plans: [
                ServicePlan(name: "Plus", price: 20.00, currency: "USD", region: "US"),
                ServicePlan(name: "Team", price: 25.00, currency: "USD", region: "US"),
                ServicePlan(name: "Plus", price: 699.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Plus", price: 20.00, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://platform.openai.com/account/billing",
            howToCancel: "ChatGPT → Profile → My Plan → Cancel Plan"
        ),
        ServiceTemplate(
            id: "claude_pro",
            name: "Claude Pro",
            category: .aiTools,
            emoji: "🧠",
            colorHex: "CC785C",
            websiteURL: "https://claude.ai",
            plans: [
                ServicePlan(name: "Pro", price: 20.00, currency: "USD", region: "US"),
                ServicePlan(name: "Pro", price: 19.00, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://claude.ai/settings",
            howToCancel: "Settings → Billing → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "github_copilot",
            name: "GitHub Copilot",
            category: .aiTools,
            emoji: "💻",
            colorHex: "6E40C9",
            websiteURL: "https://github.com/features/copilot",
            plans: [
                ServicePlan(name: "Individual", price: 10.00, currency: "USD", region: "US"),
                ServicePlan(name: "Business", price: 19.00, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 100.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://github.com/settings/copilot",
            howToCancel: "Settings → Copilot → Cancel Plan"
        ),
        ServiceTemplate(
            id: "midjourney",
            name: "Midjourney",
            category: .aiTools,
            emoji: "🎨",
            colorHex: "000000",
            websiteURL: "https://midjourney.com",
            plans: [
                ServicePlan(name: "Basic", price: 10.00, currency: "USD", region: "US"),
                ServicePlan(name: "Standard", price: 30.00, currency: "USD", region: "US"),
                ServicePlan(name: "Pro", price: 60.00, currency: "USD", region: "US"),
                ServicePlan(name: "Mega", price: 120.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://midjourney.com/account",
            howToCancel: "/subscribe command in Discord → Manage → Cancel Plan"
        ),
        ServiceTemplate(
            id: "perplexity",
            name: "Perplexity Pro",
            category: .aiTools,
            emoji: "🔍",
            colorHex: "20808D",
            websiteURL: "https://perplexity.ai",
            plans: [
                ServicePlan(name: "Pro", price: 20.00, currency: "USD", region: "US"),
                ServicePlan(name: "Pro Yearly", price: 200.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://perplexity.ai/settings",
            howToCancel: "Settings → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "notion_ai",
            name: "Notion AI",
            category: .aiTools,
            emoji: "📝",
            colorHex: "000000",
            websiteURL: "https://notion.so",
            plans: [
                ServicePlan(name: "AI Add-on", price: 10.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://notion.so/settings",
            howToCancel: "Settings → Plans → AI Add-on → Cancel"
        ),
    ]

    // MARK: - Cloud Storage
    static let cloudStorage: [ServiceTemplate] = [
        ServiceTemplate(
            id: "icloud_plus",
            name: "iCloud+",
            category: .cloudStorage,
            emoji: "☁️",
            colorHex: "3478F6",
            websiteURL: "https://apple.com/icloud",
            plans: [
                ServicePlan(name: "50 GB", price: 0.99, currency: "USD", region: "US"),
                ServicePlan(name: "200 GB", price: 2.99, currency: "USD", region: "US"),
                ServicePlan(name: "2 TB", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "50 GB", price: 6.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "200 GB", price: 20.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "2 TB", price: 69.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "50 GB", price: 0.99, currency: "EUR", region: "EU"),
                ServicePlan(name: "200 GB", price: 2.99, currency: "EUR", region: "EU"),
                ServicePlan(name: "2 TB", price: 9.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → iCloud → Manage Storage → Change Plan"
        ),
        ServiceTemplate(
            id: "google_one",
            name: "Google One",
            category: .cloudStorage,
            emoji: "🔵",
            colorHex: "4285F4",
            websiteURL: "https://one.google.com",
            plans: [
                ServicePlan(name: "100 GB", price: 1.99, currency: "USD", region: "US"),
                ServicePlan(name: "200 GB", price: 2.99, currency: "USD", region: "US"),
                ServicePlan(name: "2 TB", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "100 GB", price: 29.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "200 GB", price: 44.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "2 TB", price: 139.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://one.google.com/storage",
            howToCancel: "Google One app → Settings → Cancel Membership"
        ),
        ServiceTemplate(
            id: "dropbox",
            name: "Dropbox",
            category: .cloudStorage,
            emoji: "📂",
            colorHex: "0061FF",
            websiteURL: "https://dropbox.com",
            plans: [
                ServicePlan(name: "Plus (2 TB)", price: 11.99, currency: "USD", region: "US"),
                ServicePlan(name: "Professional", price: 19.99, currency: "USD", region: "US"),
                ServicePlan(name: "Plus Yearly", price: 119.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://dropbox.com/account/plan",
            howToCancel: "Account → Plan → Cancel Plan"
        ),
        ServiceTemplate(
            id: "onedrive",
            name: "OneDrive",
            category: .cloudStorage,
            emoji: "🔷",
            colorHex: "0078D4",
            websiteURL: "https://onedrive.live.com",
            plans: [
                ServicePlan(name: "100 GB", price: 1.99, currency: "USD", region: "US"),
                ServicePlan(name: "Microsoft 365 Personal (1 TB)", price: 6.99, currency: "USD", region: "US"),
                ServicePlan(name: "Microsoft 365 Family (6 TB)", price: 9.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://account.microsoft.com/services",
            howToCancel: "Microsoft Account → Services → Cancel"
        ),
    ]

    // MARK: - Productivity & Software
    static let productivity: [ServiceTemplate] = [
        ServiceTemplate(
            id: "microsoft_365",
            name: "Microsoft 365",
            category: .productivity,
            emoji: "📊",
            colorHex: "D83B01",
            websiteURL: "https://microsoft365.com",
            plans: [
                ServicePlan(name: "Personal", price: 6.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Personal Yearly", price: 69.99, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "Personal", price: 219.99, currency: "TRY", region: "TR"),
                ServicePlan(name: "Personal", price: 7.00, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://account.microsoft.com/services",
            howToCancel: "Microsoft Account → Services → Microsoft 365 → Cancel"
        ),
        ServiceTemplate(
            id: "adobe_cc",
            name: "Adobe Creative Cloud",
            category: .software,
            emoji: "✨",
            colorHex: "FF0000",
            websiteURL: "https://creative.adobe.com",
            plans: [
                ServicePlan(name: "Photography (20 GB)", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "All Apps", price: 59.99, currency: "USD", region: "US"),
                ServicePlan(name: "Single App", price: 20.99, currency: "USD", region: "US"),
                ServicePlan(name: "All Apps", price: 42.99, currency: "EUR", region: "EU"),
            ],
            cancelURL: "https://account.adobe.com/plans",
            howToCancel: "Adobe Account → Plans → Cancel Plan"
        ),
        ServiceTemplate(
            id: "notion",
            name: "Notion",
            category: .productivity,
            emoji: "📋",
            colorHex: "000000",
            websiteURL: "https://notion.so",
            plans: [
                ServicePlan(name: "Plus", price: 10.00, currency: "USD", region: "US"),
                ServicePlan(name: "Business", price: 18.00, currency: "USD", region: "US"),
                ServicePlan(name: "Plus Yearly", price: 96.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://notion.so/settings",
            howToCancel: "Settings → Plans → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "figma",
            name: "Figma",
            category: .productivity,
            emoji: "🎯",
            colorHex: "F24E1E",
            websiteURL: "https://figma.com",
            plans: [
                ServicePlan(name: "Professional", price: 15.00, currency: "USD", region: "US"),
                ServicePlan(name: "Organization", price: 45.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://figma.com/settings",
            howToCancel: "Settings → Plans → Downgrade to Starter"
        ),
        ServiceTemplate(
            id: "slack",
            name: "Slack",
            category: .productivity,
            emoji: "💬",
            colorHex: "4A154B",
            websiteURL: "https://slack.com",
            plans: [
                ServicePlan(name: "Pro", price: 8.75, currency: "USD", region: "US"),
                ServicePlan(name: "Business+", price: 15.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://app.slack.com/billing",
            howToCancel: "Settings → Billing → Cancel Plan"
        ),
        ServiceTemplate(
            id: "zoom",
            name: "Zoom",
            category: .productivity,
            emoji: "📹",
            colorHex: "2D8CFF",
            websiteURL: "https://zoom.us",
            plans: [
                ServicePlan(name: "Pro", price: 14.99, currency: "USD", region: "US"),
                ServicePlan(name: "Business", price: 21.99, currency: "USD", region: "US"),
                ServicePlan(name: "Pro Yearly", price: 149.90, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://zoom.us/account/billing",
            howToCancel: "Account → Billing → Cancel Plan"
        ),
        ServiceTemplate(
            id: "1password",
            name: "1Password",
            category: .productivity,
            emoji: "🔐",
            colorHex: "1A8CFF",
            websiteURL: "https://1password.com",
            plans: [
                ServicePlan(name: "Individual", price: 2.99, currency: "USD", region: "US"),
                ServicePlan(name: "Families", price: 4.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual Yearly", price: 35.88, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://my.1password.com/profile#billing",
            howToCancel: "Profile → Billing → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "linear",
            name: "Linear",
            category: .productivity,
            emoji: "📐",
            colorHex: "5E6AD2",
            websiteURL: "https://linear.app",
            plans: [
                ServicePlan(name: "Business", price: 12.00, currency: "USD", region: "US"),
                ServicePlan(name: "Enterprise", price: 16.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://linear.app/settings/billing",
            howToCancel: "Settings → Billing → Cancel Plan"
        ),
    ]

    // MARK: - Gaming
    static let gaming: [ServiceTemplate] = [
        ServiceTemplate(
            id: "xbox_gamepass",
            name: "Xbox Game Pass",
            category: .gaming,
            emoji: "🎮",
            colorHex: "107C10",
            websiteURL: "https://xbox.com/gamepass",
            plans: [
                ServicePlan(name: "Game Pass Core", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Game Pass PC", price: 14.99, currency: "USD", region: "US"),
                ServicePlan(name: "Game Pass Ultimate", price: 19.99, currency: "USD", region: "US"),
                ServicePlan(name: "Game Pass Ultimate", price: 249.90, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://account.microsoft.com/services",
            howToCancel: "Microsoft Account → Services → Xbox Game Pass → Cancel"
        ),
        ServiceTemplate(
            id: "ps_plus",
            name: "PlayStation Plus",
            category: .gaming,
            emoji: "🕹️",
            colorHex: "003087",
            websiteURL: "https://playstation.com/ps-plus",
            plans: [
                ServicePlan(name: "Essential", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Extra", price: 14.99, currency: "USD", region: "US"),
                ServicePlan(name: "Premium", price: 17.99, currency: "USD", region: "US"),
                ServicePlan(name: "Essential Yearly", price: 79.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://playstation.com/account",
            howToCancel: "PSN Account → PlayStation Plus → Turn Off Auto-Renew"
        ),
        ServiceTemplate(
            id: "nintendo_online",
            name: "Nintendo Switch Online",
            category: .gaming,
            emoji: "🔴",
            colorHex: "E4000F",
            websiteURL: "https://nintendo.com/switch/online",
            plans: [
                ServicePlan(name: "Individual", price: 3.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 7.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual + Expansion Pack", price: 4.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual Yearly", price: 19.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://accounts.nintendo.com",
            howToCancel: "Nintendo Account → Services → Nintendo Switch Online → Deactivate"
        ),
        ServiceTemplate(
            id: "apple_arcade",
            name: "Apple Arcade",
            category: .gaming,
            emoji: "🕹️",
            colorHex: "000000",
            websiteURL: "https://apple.com/apple-arcade",
            plans: [
                ServicePlan(name: "Monthly", price: 6.99, currency: "USD", region: "US"),
                ServicePlan(name: "Monthly", price: 39.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Apple Arcade → Cancel"
        ),
        ServiceTemplate(
            id: "steam",
            name: "Steam",
            category: .gaming,
            emoji: "🖥️",
            colorHex: "1B2838",
            websiteURL: "https://store.steampowered.com",
            plans: [
                ServicePlan(name: "Free (games sold separately)", price: 0.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://store.steampowered.com/account",
            howToCancel: "Account → Subscriptions → Cancel"
        ),
    ]

    // MARK: - News & Media
    static let newsMedia: [ServiceTemplate] = [
        ServiceTemplate(
            id: "new_york_times",
            name: "New York Times",
            category: .newsMedia,
            emoji: "📰",
            colorHex: "000000",
            websiteURL: "https://nytimes.com",
            plans: [
                ServicePlan(name: "Basic", price: 17.00, currency: "USD", region: "US"),
                ServicePlan(name: "All Access", price: 25.00, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 199.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://nytimes.com/subscription",
            howToCancel: "Account → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "medium",
            name: "Medium",
            category: .newsMedia,
            emoji: "✍️",
            colorHex: "000000",
            websiteURL: "https://medium.com",
            plans: [
                ServicePlan(name: "Member", price: 5.00, currency: "USD", region: "US"),
                ServicePlan(name: "Member Yearly", price: 50.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://medium.com/me/membership",
            howToCancel: "Profile → Membership → Cancel Membership"
        ),
        ServiceTemplate(
            id: "apple_news_plus",
            name: "Apple News+",
            category: .newsMedia,
            emoji: "📖",
            colorHex: "FA2F2F",
            websiteURL: "https://apple.com/news",
            plans: [
                ServicePlan(name: "Monthly", price: 12.99, currency: "USD", region: "US"),
                ServicePlan(name: "Monthly", price: 79.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Apple News+ → Cancel"
        ),
    ]

    // MARK: - Health & Fitness
    static let health: [ServiceTemplate] = [
        ServiceTemplate(
            id: "calm",
            name: "Calm",
            category: .health,
            emoji: "🧘",
            colorHex: "5B7FF4",
            websiteURL: "https://calm.com",
            plans: [
                ServicePlan(name: "Monthly", price: 14.99, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 69.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://calm.com/settings",
            howToCancel: "Profile → Settings → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "headspace",
            name: "Headspace",
            category: .health,
            emoji: "🌅",
            colorHex: "FF7E00",
            websiteURL: "https://headspace.com",
            plans: [
                ServicePlan(name: "Monthly", price: 12.99, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 69.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://headspace.com/account",
            howToCancel: "Account → Subscription → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "strava",
            name: "Strava",
            category: .health,
            emoji: "🏃",
            colorHex: "FC4C02",
            websiteURL: "https://strava.com",
            plans: [
                ServicePlan(name: "Subscription", price: 11.99, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 79.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://strava.com/settings/subscription",
            howToCancel: "Settings → Subscription → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "fitness_plus",
            name: "Apple Fitness+",
            category: .health,
            emoji: "💪",
            colorHex: "FA2F2F",
            websiteURL: "https://apple.com/apple-fitness-plus",
            plans: [
                ServicePlan(name: "Individual", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Family", price: 9.99, currency: "USD", region: "US"),
                ServicePlan(name: "Individual", price: 69.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://apple.com/billing",
            howToCancel: "Settings → Apple ID → Subscriptions → Apple Fitness+ → Cancel"
        ),
    ]

    // MARK: - Education
    static let education: [ServiceTemplate] = [
        ServiceTemplate(
            id: "duolingo_plus",
            name: "Duolingo Plus",
            category: .education,
            emoji: "🦉",
            colorHex: "58CC02",
            websiteURL: "https://duolingo.com",
            plans: [
                ServicePlan(name: "Super Duolingo", price: 6.99, currency: "USD", region: "US"),
                ServicePlan(name: "Duolingo Max", price: 13.99, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 83.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://duolingo.com/settings",
            howToCancel: "Profile → Settings → Super Duolingo → Cancel"
        ),
        ServiceTemplate(
            id: "coursera_plus",
            name: "Coursera Plus",
            category: .education,
            emoji: "🎓",
            colorHex: "0056D2",
            websiteURL: "https://coursera.org",
            plans: [
                ServicePlan(name: "Monthly", price: 59.00, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 399.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://coursera.org/account/settings",
            howToCancel: "Settings → Subscription → Cancel"
        ),
        ServiceTemplate(
            id: "skillshare",
            name: "Skillshare",
            category: .education,
            emoji: "🎨",
            colorHex: "01B9C5",
            websiteURL: "https://skillshare.com",
            plans: [
                ServicePlan(name: "Membership", price: 19.00, currency: "USD", region: "US"),
                ServicePlan(name: "Yearly", price: 168.00, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://skillshare.com/settings",
            howToCancel: "Settings → Membership → Cancel Membership"
        ),
        ServiceTemplate(
            id: "linkedin_premium",
            name: "LinkedIn Premium",
            category: .education,
            emoji: "💼",
            colorHex: "0A66C2",
            websiteURL: "https://linkedin.com/premium",
            plans: [
                ServicePlan(name: "Career", price: 39.99, currency: "USD", region: "US"),
                ServicePlan(name: "Business", price: 59.99, currency: "USD", region: "US"),
                ServicePlan(name: "Sales Navigator", price: 99.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://linkedin.com/premium",
            howToCancel: "Me → Premium → Manage Premium Account → Cancel"
        ),
    ]

    // MARK: - Developer Tools
    static let developer: [ServiceTemplate] = [
        ServiceTemplate(
            id: "github_pro",
            name: "GitHub Pro",
            category: .software,
            emoji: "🐙",
            colorHex: "000000",
            websiteURL: "https://github.com/pricing",
            plans: [
                ServicePlan(name: "Pro", price: 4.00, currency: "USD", region: "US"),
                ServicePlan(name: "Team", price: 4.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://github.com/settings/billing",
            howToCancel: "Settings → Billing → Cancel Plan"
        ),
        ServiceTemplate(
            id: "vercel_pro",
            name: "Vercel Pro",
            category: .software,
            emoji: "▲",
            colorHex: "000000",
            websiteURL: "https://vercel.com/pricing",
            plans: [
                ServicePlan(name: "Pro", price: 20.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://vercel.com/account",
            howToCancel: "Account → Billing → Cancel Plan"
        ),
        ServiceTemplate(
            id: "digital_ocean",
            name: "DigitalOcean",
            category: .software,
            emoji: "🌊",
            colorHex: "0080FF",
            websiteURL: "https://digitalocean.com",
            plans: [
                ServicePlan(name: "Droplet Basic (starts at)", price: 6.00, currency: "USD", region: "US"),
                ServicePlan(name: "App Platform (starts at)", price: 5.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://cloud.digitalocean.com/account/billing",
            howToCancel: "Billing → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "cursor_pro",
            name: "Cursor Pro",
            category: .software,
            emoji: "⚡",
            colorHex: "000000",
            websiteURL: "https://cursor.com",
            plans: [
                ServicePlan(name: "Pro", price: 20.00, currency: "USD", region: "US"),
                ServicePlan(name: "Business", price: 40.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://cursor.com/settings",
            howToCancel: "Settings → Billing → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "jetbrains_all",
            name: "JetBrains All Products",
            category: .software,
            emoji: "🔧",
            colorHex: "FE315D",
            websiteURL: "https://jetbrains.com",
            plans: [
                ServicePlan(name: "Individual Yearly", price: 249.00, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "IntelliJ IDEA", price: 24.90, currency: "USD", region: "US"),
            ],
            cancelURL: "https://account.jetbrains.com",
            howToCancel: "JetBrains Account → Licenses → Cancel"
        ),
    ]

    // MARK: - Other Popular Services
    static let other: [ServiceTemplate] = [
        ServiceTemplate(
            id: "canva_pro",
            name: "Canva Pro",
            category: .productivity,
            emoji: "🖌️",
            colorHex: "00C4CC",
            websiteURL: "https://canva.com",
            plans: [
                ServicePlan(name: "Pro", price: 15.00, currency: "USD", region: "US"),
                ServicePlan(name: "Teams", price: 10.00, currency: "USD", region: "US"),
                ServicePlan(name: "Pro Yearly", price: 120.00, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "Pro", price: 229.99, currency: "TRY", region: "TR"),
            ],
            cancelURL: "https://canva.com/settings",
            howToCancel: "Account Settings → Billing & Plans → Cancel Plan"
        ),
        ServiceTemplate(
            id: "grammarly",
            name: "Grammarly Premium",
            category: .productivity,
            emoji: "✏️",
            colorHex: "15C39A",
            websiteURL: "https://grammarly.com",
            plans: [
                ServicePlan(name: "Premium Monthly", price: 30.00, currency: "USD", region: "US"),
                ServicePlan(name: "Premium Yearly", price: 144.00, currency: "USD", region: "US", billingCycle: .yearly),
                ServicePlan(name: "Business", price: 25.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://grammarly.com/account",
            howToCancel: "Account → My Subscription → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "lastpass",
            name: "LastPass Premium",
            category: .productivity,
            emoji: "🔑",
            colorHex: "D32D27",
            websiteURL: "https://lastpass.com",
            plans: [
                ServicePlan(name: "Premium", price: 3.00, currency: "USD", region: "US"),
                ServicePlan(name: "Families", price: 4.00, currency: "USD", region: "US"),
            ],
            cancelURL: "https://lastpass.com/account",
            howToCancel: "Account Settings → Subscription → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "twitch",
            name: "Twitch (Turbo)",
            category: .entertainment,
            emoji: "🟣",
            colorHex: "9146FF",
            websiteURL: "https://twitch.tv/turbo",
            plans: [
                ServicePlan(name: "Turbo", price: 8.99, currency: "USD", region: "US"),
            ],
            cancelURL: "https://twitch.tv/settings/billing",
            howToCancel: "Settings → Billing → Cancel Subscription"
        ),
        ServiceTemplate(
            id: "bereal",
            name: "BeReal Plus",
            category: .entertainment,
            emoji: "📸",
            colorHex: "000000",
            websiteURL: "https://bereal.com",
            plans: [
                ServicePlan(name: "Plus", price: 2.99, currency: "USD", region: "US"),
                ServicePlan(name: "Plus Yearly", price: 9.99, currency: "USD", region: "US", billingCycle: .yearly),
            ],
            cancelURL: "https://bereal.com/settings",
            howToCancel: "Profile → Settings → BeReal Plus → Cancel"
        ),
    ]

    // MARK: - Helper
    static func template(for id: String) -> ServiceTemplate? {
        all.first { $0.id == id }
    }

    static func search(_ query: String) -> [ServiceTemplate] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        if q.isEmpty { return all }
        return all.filter { $0.name.lowercased().contains(q) }
    }
}
