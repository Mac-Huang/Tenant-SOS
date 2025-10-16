import Foundation

// MARK: - Law Categories
enum LawCategoryType: String, CaseIterable {
    case tenantRights = "Tenant Rights"
    case traffic = "Traffic Laws"
    case employment = "Employment"
    case taxes = "Taxes"
    case consumer = "Consumer Protection"

    var icon: String {
        switch self {
        case .tenantRights: return "house.fill"
        case .traffic: return "car.fill"
        case .employment: return "briefcase.fill"
        case .taxes: return "dollarsign.circle.fill"
        case .consumer: return "cart.fill"
        }
    }
}

// MARK: - Key Law Differences Structure
struct StateLaw {
    let category: LawCategoryType
    let title: String
    let description: String
    let value: String // e.g., "30 days", "$15/hour", "Yes/No"
    let importance: ImportanceLevel
    let effectiveDate: Date?
}

enum ImportanceLevel: Int, Comparable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4

    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }

    static func < (lhs: ImportanceLevel, rhs: ImportanceLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - State Laws Database
struct StateLawsDatabase {
    // Key laws for each state - this is a simplified example
    // In production, this would come from a backend database
    static let stateLaws: [String: [StateLaw]] = [
        "CA": [
            // Tenant Rights
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (<10%), 90 days (>10%)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "Yes (AB 1482 - 5% + inflation)", importance: .critical, effectiveDate: Date()),

            // Traffic Laws
            StateLaw(category: .traffic, title: "Hands-Free Driving", description: "Cell phone use while driving", value: "Hands-free only", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Lane Splitting", description: "Motorcycles riding between lanes", value: "Legal", importance: .medium, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Right Turn on Red", description: "Turning right at red lights", value: "Allowed after stop", importance: .low, effectiveDate: nil),

            // Employment
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$16.00/hour", importance: .critical, effectiveDate: Date()),
            StateLaw(category: .employment, title: "Overtime Pay", description: "Overtime after hours worked", value: "8 hours/day, 40 hours/week", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "Yes - 1 hour per 30 worked", importance: .high, effectiveDate: nil),

            // Taxes
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1% - 13.3%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "7.25% + local", importance: .medium, effectiveDate: nil),
        ],

        "TX": [
            // Tenant Rights
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "No rent control", importance: .critical, effectiveDate: nil),

            // Traffic Laws
            StateLaw(category: .traffic, title: "Hands-Free Driving", description: "Cell phone use while driving", value: "Texting banned, calls OK", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Lane Splitting", description: "Motorcycles riding between lanes", value: "Illegal", importance: .medium, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Right Turn on Red", description: "Turning right at red lights", value: "Allowed after stop", importance: .low, effectiveDate: nil),

            // Employment
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Overtime Pay", description: "Overtime after hours worked", value: "40 hours/week only", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "No requirement", importance: .high, effectiveDate: nil),

            // Taxes
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.25% + local", importance: .medium, effectiveDate: nil),
        ],

        "NY": [
            // Tenant Rights
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30-90 days based on tenancy", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "Rent control in certain areas", value: "Yes (NYC & some cities)", importance: .critical, effectiveDate: nil),

            // Employment
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$15.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "Yes - up to 56 hours/year", importance: .high, effectiveDate: nil),

            // Taxes
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4% - 10.9%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4% + local", importance: .medium, effectiveDate: nil),
        ],

        "FL": [
            // Tenant Rights
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "15 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "No rent control", importance: .critical, effectiveDate: nil),

            // Employment
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "No requirement", importance: .high, effectiveDate: nil),

            // Taxes
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        "IL": [
            // Tenant Rights
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),

            // Employment
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$13.00/hour", importance: .critical, effectiveDate: nil),

            // Taxes
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.95% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.25% + local", importance: .medium, effectiveDate: nil),
        ],

        "WI": [
            // Tenant Rights - Wisconsin specific
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "28 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "No rent control", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Deposit Return", description: "Time to return security deposit", value: "21 days", importance: .high, effectiveDate: nil),

            // Traffic Laws - Wisconsin specific
            StateLaw(category: .traffic, title: "Hands-Free Driving", description: "Cell phone use while driving", value: "Texting banned, calls OK", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Absolute Sobriety Law", description: "Zero tolerance for minors", value: "0.00 BAC under 21", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Right Turn on Red", description: "Turning right at red lights", value: "Allowed after stop", importance: .low, effectiveDate: nil),

            // Employment - Wisconsin specific
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Overtime Pay", description: "Overtime after hours worked", value: "40 hours/week", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "No requirement", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Meal Breaks", description: "Required meal periods", value: "Recommended, not required", importance: .medium, effectiveDate: nil),

            // Taxes - Wisconsin specific
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.5% - 7.65%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5% + local", importance: .medium, effectiveDate: nil),

            // Consumer Protection - Wisconsin specific
            StateLaw(category: .consumer, title: "Lemon Law", description: "New vehicle warranty protection", value: "1 year/15,000 miles", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Cooling-Off Period", description: "Door-to-door sales cancellation", value: "3 business days", importance: .medium, effectiveDate: nil),
        ]
    ]

    // Get laws for a specific state
    static func getLaws(for stateCode: String) -> [StateLaw] {
        return stateLaws[stateCode] ?? []
    }

    // Get key differences between two states
    static func getKeyDifferences(from: String, to: String, categories: [LawCategoryType]? = nil) -> [LawComparison] {
        let fromLaws = getLaws(for: from)
        let toLaws = getLaws(for: to)

        var comparisons: [LawComparison] = []
        let categoriesToCompare = categories ?? LawCategoryType.allCases

        for category in categoriesToCompare {
            let fromCategoryLaws = fromLaws.filter { $0.category == category }
            let toCategoryLaws = toLaws.filter { $0.category == category }

            // Find matching laws by title
            for fromLaw in fromCategoryLaws {
                if let toLaw = toCategoryLaws.first(where: { $0.title == fromLaw.title }) {
                    if fromLaw.value != toLaw.value {
                        let comparison = LawComparison(
                            category: category,
                            lawTitle: fromLaw.title,
                            fromState: from,
                            fromValue: fromLaw.value,
                            toState: to,
                            toValue: toLaw.value,
                            description: fromLaw.description,
                            importance: max(fromLaw.importance, toLaw.importance),
                            isDifferent: true
                        )
                        comparisons.append(comparison)
                    }
                }
            }
        }

        // Sort by importance (critical first)
        return comparisons.sorted { $0.importance.rawValue > $1.importance.rawValue }
    }

    // Get most important differences for notification
    static func getCriticalDifferences(from: String, to: String, limit: Int = 3) -> [LawComparison] {
        let differences = getKeyDifferences(from: from, to: to)
        let critical = differences.filter { $0.importance == .critical || $0.importance == .high }
        return Array(critical.prefix(limit))
    }
}

