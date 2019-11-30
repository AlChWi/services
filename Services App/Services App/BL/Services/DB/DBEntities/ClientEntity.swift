//
//  ClientEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class ClientEntity: UserEntity {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ user: UserModel, stack: DataStack) throws -> ClientEntity {
        if let clientEntity = try? ClientEntity.find(userId: user.id, stack: stack) {
            
            return clientEntity
        } else {
            try stack.perform(synchronous: { transaction in
                let client = transaction.create(Into<ClientEntity>())
                client.firstName = user.firstName
                client.lastName = user.lastName
                client.login = user.login
                client.password = user.password
                client.email = user.email
                client.age = user.age
                client.money = 10000.0
                client.image = user.image?.pngData()
                client.id = user.id
                client.phone = user.phone
            })
            let clientEntity = try stack.fetchOne(
            From<ClientEntity>()
                .where(\.id == user.id)
            )
            return clientEntity!
        }
    }
    
    override class func find(userId: UUID, stack: DataStack) throws -> ClientEntity? {
        let result = try stack.fetchOne(
            From<UserEntity>()
                .where(\.id == userId)
        )
        switch result {
        case is ClientEntity:
            return result as? ClientEntity
        default:
            return nil
        }
    }
    //MARK: -
    
}
