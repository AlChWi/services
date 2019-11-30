//
//  UserEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class UserEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func all(_ stack: DataStack) throws -> [UserEntity] {
        let result = try stack.fetchAll(
            From<UserEntity>()
        )
        return result
    }
    
    class func findAll(stack: DataStack) throws -> [UserEntity] {
        return try stack.fetchAll(
            From<UserEntity>()
        )
    }
    
    class func find(userId: UUID, stack: DataStack) throws -> UserEntity? {
        let result = try stack.fetchOne(
            From<UserEntity>()
                .where(\.id == userId)
        )
        return result
    }
    
    class func findWithMostMoney(inDataStack stack: DataStack) throws -> UserEntity? {
        return try stack.fetchOne(
            From<UserEntity>()
                .orderBy(.descending(\.money))
        )
    }
    
    class func findWithLogin(login: String, stack: DataStack) throws -> UserEntity? {
        let result = try stack.fetchOne(
            From<UserEntity>()
                .where(\.login == login)
        )
        return result
    }
    
    class func findProfile(login: String, password: String, stack: DataStack) throws -> UserEntity? {
        let result = try stack.fetchOne(
            From<UserEntity>()
                .where(\.login == login && \.password == password)
        )
        return result
    }
    //MARK: -
}