// MARK: - Law Comparison Model
struct LawComparison {
    let category: LawCategoryType
    let lawTitle: String
    let fromState: String
    let fromValue: String
    let toState: String
    let toValue: String
    let description: String
    let importance: ImportanceLevel
    let isDifferent: Bool

    var summaryText: String {
        return "\(lawTitle): \(fromState): \(fromValue) → \(toState): \(toValue)"
    }

    var notificationText: String {
        switch category {
        case .tenantRights:
            if lawTitle.contains("Security Deposit") {
                return "⚠️ Security deposit limits: \(toValue) (was \(fromValue))"
            } else if lawTitle.contains("Rent Control") {
                return "🏠 Rent control: \(toValue)"
            }
            return "🏠 \(lawTitle): \(toValue)"

        case .traffic:
            if lawTitle.contains("Hands-Free") {
                return "🚗 Phone use: \(toValue)"
            }
            return "🚗 \(lawTitle): \(toValue)"

        case .employment:
            if lawTitle.contains("Minimum Wage") {
                return "💰 Minimum wage: \(toValue) (was \(fromValue))"
            }
            return "💼 \(lawTitle): \(toValue)"

        case .taxes:
            if lawTitle.contains("Income Tax") {
                return "💸 State income tax: \(toValue)"
            }
            return "💸 \(lawTitle): \(toValue)"

        case .consumer:
            return "🛒 \(lawTitle): \(toValue)"
        }
    }
}