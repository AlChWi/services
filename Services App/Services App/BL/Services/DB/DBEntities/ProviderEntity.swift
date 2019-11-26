//
//  ProviderEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class ProviderEntity: UserEntity {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ user: UserModel, profession: ProfessionModel, context: NSManagedObjectContext) throws -> ProviderEntity {
        if let providerEntity = try? ProviderEntity.find(userId: user.id, context: context) {
            
            return providerEntity
        } else {
            let providerEntity = ProviderEntity(context: context)
            let professionEntity = try ProfessionEntity.find(professionName: profession.name, context: context)
            providerEntity.id = user.id
            providerEntity.firstName = user.firstName
            providerEntity.lastName = user.lastName
            providerEntity.login = user.login
            providerEntity.password = user.password
            providerEntity.age = user.age
            providerEntity.profession = professionEntity
            providerEntity.email = user.email
            providerEntity.phone = user.phone
            providerEntity.money = user.money as NSDecimalNumber
            providerEntity.image = user.image?.jpegData(compressionQuality: 1)

            return providerEntity
        }
    }
    
    override class func find(userId: UUID, context: NSManagedObjectContext) throws -> ProviderEntity? {
        let request: NSFetchRequest<ProviderEntity> = ProviderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %id", argumentArray: [userId])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findServices(userID: UUID, context: NSManagedObjectContext) throws -> [ServiceEntity]? {
        let provider = try find(userId: userID, context: context)
        let services = provider?.services?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: false)]) as? [ServiceEntity]
        
        return services
    }
    //MARK: -
}
