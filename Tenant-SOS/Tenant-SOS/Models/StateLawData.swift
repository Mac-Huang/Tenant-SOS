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
            // TENANT RIGHTS - Wisconsin Comprehensive
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No statutory limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Security Deposit Return", description: "Time to return security deposit", value: "21 days after move-out", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Security Deposit Interest", description: "Interest on security deposits", value: "Not required", importance: .medium, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "28 days minimum", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction for Nonpayment", description: "Notice for eviction (nonpayment of rent)", value: "5 days notice", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction for Lease Violation", description: "Notice for eviction (lease violation)", value: "5 days notice", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Without Cause", description: "Notice for eviction (month-to-month)", value: "28 days notice", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "No rent control - preempted by state law", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Late Fees", description: "Late rent payment fees", value: "Must be reasonable, specified in lease", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Landlord Entry", description: "Landlord right to enter rental unit", value: "Reasonable notice required (12 hours typical)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Lease Break", description: "Early termination of lease", value: "Allowed for military deployment, domestic abuse, uninhabitable conditions", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Habitability", description: "Landlord duty to maintain habitable premises", value: "Must maintain safe, sanitary conditions", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Retaliation Protection", description: "Protection from landlord retaliation", value: "Protected for complaints, tenant organizing", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Discrimination", description: "Fair housing protections", value: "Protected: race, color, religion, sex, disability, familial status, national origin, sexual orientation, marital status", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Utility Shutoff", description: "Landlord shutting off utilities", value: "Illegal - constitutes unlawful eviction", importance: .critical, effectiveDate: nil),

            // TRAFFIC LAWS - Wisconsin Comprehensive
            StateLaw(category: .traffic, title: "Texting While Driving", description: "Texting and driving prohibition", value: "Banned - $20-$400 fine", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Handheld Phone Use", description: "Handheld device use while driving", value: "Allowed for phone calls (texting banned)", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Speed Limit - Urban", description: "Speed limit in cities/villages", value: "25 mph (unless posted)", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Speed Limit - Rural", description: "Speed limit on rural highways", value: "55 mph", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Speed Limit - Interstate", description: "Speed limit on interstate highways", value: "70 mph", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "DUI Blood Alcohol", description: "Legal BAC limit for DUI", value: "0.08% (0.00% under 21)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "DUI Penalties - First", description: "First OWI/DUI offense", value: "$150-$300 fine, 6-9 month license revocation", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Implied Consent", description: "Chemical testing requirement", value: "Refusal = automatic license revocation", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Seatbelt Requirement", description: "Seatbelt laws", value: "Required for all occupants, primary offense", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Child Car Seat", description: "Child restraint requirements", value: "Under 4 years or under 40 lbs", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Booster Seat", description: "Booster seat requirements", value: "Ages 4-8 and under 4'9\" tall", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Motorcycle Helmet", description: "Motorcycle helmet requirements", value: "Required only for instructional permit holders and under 18", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Right Turn on Red", description: "Turning right at red lights", value: "Allowed after complete stop (unless posted)", importance: .medium, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Left Turn on Red", description: "Left turn from one-way to one-way", value: "Allowed after stop", importance: .low, effectiveDate: nil),
            StateLaw(category: .traffic, title: "School Bus Stop", description: "Stopping for school buses", value: "Must stop both directions (unless divided highway)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Move Over Law", description: "Moving over for emergency vehicles", value: "Must move over or slow down", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Reckless Driving", description: "Reckless driving penalties", value: "$25-$200 fine, up to 30 days jail", importance: .high, effectiveDate: nil),
            StateLaw(category: .traffic, title: "Hit and Run", description: "Leaving scene of accident", value: "Felony if injury ($600-$10,000 fine, up to 10 years)", importance: .critical, effectiveDate: nil),

            // EMPLOYMENT - Wisconsin Comprehensive
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal minimum)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Tipped Minimum Wage", description: "Minimum wage for tipped employees", value: "$2.33/hour (if tips + wages = $7.25)", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Youth Minimum Wage", description: "Opportunity wage for workers under 20", value: "$5.90/hour (first 90 days)", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Overtime Pay", description: "Overtime after hours worked", value: "1.5x pay after 40 hours/week", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Paid Sick Leave", description: "Mandatory paid sick leave", value: "No state requirement", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Meal Breaks", description: "Required meal periods", value: "Recommended 30 min after 6 hours (not required for most adults)", importance: .medium, effectiveDate: nil),
            StateLaw(category: .employment, title: "Rest Breaks", description: "Required rest breaks", value: "Not required by state law", importance: .medium, effectiveDate: nil),
            StateLaw(category: .employment, title: "Final Paycheck", description: "When final paycheck is due", value: "Next regular payday", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Payday Frequency", description: "How often employees must be paid", value: "At least monthly", importance: .medium, effectiveDate: nil),
            StateLaw(category: .employment, title: "At-Will Employment", description: "Employment at-will status", value: "Yes - employment can be terminated by either party", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Wrongful Termination", description: "Protections against wrongful termination", value: "Protected: discrimination, retaliation, public policy violations", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Workers' Compensation", description: "Workers' comp insurance requirement", value: "Required for 3+ employees", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Unemployment Insurance", description: "Unemployment benefit eligibility", value: "Must have earned wages, job loss through no fault", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Child Labor", description: "Minimum working age", value: "14 years (12 for agricultural work)", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Youth Work Hours", description: "Work hour restrictions for minors", value: "16-17: no more than 6 days/week; 14-15: limited hours", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Background Checks", description: "Ban the box law", value: "No - employers may ask about criminal history", importance: .medium, effectiveDate: nil),
            StateLaw(category: .employment, title: "Drug Testing", description: "Pre-employment drug testing", value: "Allowed with notice", importance: .medium, effectiveDate: nil),
            StateLaw(category: .employment, title: "Non-Compete Agreements", description: "Enforceability of non-compete clauses", value: "Enforceable if reasonable in scope, time, geography", importance: .high, effectiveDate: nil),
            StateLaw(category: .employment, title: "Right to Work", description: "Union membership requirements", value: "Right-to-work state - union membership cannot be required", importance: .high, effectiveDate: nil),

            // TAXES - Wisconsin Comprehensive
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate (2024)", value: "3.5% - 7.65% (4 brackets)", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Income Tax Brackets", description: "Tax brackets for single filers", value: "$0-13,810: 3.5%; $13,811-27,630: 4.4%; $27,631-304,170: 5.3%; $304,171+: 7.65%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Standard Deduction", description: "Standard deduction amount", value: "$12,760 single, $23,620 married (2024)", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5%", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Local Sales Tax", description: "Additional local sales taxes", value: "0-1.75% (varies by county)", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax Exemptions", description: "Items exempt from sales tax", value: "Groceries, prescription drugs, most services", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Property Tax", description: "Property tax system", value: "Based on assessed value, paid to local government", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Property Tax Rate", description: "Average property tax rate", value: "~1.73% of home value (varies by municipality)", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Vehicle Registration", description: "Annual vehicle registration fee", value: "$75 base + $5.50 per $1,000 of vehicle value", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Gas Tax", description: "State fuel tax", value: "30.9¢ per gallon", importance: .low, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Cigarette Tax", description: "State cigarette tax", value: "$2.52 per pack", importance: .low, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Estate Tax", description: "State estate/inheritance tax", value: "No estate tax", importance: .medium, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Capital Gains Tax", description: "Tax on capital gains", value: "Taxed as regular income at state rates", importance: .medium, effectiveDate: nil),

            // CONSUMER PROTECTION - Wisconsin Comprehensive
            StateLaw(category: .consumer, title: "Lemon Law", description: "New vehicle warranty protection", value: "Covers 1 year or 15,000 miles", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Lemon Law Requirements", description: "Conditions for lemon law claim", value: "4 repair attempts or 30 days out of service", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Used Car Lemon Law", description: "Protection for used vehicles", value: "No specific lemon law for used cars", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Cooling-Off Period", description: "Door-to-door sales cancellation", value: "3 business days to cancel", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Home Improvement Contract", description: "Cancellation of home improvement contracts", value: "3 business days to cancel", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Debt Collection", description: "Debt collection practices", value: "Prohibited: harassment, false statements, unfair practices", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Wage Garnishment", description: "Limits on wage garnishment", value: "Limited to 20% of disposable earnings", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Credit Freeze", description: "Right to freeze credit", value: "Free credit freeze available", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Data Breach Notification", description: "Notification requirement for data breaches", value: "Must notify within reasonable time", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Price Gouging", description: "Price gouging during emergencies", value: "Prohibited during declared emergencies", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Warranty Requirements", description: "Implied warranty protections", value: "Implied warranty of merchantability applies", importance: .medium, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Identity Theft", description: "Identity theft protections", value: "Security freeze, fraud alerts available", importance: .high, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Telemarketing", description: "Do Not Call registry", value: "State and federal Do Not Call lists available", importance: .low, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Gift Cards", description: "Gift card expiration rules", value: "Cannot expire within 5 years", importance: .low, effectiveDate: nil),
            StateLaw(category: .consumer, title: "Rental Car Damage", description: "Rental car damage waiver", value: "Personal insurance may cover - review carefully", importance: .low, effectiveDate: nil),
        ],

        // ALABAMA
        "AL": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent (recommended)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2% - 5%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4% + local", importance: .medium, effectiveDate: nil),
        ],

        // ALASKA
        "AK": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$11.73/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "No state sales tax (local only)", importance: .medium, effectiveDate: nil),
        ],

        // ARIZONA
        "AZ": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1.5 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.35/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2.5% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.6% + local", importance: .medium, effectiveDate: nil),
        ],

        // ARKANSAS
        "AR": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$11.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2% - 4.7%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.5% + local", importance: .medium, effectiveDate: nil),
        ],

        // COLORADO
        "CO": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (60 days for 10%+)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.42/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.4% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "2.9% + local", importance: .medium, effectiveDate: nil),
        ],

        // CONNECTICUT
        "CT": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$15.69/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3% - 6.99%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.35%", importance: .medium, effectiveDate: nil),
        ],

        // DELAWARE
        "DE": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent (pet deposits extra)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "60 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$13.25/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2.2% - 6.6%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "No sales tax", importance: .medium, effectiveDate: nil),
        ],

        // GEORGIA
        "GA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "60 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "Immediate notice allowed", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1% - 5.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4% + local", importance: .medium, effectiveDate: nil),
        ],

        // HAWAII
        "HI": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "45 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1.4% - 11%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4% (general excise tax)", importance: .medium, effectiveDate: nil),
        ],

        // IDAHO
        "ID": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "15 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "5.8% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // INDIANA
        "IN": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.05% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "7%", importance: .medium, effectiveDate: nil),
        ],

        // IOWA
        "IA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.4% - 6%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // KANSAS
        "KS": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent (unfurnished), 1.5 (furnished)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.1% - 5.7%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.5% + local", importance: .medium, effectiveDate: nil),
        ],

        // KENTUCKY
        "KY": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.5% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6%", importance: .medium, effectiveDate: nil),
        ],

        // LOUISIANA
        "LA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "10 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1.85% - 4.25%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4.45% + local", importance: .medium, effectiveDate: nil),
        ],

        // MAINE
        "ME": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "45 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.15/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "5.8% - 7.15%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.5%", importance: .medium, effectiveDate: nil),
        ],

        // MARYLAND
        "MD": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$15.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2% - 5.75% + local", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6%", importance: .medium, effectiveDate: nil),
        ],

        // MASSACHUSETTS
        "MA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (at-will), full rental period (lease)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$15.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "5% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.25%", importance: .medium, effectiveDate: nil),
        ],

        // MICHIGAN
        "MI": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1.5 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$10.33/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.25% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6%", importance: .medium, effectiveDate: nil),
        ],

        // MINNESOTA
        "MN": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "Full rental period (at least 1 month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$10.85/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "5.35% - 9.85%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.875% + local", importance: .medium, effectiveDate: nil),
        ],

        // MISSISSIPPI
        "MS": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "0% - 5%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "7% + local", importance: .medium, effectiveDate: nil),
        ],

        // MISSOURI
        "MO": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.30/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2% - 4.95%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4.225% + local", importance: .medium, effectiveDate: nil),
        ],

        // MONTANA
        "MT": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "15 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$10.30/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.7% - 5.9%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "No state sales tax", importance: .medium, effectiveDate: nil),
        ],

        // NEBRASKA
        "NE": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2.46% - 5.84%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.5% + local", importance: .medium, effectiveDate: nil),
        ],

        // NEVADA
        "NV": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "3 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "45 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.85% + local", importance: .medium, effectiveDate: nil),
        ],

        // NEW HAMPSHIRE
        "NH": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent or $100", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No regular income tax (5% on interest/dividends)", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "No sales tax", importance: .medium, effectiveDate: nil),
        ],

        // NEW JERSEY
        "NJ": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1.5 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "30 days notice to quit", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$15.13/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1.4% - 10.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.625%", importance: .medium, effectiveDate: nil),
        ],

        // NEW MEXICO
        "NM": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "7 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1.7% - 5.9%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.125% + local", importance: .medium, effectiveDate: nil),
        ],

        // NORTH CAROLINA
        "NC": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1.5 months rent (month-to-month), 2 months (longer lease)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "7 days (week-to-week), 30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.5% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4.75% + local", importance: .medium, effectiveDate: nil),
        ],

        // NORTH DAKOTA
        "ND": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent or $1,500 if pet", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "1.1% - 2.9%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5% + local", importance: .medium, effectiveDate: nil),
        ],

        // OHIO
        "OH": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$10.45/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2.75% - 3.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.75% + local", importance: .medium, effectiveDate: nil),
        ],

        // OKLAHOMA
        "OK": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "0.25% - 4.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4.5% + local", importance: .medium, effectiveDate: nil),
        ],

        // OREGON
        "OR": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "90 days (10%+ increase)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Rent Control", description: "State-wide rent control laws", value: "Yes (7% + inflation cap)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.20/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.75% - 9.9%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "No sales tax", importance: .medium, effectiveDate: nil),
        ],

        // PENNSYLVANIA
        "PA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent (1st year), 1 month (after)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "10 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.07% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // RHODE ISLAND
        "RI": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "15 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$14.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.75% - 5.99%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "7%", importance: .medium, effectiveDate: nil),
        ],

        // SOUTH CAROLINA
        "SC": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "0% - 6.5%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // SOUTH DAKOTA
        "SD": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "1 month rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days (month-to-month)", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$11.20/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4.2% + local", importance: .medium, effectiveDate: nil),
        ],

        // TENNESSEE
        "TN": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No regular income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "7% + local", importance: .medium, effectiveDate: nil),
        ],

        // UTAH
        "UT": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "15 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "4.65% flat", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.1% + local", importance: .medium, effectiveDate: nil),
        ],

        // VERMONT
        "VT": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "60 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$13.67/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "3.35% - 8.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // VIRGINIA
        "VA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "2 months rent", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$12.00/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2% - 5.75%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "5.3% + local", importance: .medium, effectiveDate: nil),
        ],

        // WASHINGTON
        "WA": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "60 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "14 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$16.28/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No regular income tax (capital gains tax 7%)", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6.5% + local", importance: .medium, effectiveDate: nil),
        ],

        // WEST VIRGINIA
        "WV": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "5 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$8.75/hour", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "2.36% - 5.12%", importance: .high, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "6% + local", importance: .medium, effectiveDate: nil),
        ],

        // WYOMING
        "WY": [
            StateLaw(category: .tenantRights, title: "Security Deposit Limit", description: "Maximum security deposit landlord can charge", value: "No limit", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Notice for Rent Increase", description: "Required notice period for rent increases", value: "30 days", importance: .high, effectiveDate: nil),
            StateLaw(category: .tenantRights, title: "Eviction Notice Period", description: "Minimum notice for eviction", value: "3 days (pay or quit)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .employment, title: "Minimum Wage", description: "State minimum wage", value: "$7.25/hour (federal)", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "State Income Tax", description: "State income tax rate", value: "No income tax", importance: .critical, effectiveDate: nil),
            StateLaw(category: .taxes, title: "Sales Tax", description: "State sales tax rate", value: "4% + local", importance: .medium, effectiveDate: nil),
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