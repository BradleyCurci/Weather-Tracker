//
//  CoreDataManager.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import CoreData
import UIKit
import Combine

class CoreDataManager: ObservableObject {
    
    // instantiate singleton
    static let shared = CoreDataManager()
    
    // Initialized Persistence
    let persistentContainer: NSPersistentContainer
    @Published var locations: [Location] = []
    
    // Init Core Data Stack
    private init() {
        persistentContainer = NSPersistentContainer(name: "Location")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load Core Data Entities: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.fetchLocations()
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    func create(_ name: String) {
        let location = Location(context: context)
        location.name = name
        saveContext()
    }
    
    func fetchLocations() {
        let fetch: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            self.locations = try context.fetch(fetch)
            print("Fetched locations:\n\(self.locations.count)")
        } catch {
            print("Unable to fetch locations: \(error)")
        }
    }
    
    func deleteLocation(location: String) {
        context.delete(locations.first(where: { $0.name == location })!)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            DispatchQueue.main.async {
                do {
                    try self.context.save()
                    self.fetchLocations()
                } catch {
                    print("Unable to save context: \(error)")
                }
            }
        }
    }
    
    @objc private func contextDidChange() {
        DispatchQueue.main.async {
            self.fetchLocations()
            print("Context Changed:\(self.locations)")
        }
    }
}
