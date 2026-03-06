//
//  PersistenceController.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 05/03/26.
//

import Foundation
import CoreData

final class PersistenceController {
    
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "NewsApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
