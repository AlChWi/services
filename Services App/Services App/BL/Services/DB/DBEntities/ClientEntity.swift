//
//  ClientEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class ClientEntity: UserEntity {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ user: UserModel, context: NSManagedObjectContext) throws -> ClientEntity {
        if let clientEntity = try? ClientEntity.find(userId: user.id, context: context) {
            
            return clientEntity
        } else {
            let clientEntity = ClientEntity(context: context)
            clientEntity.id = user.id
            clientEntity.firstName = user.firstName
            clientEntity.lastName = user.lastName
            clientEntity.login = user.login
            clientEntity.password = user.password
            clientEntity.age = user.age
            clientEntity.email = user.email
            clientEntity.phone = user.phone
            clientEntity.image = user.image?.jpegData(compressionQuality: 1)
            
            return clientEntity
        }
    }
    
    override class func find(userId: UUID, context: NSManagedObjectContext) throws -> ClientEntity? {
        let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %id", argumentArray: [userId])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    //MARK: -
    
}
