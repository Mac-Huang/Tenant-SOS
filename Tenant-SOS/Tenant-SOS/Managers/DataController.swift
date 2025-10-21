import SwiftUI
import Combine

// Simple models without Core Data
struct StateModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let abbreviation: String
    let lastUpdated: Date

    init(id: UUID = UUID(), name: String, abbreviation: String, lastUpdated: Date) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.lastUpdated = lastUpdated
    }
}

struct LawModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let category: String
    let summary: String
    let content: String
    let statute: String
    let stateCode: String
    let effectiveDate: Date
    let lastUpdated: Date

    init(id: UUID = UUID(), title: String, category: String, summary: String, content: String, statute: String, stateCode: String, effectiveDate: Date, lastUpdated: Date) {
        self.id = id
        self.title = title
        self.category = category
        self.summary = summary
        self.content = content
        self.statute = statute
        self.stateCode = stateCode
        self.effectiveDate = effectiveDate
        self.lastUpdated = lastUpdated
    }
}

struct DocumentModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: Data
    let type: String
    let templateName: String
    let state: String
    let createdAt: Date
    let updatedAt: Date

    init(id: UUID = UUID(), title: String, content: Data, type: String, templateName: String, state: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.type = type
        self.templateName = templateName
        self.state = state
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct BookmarkModel: Identifiable, Codable {
    let id: UUID
    let lawId: UUID
    let createdAt: Date
    let notes: String?

    init(id: UUID = UUID(), lawId: UUID, createdAt: Date, notes: String? = nil) {
        self.id = id
        self.lawId = lawId
        self.createdAt = createdAt
        self.notes = notes
    }
}

class DataController: ObservableObject {
    @Published var states: [StateModel] = []
    @Published var laws: [LawModel] = []
    @Published var documents: [DocumentModel] = []
    @Published var bookmarks: [BookmarkModel] = []

    init() {
        // Initialize empty, load data asynchronously
    }

    func loadDataAsync() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var loadedStates = self.loadStatesFromDefaults()
            var loadedLaws = self.loadLawsFromDefaults()

            if loadedStates.isEmpty || loadedLaws.isEmpty {
                self.generateInitialData()
                loadedStates = self.loadStatesFromDefaults()
                loadedLaws = self.loadLawsFromDefaults()
            }

            let didUpdate = self.ensureAllStatesLoaded(states: &loadedStates, laws: &loadedLaws)

            if didUpdate {
                self.persistStateData(states: loadedStates, laws: loadedLaws)
            }

            loadedStates.sort { $0.name < $1.name }
            loadedLaws.sort {
                if $0.stateCode == $1.stateCode {
                    if $0.category == $1.category {
                        return $0.title < $1.title
                    }
                    return $0.category < $1.category
                }
                return $0.stateCode < $1.stateCode
            }

            DispatchQueue.main.async {
                self.clearCaches()
                self.states = loadedStates
                self.laws = loadedLaws
            }
        }
    }

    private func generateInitialData() {
        // Generate data on background thread, then save
        var newStates: [StateModel] = []
        var allLaws: [LawModel] = []
        let timestamp = Date()

        for stateInfo in StateDatabase.allStates {
            let stateModel = StateModel(name: stateInfo.name, abbreviation: stateInfo.code, lastUpdated: timestamp)
            newStates.append(stateModel)
            allLaws.append(contentsOf: generateLawsForState(stateModel))
        }

        persistStateData(states: newStates, laws: allLaws)
    }

    private func loadStatesFromDefaults() -> [StateModel] {
        if let data = UserDefaults.standard.data(forKey: "states"),
           let decoded = try? JSONDecoder().decode([StateModel].self, from: data) {
            return decoded
        }
        return []
    }

    private func loadLawsFromDefaults() -> [LawModel] {
        if let data = UserDefaults.standard.data(forKey: "laws"),
           let decoded = try? JSONDecoder().decode([LawModel].self, from: data) {
            return decoded
        }
        return []
    }

    @discardableResult
    private func ensureAllStatesLoaded(states: inout [StateModel], laws: inout [LawModel]) -> Bool {
        var didUpdate = false
        let existingStateCodes = Set(states.map { $0.abbreviation })
        var existingLawKeys = Set(laws.map { "\($0.stateCode)|\($0.title)" })
        let timestamp = Date()
        var appendedStates: [StateModel] = []

        for stateInfo in StateDatabase.allStates where !existingStateCodes.contains(stateInfo.code) {
            didUpdate = true

            let stateModel = StateModel(name: stateInfo.name, abbreviation: stateInfo.code, lastUpdated: timestamp)
            appendedStates.append(stateModel)

            for law in generateLawsForState(stateModel) {
                let key = "\(law.stateCode)|\(law.title)"
                if !existingLawKeys.contains(key) {
                    laws.append(law)
                    existingLawKeys.insert(key)
                }
            }
        }

        if !appendedStates.isEmpty {
            states.append(contentsOf: appendedStates)
        }

        return didUpdate
    }

    private func persistStateData(states: [StateModel], laws: [LawModel]) {
        if let encodedStates = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(encodedStates, forKey: "states")
        }
        if let encodedLaws = try? JSONEncoder().encode(laws) {
            UserDefaults.standard.set(encodedLaws, forKey: "laws")
        }
    }

    private func generateLawsForState(_ state: StateModel) -> [LawModel] {
        return [
            LawModel(
                title: "Security Deposit Limits",
                category: "Tenant Rights",
                summary: "Maximum security deposit allowed in \(state.name)",
                content: getSecurityDepositContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "tenant"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            ),
            LawModel(
                title: "Eviction Notice Requirements",
                category: "Tenant Rights",
                summary: "Required notice periods for eviction in \(state.name)",
                content: getEvictionNoticeContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "eviction"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            ),
            LawModel(
                title: "Speed Limits",
                category: "Traffic Laws",
                summary: "Highway and residential speed limits",
                content: getSpeedLimitContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "traffic"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            ),
            LawModel(
                title: "Minimum Wage",
                category: "Employment",
                summary: "Current minimum wage requirements",
                content: getMinimumWageContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "employment"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            ),
            LawModel(
                title: "State Income Tax",
                category: "Tax",
                summary: "State income tax rates and brackets",
                content: getStateTaxContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "tax"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            ),
            LawModel(
                title: "Sales Tax",
                category: "Tax",
                summary: "State and local sales tax rates",
                content: getSalesTaxContent(for: state.abbreviation),
                statute: getStatuteReference(for: state.abbreviation, category: "sales-tax"),
                stateCode: state.abbreviation,
                effectiveDate: Date(),
                lastUpdated: Date()
            )
        ]
    }

    func save() {
        clearCaches() // Clear caches when data changes
        
        // Save to UserDefaults for persistence
        if let encoded = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(encoded, forKey: "states")
        }
        if let encoded = try? JSONEncoder().encode(laws) {
            UserDefaults.standard.set(encoded, forKey: "laws")
        }
        if let encoded = try? JSONEncoder().encode(documents) {
            UserDefaults.standard.set(encoded, forKey: "documents")
        }
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: "bookmarks")
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "states"),
           let decoded = try? JSONDecoder().decode([StateModel].self, from: data) {
            states = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "laws"),
           let decoded = try? JSONDecoder().decode([LawModel].self, from: data) {
            laws = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "documents"),
           let decoded = try? JSONDecoder().decode([DocumentModel].self, from: data) {
            documents = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "bookmarks"),
           let decoded = try? JSONDecoder().decode([BookmarkModel].self, from: data) {
            bookmarks = decoded
        }
    }


    // Content generation methods
    private func getSecurityDepositContent(for state: String) -> String {
        switch state {
        case "CA":
            return "In California, landlords can charge up to 2 months' rent for an unfurnished unit and 3 months' rent for a furnished unit. The deposit must be returned within 21 days after move-out, along with an itemized list of deductions if any are made."
        case "TX":
            return "Texas has no statutory limit on security deposits. However, landlords must return the deposit within 30 days after the tenant moves out. If deductions are made, an itemized list must be provided."
        case "NY":
            return "In New York, security deposits are limited to one month's rent. Landlords must return deposits within 14 days after the tenant vacates. The deposit must be held in a separate interest-bearing account."
        case "FL":
            return "Florida has no statutory limit on security deposits. Deposits must be returned within 15 days if no deductions are made, or within 30 days with an itemized list of deductions."
        case "IL":
            return "Illinois has no statewide limit, but Chicago limits deposits to one month's rent. Deposits must be returned within 30-45 days depending on deductions. Interest may be required on deposits held for more than 6 months."
        case "WI":
            return "Wisconsin has no statewide cap on security deposits. Landlords must provide a check-in sheet at move-in and return deposits within 21 days after the tenant vacates, with an itemized list of deductions if any are taken."
        default:
            return "Security deposit regulations vary. Please check local laws."
        }
    }

    private func getEvictionNoticeContent(for state: String) -> String {
        switch state {
        case "CA":
            return "California requires: 3-day notice for non-payment of rent or lease violations. 30-day notice for month-to-month tenancies (60 days if tenant has lived there over 1 year). Just cause required in many cities."
        case "TX":
            return "Texas requires: 3-day notice to vacate for non-payment or lease violations. 30-day notice for month-to-month tenancies. No statewide just cause requirement."
        case "NY":
            return "New York requires: 14-day notice for non-payment. 30/60/90-day notice based on length of tenancy. Good cause eviction protection in NYC and some other areas."
        case "FL":
            return "Florida requires: 3-day notice for non-payment (excluding weekends/holidays). 7-day notice for lease violations with opportunity to cure. 15-day notice for month-to-month tenancies."
        case "IL":
            return "Illinois requires: 5-day notice for non-payment. 10-day notice for lease violations. 30-day notice for month-to-month tenancies. Chicago has additional tenant protections."
        case "WI":
            return "Wisconsin requires: 5-day notice to pay or vacate for first non-payment or lease violation within 12 months (14-day with no right to cure on repeat). Month-to-month tenancies generally require 28-day notice to terminate."
        default:
            return "Eviction notice requirements vary by jurisdiction."
        }
    }

    private func getSpeedLimitContent(for state: String) -> String {
        switch state {
        case "CA":
            return "Maximum speed limits: 65 mph on highways, 70 mph on some rural interstates, 55 mph on two-lane undivided highways. Residential areas: 25 mph unless otherwise posted. School zones: 25 mph when children are present."
        case "TX":
            return "Maximum speed limits: 75-85 mph on highways (highest in the nation on some roads), 60-70 mph on other highways. Urban areas: 30 mph in residential zones. School zones: 20 mph when flashing."
        case "NY":
            return "Maximum speed limits: 55 mph on most highways, 65 mph on some interstates. NYC: 25 mph citywide unless otherwise posted. School zones: 15-20 mph during school hours."
        case "FL":
            return "Maximum speed limits: 70 mph on highways, 65 mph on rural interstates. Residential areas: 30 mph. School zones: 15-20 mph when lights are flashing."
        case "IL":
            return "Maximum speed limits: 70 mph on rural interstates, 55 mph in urban areas. Residential: 30 mph. School zones: 20 mph on school days."
        case "WI":
            return "Maximum speed limits: 70 mph on rural interstates and 65 mph on expressways. Other highways typically 55 mph. Urban and residential areas: 25-35 mph unless posted. School zones: 15 mph during school hours."
        default:
            return "Speed limits vary by road type and location."
        }
    }

    private func getDUIContent(for state: String) -> String {
        switch state {
        case "CA":
            return "BAC limit: 0.08% (0.04% commercial drivers, 0.01% under 21). Penalties: First offense - up to 6 months jail, $390-1,000 fine, 6-month license suspension. Implied consent law applies."
        case "TX":
            return "BAC limit: 0.08% (0.04% commercial drivers, zero tolerance under 21). Penalties: First offense - up to 180 days jail, up to $2,000 fine, 90-365 day license suspension."
        case "NY":
            return "BAC limit: 0.08% (0.04% commercial drivers, 0.02% under 21). Penalties: First offense - up to 1 year jail, $500-1,000 fine, minimum 6-month license revocation."
        case "FL":
            return "BAC limit: 0.08% (0.04% commercial drivers, 0.02% under 21). Penalties: First offense - up to 6 months jail, $500-2,000 fine, 180-365 day license suspension."
        case "IL":
            return "BAC limit: 0.08% (0.04% commercial drivers, zero tolerance under 21). Penalties: First offense - up to 1 year jail, up to $2,500 fine, 1-year license suspension."
        case "WI":
            return "BAC limit: 0.08% (0.04% commercial drivers, 0.00% for drivers under 21 under absolute sobriety law). First offense OWI is civil: forfeiture $150-$300, license revocation 6-9 months, ignition interlock if BAC ≥ 0.15%. Subsequent offenses carry criminal penalties."
        default:
            return "DUI laws and penalties vary by state."
        }
    }

    private func getMinimumWageContent(for state: String) -> String {
        switch state {
        case "CA":
            return "California minimum wage: $16.00 per hour statewide (2024). Many cities have higher minimums: Los Angeles $16.78, San Francisco $18.07. Annual increases based on CPI. Overtime after 8 hours/day or 40 hours/week."
        case "TX":
            return "Texas minimum wage: $7.25 per hour (federal minimum). No state-mandated increases planned. Tipped employees: $2.13 per hour plus tips must equal $7.25. No daily overtime requirements."
        case "NY":
            return "New York minimum wage: $15.00 per hour in NYC, Long Island, and Westchester. $15.00 upstate (2024). Fast food workers: $15.00 statewide. Tipped workers have separate minimums."
        case "FL":
            return "Florida minimum wage: $12.00 per hour (2024), increasing $1 annually until reaching $15.00 in 2026. Tipped employees: $8.98 per hour. Adjusted annually for inflation after 2026."
        case "IL":
            return "Illinois minimum wage: $14.00 per hour (2024), increasing to $15.00 in 2025. Chicago: $15.80 per hour (higher for large employers). Tipped employees: 60% of minimum wage."
        case "WI":
            return "Wisconsin minimum wage: $7.25 per hour (matching federal rate). Tipped employees: $2.33 per hour with tips making up the difference. Youth opportunity wage: $5.90 per hour for the first 90 days of work."
        default:
            return "Minimum wage rates vary. Check current local and state requirements."
        }
    }

    private func getOvertimeContent(for state: String) -> String {
        switch state {
        case "CA":
            return "Overtime pay required: 1.5x rate after 8 hours/day or 40 hours/week. Double time after 12 hours/day or after 8 hours on the 7th consecutive workday. Exemptions apply to certain positions."
        case "TX":
            return "Follows federal law: 1.5x rate after 40 hours/week. No daily overtime requirements. Exemptions for executive, administrative, and professional employees earning over $684/week."
        case "NY":
            return "Overtime pay: 1.5x rate after 40 hours/week. Some industries have different rules. Residential employees: 1.5x after 44 hours. Farm laborers: 1.5x after 60 hours (lowering to 40 by 2032)."
        case "FL":
            return "Follows federal law: 1.5x rate after 40 hours/week. No state-specific overtime laws. Manual laborers entitled to overtime regardless of salary level."
        case "IL":
            return "Overtime pay: 1.5x rate after 40 hours/week. No daily overtime requirements. Exemptions follow federal guidelines. Chicago has no additional overtime requirements."
        case "WI":
            return "Wisconsin follows federal overtime rules: 1.5x pay after 40 hours/week. Certain agricultural, executive, administrative, and professional employees are exempt."
        default:
            return "Overtime rules follow federal standards unless state law provides greater benefits."
        }
    }

    private func getStateTaxContent(for state: String) -> String {
        switch state {
        case "CA":
            return "California state income tax: Progressive rates from 1% to 13.3% (highest in nation). Brackets: $0-10,099 (1%), $10,100-23,942 (2%), $23,943-37,788 (4%), $37,789-52,455 (6%), $52,456-66,295 (8%), $66,296-338,639 (9.3%), $338,640-406,364 (10.3%), $406,365-677,275 (11.3%), $677,276+ (12.3%). Additional 1% Mental Health Services Tax on income over $1M."
        case "TX":
            return "Texas has NO state income tax. One of 9 states with no income tax. Revenue comes from sales tax (6.25% state rate) and property taxes. No corporate income tax (uses margin tax instead). This is a significant benefit for residents and businesses."
        case "NY":
            return "New York state income tax: Progressive rates from 4% to 10.9%. Brackets: $0-8,500 (4%), $8,501-11,700 (4.5%), $11,701-13,900 (5.25%), $13,901-80,650 (5.85%), $80,651-215,400 (6.25%), $215,401-1,077,550 (6.85%), $1,077,551-5,000,000 (9.65%), $5,000,001-25,000,000 (10.3%), $25,000,001+ (10.9%). NYC residents pay additional city income tax (3.078-3.876%)."
        case "FL":
            return "Florida has NO state income tax. Major advantage for residents and retirees. Revenue primarily from sales tax (6% state + up to 2% local) and tourism taxes. No estate or inheritance tax. Became no-income-tax state in 1855."
        case "IL":
            return "Illinois flat income tax: 4.95% on all income levels (2024). One of few states with flat tax structure. No local income taxes. Standard exemption: $2,425 per person. Property tax credit available. Chicago does not impose additional income tax."
        case "WA":
            return "Washington has NO state income tax. Revenue from sales tax (6.5% state rate, highest combined rate nation-wide with local taxes reaching 10.4%), B&O tax on businesses, and property tax. Capital gains tax of 7% on gains exceeding $250,000 annually (started 2022)."
        case "GA":
            return "Georgia state income tax: Progressive rates from 1% to 5.75%. Brackets: $0-750 (1%), $751-2,250 (2%), $2,251-3,750 (3%), $3,751-5,250 (4%), $5,251-7,000 (5%), $7,001+ (5.75%). Standard deduction: $5,400 (single), $7,100 (head of household), $10,800 (married filing jointly)."
        case "PA":
            return "Pennsylvania flat income tax: 3.07% on all income (2024). One of lowest state income tax rates. Local taxes: Philadelphia 3.79%, Pittsburgh 3%. No local income tax in most areas. Retirement income (pensions, 401k, IRA distributions, Social Security) is tax-exempt."
        case "AZ":
            return "Arizona flat income tax: 2.5% on all income (2024). Recently simplified from progressive system. One of lowest state income tax rates. Maricopa County residents pay additional 0.7% for transportation. No local income taxes in most areas."
        case "MA":
            return "Massachusetts flat income tax: 5% on most income (2024). Recently reduced from 5.05%. Additional 4% surtax on income over $1M (total 9%). Short-term capital gains taxed at 8.5%. Long-term capital gains at 5%. No local income taxes."
        case "WI":
            return "Wisconsin state income tax: Progressive rates from 3.54% to 7.65% (2024). Brackets (single): up to $13,810 (3.54%), $13,811-$27,630 (4.65%), $27,631-$304,170 (5.3%), over $304,171 (7.65%). Counties do not levy additional income tax, but there is a separate 0.4% payroll deduction for unemployment insurance."
        default:
            return "State income tax varies. Check your specific state tax authority for current rates and brackets."
        }
    }

    private func getSalesTaxContent(for state: String) -> String {
        switch state {
        case "CA":
            return "California sales tax: 7.25% base state rate. With local taxes, rates range from 7.25% to 10.75%. Highest combined rates: Los Angeles 9.5%, San Francisco 8.625%, San Jose 9.375%. Most counties add district taxes. Groceries exempt, but prepared food taxed. Prescription drugs exempt."
        case "TX":
            return "Texas sales tax: 6.25% state rate. Local jurisdictions can add up to 2%, making maximum 8.25%. Most areas 8.25%. Food and prescription drugs exempt. Over-the-counter drugs taxable. Remote sellers must collect if $500,000+ in Texas sales."
        case "NY":
            return "New York sales tax: 4% state rate. Counties add 3-4.875%, making combined rates 7-8.875%. NYC: 8.875% (highest). Most clothing under $110 exempt statewide. Groceries, prescription drugs exempt. Prepared food taxable. Counties may exempt clothing entirely."
        case "FL":
            return "Florida sales tax: 6% state rate. Counties can add up to 1.5%, making combined rates 6-8%. Most areas 6-7%. Groceries, prescription drugs exempt. Clothing taxable (no exemption). Florida has sales tax 'holidays' for back-to-school and disaster prep supplies."
        case "IL":
            return "Illinois sales tax: 6.25% state rate. Local jurisdictions add more, making combined rates 6.25-11%. Chicago: 10.25% (one of highest in nation). Cook County: 10.25-11%. Groceries taxed at reduced 1% state rate. Prescription drugs exempt. General merchandise fully taxed."
        case "WA":
            return "Washington sales tax: 6.5% state rate. Local areas add up to 3.9%, making combined rates reach 10.4% (highest in US). Seattle: 10.25%, Tacoma: 10.3%. Groceries and prescription drugs exempt. No income tax means sales tax is primary revenue source."
        case "GA":
            return "Georgia sales tax: 4% state rate. Counties and cities add 3-5%, making combined rates 4-9%. Atlanta: 8.9%. Groceries exempt from state tax but may have local tax. Prescription drugs exempt. Counties can add 1% SPLOST for infrastructure projects."
        case "PA":
            return "Pennsylvania sales tax: 6% state rate statewide (no local additions in most areas). Philadelphia: additional 2% (8% total), Allegheny County 1% additional (7% total). Groceries, clothing, prescription drugs all exempt. One of most exemptions in nation."
        case "AZ":
            return "Arizona sales tax: 5.6% state rate (called Transaction Privilege Tax). Cities and counties add 1.5-5.6%, making combined rates 5.6-11.2%. Phoenix: 8.6%, Tucson: 8.7%. Groceries exempt. Prescription drugs exempt. Rental cars taxed higher (combined can exceed 50%)."
        case "MA":
            return "Massachusetts sales tax: 6.25% statewide, no local additions. Clothing under $175 per item exempt. Groceries exempt. Prescription drugs exempt. Restaurant meals taxed. Alcohol taxed separately. Sales tax holidays offered occasionally."
        case "WI":
            return "Wisconsin sales tax: 5% statewide. Most counties add a 0.5% sales tax, making combined rates typically 5.5%. Select communities (Milwaukee, Wisconsin Dells) levy additional premier resort taxes up to 1.25% on certain sales. Groceries and prescription drugs are exempt."
        default:
            return "Sales tax varies by state and locality. Check your local tax authority for exact rates."
        }
    }

    private func getStatuteReference(for state: String, category: String) -> String {
        switch (state, category) {
        case ("CA", "tenant"): return "Cal. Civ. Code § 1950.5"
        case ("CA", "eviction"): return "Cal. Civ. Proc. Code § 1161"
        case ("CA", "traffic"): return "Cal. Veh. Code § 22349"
        case ("CA", "dui"): return "Cal. Veh. Code § 23152"
        case ("CA", "employment"): return "Cal. Lab. Code § 1182.12"
        case ("CA", "overtime"): return "Cal. Lab. Code § 510"
        case ("CA", "tax"): return "Cal. Rev. & Tax. Code § 17041"
        case ("CA", "sales-tax"): return "Cal. Rev. & Tax. Code § 6001"
        case ("TX", "tenant"): return "Tex. Prop. Code § 92.101"
        case ("TX", "eviction"): return "Tex. Prop. Code § 24.005"
        case ("TX", "traffic"): return "Tex. Transp. Code § 545.352"
        case ("TX", "dui"): return "Tex. Penal Code § 49.04"
        case ("TX", "employment"): return "Tex. Lab. Code § 62.051"
        case ("TX", "overtime"): return "29 U.S.C. § 207 (Federal)"
        case ("TX", "tax"): return "N/A - No State Income Tax"
        case ("TX", "sales-tax"): return "Tex. Tax Code § 151.051"
        case ("NY", "tenant"): return "NY Real Prop L § 233"
        case ("NY", "eviction"): return "NY Real Prop Acts L § 711"
        case ("NY", "traffic"): return "NY Veh. & Traf. L § 1180"
        case ("NY", "dui"): return "NY Veh. & Traf. L § 1192"
        case ("NY", "employment"): return "NY Lab. Law § 652"
        case ("NY", "overtime"): return "12 NYCRR § 142-2.2"
        case ("NY", "tax"): return "NY Tax Law § 601"
        case ("NY", "sales-tax"): return "NY Tax Law § 1105"
        case ("FL", "tenant"): return "Fla. Stat. § 83.49"
        case ("FL", "eviction"): return "Fla. Stat. § 83.56"
        case ("FL", "traffic"): return "Fla. Stat. § 316.183"
        case ("FL", "dui"): return "Fla. Stat. § 316.193"
        case ("FL", "employment"): return "Fla. Const. Art. X § 24"
        case ("FL", "overtime"): return "29 U.S.C. § 207 (Federal)"
        case ("FL", "tax"): return "N/A - No State Income Tax"
        case ("FL", "sales-tax"): return "Fla. Stat. § 212.05"
        case ("IL", "tenant"): return "765 ILCS 710"
        case ("IL", "eviction"): return "735 ILCS 5/9-209"
        case ("IL", "traffic"): return "625 ILCS 5/11-601"
        case ("IL", "dui"): return "625 ILCS 5/11-501"
        case ("IL", "employment"): return "820 ILCS 105/4"
        case ("IL", "overtime"): return "820 ILCS 105/4a"
        case ("IL", "tax"): return "35 ILCS 5/201"
        case ("IL", "sales-tax"): return "35 ILCS 120/2"
        case ("WA", "tax"): return "N/A - No State Income Tax"
        case ("WA", "sales-tax"): return "RCW 82.08.020"
        case ("GA", "tax"): return "O.C.G.A. § 48-7-20"
        case ("GA", "sales-tax"): return "O.C.G.A. § 48-8-30"
        case ("PA", "tax"): return "72 P.S. § 7302"
        case ("PA", "sales-tax"): return "72 P.S. § 7202"
        case ("AZ", "tax"): return "A.R.S. § 43-1011"
        case ("AZ", "sales-tax"): return "A.R.S. § 42-5061"
        case ("MA", "tax"): return "M.G.L. c. 62 § 4"
        case ("MA", "sales-tax"): return "M.G.L. c. 64H § 2"
        case ("WI", "tenant"): return "Wis. Admin. Code ATCP 134.06"
        case ("WI", "eviction"): return "Wis. Stat. § 704.17"
        case ("WI", "traffic"): return "Wis. Stat. § 346.57"
        case ("WI", "dui"): return "Wis. Stat. § 346.63"
        case ("WI", "employment"): return "Wis. Stat. § 104.035"
        case ("WI", "overtime"): return "Wis. Admin. Code DWD 274.03"
        case ("WI", "tax"): return "Wis. Stat. § 71.06"
        case ("WI", "sales-tax"): return "Wis. Stat. § 77.52"
        default: return "State Statute Reference"
        }
    }

    // Fetch methods with improved performance
    func fetchStates() -> [StateModel] {
        return states.sorted { $0.name < $1.name }
    }

    func fetchState(byCode code: String) -> StateModel? {
        return states.first { $0.abbreviation == code }
    }

    func fetchLaws(for stateCode: String, category: String? = nil) -> [LawModel] {
        let filteredLaws: [LawModel]
        
        if let category = category {
            filteredLaws = laws.filter { $0.stateCode == stateCode && $0.category == category }
        } else {
            filteredLaws = laws.filter { $0.stateCode == stateCode }
        }
        
        return filteredLaws.sorted { ($0.category, $0.title) < ($1.category, $1.title) }
    }

    func searchLaws(query: String) -> [LawModel] {
        guard !query.isEmpty else { return [] }
        
        let lowercasedQuery = query.lowercased()
        let matchingLaws = laws.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.summary.lowercased().contains(lowercasedQuery) ||
            $0.content.lowercased().contains(lowercasedQuery)
        }
        
        return matchingLaws.sorted { $0.title < $1.title }
    }

    private var _cachedCategories: [String]?
    func getCategories() -> [String] {
        if let cached = _cachedCategories {
            return cached
        }
        
        let categories = Array(Set(laws.map { $0.category })).sorted()
        _cachedCategories = categories
        return categories
    }
    
    // Clear cache when data changes
    private func clearCaches() {
        _cachedCategories = nil
    }

    func isBookmarked(_ law: LawModel) -> Bool {
        return bookmarks.contains { $0.lawId == law.id }
    }

    func toggleBookmark(for law: LawModel) {
        if let index = bookmarks.firstIndex(where: { $0.lawId == law.id }) {
            bookmarks.remove(at: index)
        } else {
            let bookmark = BookmarkModel(lawId: law.id, createdAt: Date(), notes: nil)
            bookmarks.append(bookmark)
        }
        save()
    }

    func getBookmarkedLaws() -> [LawModel] {
        let bookmarkedIds = Set(bookmarks.map { $0.lawId })
        return laws.filter { bookmarkedIds.contains($0.id) }
    }

    func saveDocument(title: String, content: Data, type: String, templateName: String, state: String) {
        let document = DocumentModel(
            title: title,
            content: content,
            type: type,
            templateName: templateName,
            state: state,
            createdAt: Date(),
            updatedAt: Date()
        )
        documents.append(document)
        save()
    }

    func fetchDocuments() -> [DocumentModel] {
        return documents.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteDocument(_ document: DocumentModel) {
        documents.removeAll { $0.id == document.id }
        save()
    }
}
