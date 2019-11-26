//
//  ServiceCategoryEntity.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class ServiceCategoryEntity: NSManagedObject {
    class func findOrCreate(_ category: ServiceCategoryModel, context: NSManagedObjectContext) throws -> ServiceCategoryEntity {
        if let _ = try? ServiceCategoryEntity.find(categoryName: category.name, context: context) {
            throw ServiceCreationErrors.alreadyExisted
        } else {
            let categoryEntity = ServiceCategoryEntity(context: context)
            categoryEntity.name = category.name
            categoryEntity.id = category.id
            categoryEntity.standardLength = category.standardLength ?? 0
            
            print("category created")
            return categoryEntity
        }
    }
    
    class func find(categoryName: String, context: NSManagedObjectContext) throws -> ServiceCategoryEntity? {
        let request: NSFetchRequest<ServiceCategoryEntity> = ServiceCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [categoryName])
        let fetchResult = try context.fetch(request)
        
        return fetchResult.first
    }
    
    class func find(containingName name: String, context: NSManagedObjectContext) throws -> ServiceCategoryEntity? {
        let request: NSFetchRequest<ServiceCategoryEntity> = ServiceCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS %@", argumentArray: [name])
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchResult = try context.fetch(request)
        
        return fetchResult.first
    }
    
    class func findAll(context: NSManagedObjectContext) throws -> [ServiceCategoryEntity] {
        let request: NSFetchRequest<ServiceCategoryEntity> = ServiceCategoryEntity.fetchRequest()
        let fetchResult = try context.fetch(request)
        
        return fetchResult
    }
}


enum CategoryCreationError: Error {
    case alreadyExisted
}

