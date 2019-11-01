//
//  UserEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class UserEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func all(_ context: NSManagedObjectContext) throws -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            throw error
        }
    }
    
    class func find(userId: UUID, context: NSManagedObjectContext) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %id", argumentArray: [userId])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findWithLogin(login: String, context: NSManagedObjectContext) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", argumentArray: [login])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findProfile(login: String, password: String, context: NSManagedObjectContext) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@ AND password == %@", argumentArray: [login, password])
        let fetchResult = try context.fetch(request)
        
        return fetchResult.first
    }
    //MARK: -
}
