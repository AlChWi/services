//
//  ServiceCategoryEntity.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class ServiceCategoryEntity: NSManagedObject {
    class func findOrCreate(_ category: ServiceCategoryModel, stack: DataStack) throws -> ServiceCategoryEntity {
        if let _ = try? ServiceCategoryEntity.find(categoryName: category.name, stack: stack) {
            throw ServiceCreationErrors.alreadyExisted
        } else {
            try stack.perform(synchronous: { transaction in
                let entity = transaction.create(Into<ServiceCategoryEntity>())
                entity.name = category.name
                entity.id = category.id
                entity.standardLength = category.standardLength ?? 0
            })
            let categoryEntity = try stack.fetchOne(
                From<ServiceCategoryEntity>()
                    .where(\.id == category.id)
            )
            
            print("category created")
            return categoryEntity!
        }
    }
    
    class func find(categoryName: String, stack: DataStack) throws -> ServiceCategoryEntity? {
        return try stack.fetchOne(
            From<ServiceCategoryEntity>()
                .where(\.name == categoryName)
        )
    }
    
    class func find(containingName name: String, stack: DataStack) throws -> [ServiceCategoryEntity]? {
        return try stack.fetchAll(
            From<ServiceCategoryEntity>()
                .where(format: "%K CONTAINS %@", #keyPath(ServiceCategoryEntity.name).lowercased(), name.lowercased())
        )
        
    }
    
    class func findCountForCategory(_ categoryName: String, stack: DataStack) throws -> Int {
        return try stack.queryValue(
            From<ServiceEntity>(),
            Select(.count(\.id)),
            Where<ServiceEntity>(\.category?.name == categoryName)
        )!
    }
    
    class func findAll(stack: DataStack) throws -> [ServiceCategoryEntity] {
        return try stack.fetchAll(
            From<ServiceCategoryEntity>()
        )
    }
}


enum CategoryCreationError: Error {
    case alreadyExisted
}

