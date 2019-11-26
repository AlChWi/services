//
//  ЗкщауыышщтУтешен.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class ProfessionEntity: NSManagedObject {
    class func findOrCreate(_ profession: ProfessionModel, context: NSManagedObjectContext) throws -> ProfessionEntity {
        if let _ = try? ProfessionEntity.find(professionName: profession.name, context: context) {
            throw ProfessionCreationError.alreadyExisted
        } else {
            let professionEntity = ProfessionEntity(context: context)
            professionEntity.name = profession.name
            professionEntity.id = profession.id

            print("profession created")
            return professionEntity
        }
    }
    
    class func find(professionName: String, context: NSManagedObjectContext) throws -> ProfessionEntity? {
        let request: NSFetchRequest<ProfessionEntity> = ProfessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [professionName])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func find(containigName name: String, context: NSManagedObjectContext) throws -> ProfessionEntity? {
        let request: NSFetchRequest<ProfessionEntity> = ProfessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS %@", argumentArray: [name])
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findAll(context: NSManagedObjectContext) throws -> [ProfessionEntity] {
        let request: NSFetchRequest<ProfessionEntity> = ProfessionEntity.fetchRequest()
        let fetchResult = try context.fetch(request)
            
        return fetchResult
    }
}

enum ProfessionCreationError: Error {
    case alreadyExisted
}
