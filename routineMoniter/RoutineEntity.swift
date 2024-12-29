import Foundation
import CoreData

@objc(RoutineEntity)
public class RoutineEntity: NSManagedObject {
	@NSManaged public var needsSync: Bool
	@NSManaged public var id: String?
	@NSManaged public var title: String?
	@NSManaged public var routineDescription: String?
	@NSManaged public var time: Date?
}

extension RoutineEntity: Identifiable {}
