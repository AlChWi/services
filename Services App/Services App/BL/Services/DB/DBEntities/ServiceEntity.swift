//
//  ServiceEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class ServiceEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ service: ServiceModel, context: NSManagedObjectContext) throws -> ServiceEntity {
        if let _ = try? ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, context: context) {
            throw ServiceCreationErrors.alreadyExisted
        } else {
            print(service.providerID)
            guard let provider = DataService.shared.findUser(byID: service.providerID) as? ProviderEntity else {
                throw ServiceCreationErrors.couldntFindUser
            }
            let serviceEntity = ServiceEntity(context: context)
            serviceEntity.name = service.name
            serviceEntity.toProvider = provider

            print("service created")
            return serviceEntity
        }
    }
    
    class func find(serviceName: String, serviceProviderID: UUID, context: NSManagedObjectContext) throws -> ServiceEntity? {
        let request: NSFetchRequest<ServiceEntity> = ServiceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND toProvider.id == %d", argumentArray: [serviceName, serviceProviderID])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findAll(context: NSManagedObjectContext) throws -> [ServiceEntity] {
        let request: NSFetchRequest<ServiceEntity> = ServiceEntity.fetchRequest()
        let fetchResult = try context.fetch(request)
            
        return fetchResult
    }
    
    class func findAll(forProvider provider: ProviderModel, context: NSManagedObjectContext) throws -> [ServiceEntity]? {
        let request: NSFetchRequest<ServiceEntity> = ServiceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "toProvider.id == @d", argumentArray: [provider.id])
        let fetchResult = try context.fetch(request)
        
        return fetchResult
    }
    //MARK: -
}

//MARK: - ERRORS
enum ServiceCreationErrors: Error {
    case couldntFindUser
    case alreadyExisted
}
//MARK: -
