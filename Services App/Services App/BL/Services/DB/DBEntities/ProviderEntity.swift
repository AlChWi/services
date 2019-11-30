//
//  ProviderEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class ProviderEntity: UserEntity {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ user: UserModel, profession: ProfessionModel, stack: DataStack) throws -> ProviderEntity {
        if let providerEntity = try? ProviderEntity.find(userId: user.id, stack: stack) {
            return providerEntity
        } else {
            _ = try stack.perform(synchronous: { transaction in
                let provider = transaction.create(Into<ProviderEntity>())
                guard
                    let professionUNSAFE = try? ProfessionEntity.find(professionName: profession.name, stack: stack) else {
                        try transaction.cancel()
                }
                let professionEntity = transaction.edit(professionUNSAFE)!
                provider.profession = professionEntity
                provider.lastName = user.lastName
                provider.id = user.id
                provider.firstName = user.firstName
                provider.email = user.email
                provider.phone = user.phone
                provider.login = user.login
                provider.password = user.password
                provider.age = user.age
                provider.image = user.image?.pngData()
                provider.money = 100000.0
            })
            return try stack.fetchOne(
                From<ProviderEntity>()
                    .where(\.id == user.id)
                )!
        }
    }
    
    override class func find(userId: UUID, stack: DataStack) throws -> ProviderEntity? {
        let result = try? stack.fetchOne(
            From<UserEntity>()
                .where(\.id == userId)
        )
        switch result {
        case is ProviderEntity:
            return result as? ProviderEntity
        default:
            return nil
        }
    }
    
    class func createWithCoreStore(store: DataStack) -> ProviderEntity? {
        let id = UUID()
        _ = try? store.perform(synchronous: { transaction in
            let user = transaction.create(Into<ProviderEntity>())
            user.lastName = "John"
            user.id = id
            user.firstName = ""
            user.email = ""
            user.phone = ""
            user.login = ""
            user.password = ""
            user.age = 18
            user.image = nil
            user.money = 10000.0
        })
        let res = try? store.fetchOne(
            From<ProviderEntity>()
                .where(\.id == id)
        )
        print(res?.lastName)
        return res
    }
    
    class func findServices(userID: UUID, stack: DataStack) throws -> [ServiceEntity]? {
        let res = try? stack.fetchOne(
            From<ProviderEntity>()
                .where(\.id == userID)
        )
        
        return res?.services?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as? [ServiceEntity]
    }
    //MARK: -
}
