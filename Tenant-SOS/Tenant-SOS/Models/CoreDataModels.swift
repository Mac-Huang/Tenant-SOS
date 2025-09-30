import Foundation
import CoreData

// MARK: - State Entity
@objc(StateEntity)
public class StateEntity: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var laws: NSSet?
}

extension StateEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StateEntity> {
        return NSFetchRequest<StateEntity>(entityName: "StateEntity")
    }

    @objc(addLawsObject:)
    @NSManaged public func addToLaws(_ value: Law)

    @objc(removeLawsObject:)
    @NSManaged public func removeFromLaws(_ value: Law)
}

// MARK: - Law Entity
@objc(Law)
public class Law: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var statute: String?
    @NSManaged public var effectiveDate: Date?
    @NSManaged public var state: StateEntity?
    @NSManaged public var category: LawCategory?
}

extension Law {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Law> {
        return NSFetchRequest<Law>(entityName: "Law")
    }
}

// MARK: - LawCategory Entity
@objc(LawCategory)
public class LawCategory: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var icon: String?
    @NSManaged public var laws: NSSet?
}

extension LawCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LawCategory> {
        return NSFetchRequest<LawCategory>(entityName: "LawCategory")
    }

    @objc(addLawsObject:)
    @NSManaged public func addToLaws(_ value: Law)

    @objc(removeLawsObject:)
    @NSManaged public func removeFromLaws(_ value: Law)
}

// MARK: - Bookmark Entity
@objc(Bookmark)
public class Bookmark: NSManagedObject {
    @NSManaged public var dateAdded: Date?
    @NSManaged public var notes: String?
    @NSManaged public var law: Law?
}

extension Bookmark {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }
}

// MARK: - UserProfile Entity
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var homeState: String?
    @NSManaged public var frequentStatesData: Data? // Store as Data
    @NSManaged public var housingStatus: String?
    @NSManaged public var hasDriversLicense: Bool
    @NSManaged public var employmentType: String?

    // Computed property to handle array conversion
    var frequentStates: [String] {
        get {
            guard let data = frequentStatesData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            frequentStatesData = try? JSONEncoder().encode(newValue)
        }
    }
}

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
}

// MARK: - Document Entity
@objc(Document)
public class Document: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var content: Data?
    @NSManaged public var type: String?
    @NSManaged public var templateName: String?
    @NSManaged public var state: String?
    @NSManaged public var generatedDate: Date?
}

extension Document {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }
}