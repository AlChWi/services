//
//  ServiceEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class ServiceEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ service: ServiceModel, stack: DataStack) throws -> ServiceEntity {
        if let _ = try? ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, stack: stack) {
            throw ServiceCreationErrors.alreadyExisted
        } else {
            try stack.perform(synchronous: { transaction in
                guard
                    let provider = try stack.fetchOne(
                        From<ProviderEntity>()
                            .where(\.id == service.providerID)
                    ),
                    let category = try transaction.fetchOne(
                        From<ServiceCategoryEntity>()
                            .where(\.name == service.category?.name)
                    ) else {
                        try transaction.cancel()
                }
                let entity = transaction.create(Into<ServiceEntity>())
                let provider1 = transaction.edit(provider)!
                entity.toProvider = provider1
                entity.category = category
                entity.id = service.id
                entity.name = service.name
                entity.pricePerHour = service.pricePerHour as NSDecimalNumber?
            })
            let serviceEntity = try stack.fetchOne(
                From<ServiceEntity>()
                    .where(\.id == service.id)
            )
            
            print(serviceEntity?.name)
            print(serviceEntity?.category)
            print(serviceEntity?.pricePerHour)
            print("service created")
            return serviceEntity!
        }
    }
    
    class func find(serviceName: String, serviceProviderID: UUID, stack: DataStack) throws -> ServiceEntity? {
        return try stack.fetchOne(
            From<ServiceEntity>()
                .where(\.name == serviceName && \.toProvider?.id == serviceProviderID)
        )
    }
    
    class func find(containingName name: String, stack: DataStack) throws -> [ServiceEntity] {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .where(format: "%K CONTAINS %@",
                       #keyPath(ServiceEntity.name), name)
        )
    }
    
    class func find(containingName name: String, orInCategory category: String, orFromProvider providerName: String, stack: DataStack) throws -> [ServiceEntity]? {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .where(format: "%K CONTAINS %@ OR %K CONTAINS %@ OR %K CONTAINS %@",
                       #keyPath(ServiceEntity.name).lowercased(), name.lowercased(),
                       #keyPath(ServiceEntity.category.name).lowercased(), category.lowercased(),
                       #keyPath(ServiceEntity.toProvider.firstName).lowercased(), providerName.lowercased())
                .orderBy(.ascending(\.name), .ascending(\.category?.name))
        )
    }
    
    class func find(containingName name: String, orInCategory category: String, andFromProvider providerID: UUID, stack: DataStack) throws -> [ServiceEntity]? {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .where(format: "(%K CONTAINS %@ OR %K CONTAINS %@) AND %K CONTAINS %@",
                       #keyPath(ServiceEntity.name).lowercased(), name.lowercased(),
                       #keyPath(ServiceEntity.category.name).lowercased(), category.lowercased(),
                       #keyPath(ServiceEntity.toProvider.id), providerID)
                .orderBy(.ascending(\.name), .ascending(\.category?.name))
        )
    }
    
    class func find(forCategory categoryName: String, stack: DataStack) throws -> [ServiceEntity] {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .where(\.category?.name == categoryName)
                .orderBy(.ascending(\.name))
        )
    }
    
    class func countOfOrders(forService service: ServiceModel, stack: DataStack) throws -> Int {
        return try stack.queryValue(
            From<OrderEntity>(),
            Select(.count(\.startDate)),
            Where<OrderEntity>(\.service?.id == service.id)
        )!
    }
    
    class func findAll(stack: DataStack) throws -> [ServiceEntity] {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .orderBy(.ascending(\.name))
        )
    }
    
    class func findAll(forProvider provider: ProviderModel, stack: DataStack) throws -> [ServiceEntity]? {
        return try stack.fetchAll(
            From<ServiceEntity>()
                .where(\.toProvider?.id == provider.id)
        )
    }
    //MARK: -
}

//MARK: - ERRORS
enum ServiceCreationErrors: Error {
    case couldntFindUser
    case alreadyExisted
}
//MARK: -
