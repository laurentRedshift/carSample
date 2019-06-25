import CoreData
import Foundation

enum CoreDataManagerError: Error {
    case createEntityError
    case fetchEntityError
}

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CarSample")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) throws -> NSManagedObject {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext) else { throw CoreDataManagerError.createEntityError }
        return NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
    }
    
    func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) throws -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        var result = [NSManagedObject]()
        let records = try managedObjectContext.fetch(fetchRequest)
        if let records = records as? [NSManagedObject] {
            result = records
        }
        return result
    }
    
//    func deleteRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) throws {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        let records = try managedObjectContext.fetch(fetchRequest)
//        if let records = records as? [NSManagedObject] {
//            records.forEach({ managedObjectContext.delete($0) })
//        }
//        saveContext()
//    }
    
    func delete(objects: [NSManagedObject], inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        objects.forEach({ managedObjectContext.delete($0) })
        saveContext(inManagedObjectContext: managedObjectContext)
    }
    
    func saveContext(inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
