//
//  ЗкщауыышщтУтешен.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class ProfessionEntity: NSManagedObject {
    class func findOrCreate(_ profession: ProfessionModel, stack: DataStack) throws -> ProfessionEntity {
        if let _ = try? ProfessionEntity.find(professionName: profession.name, stack: stack) {
            throw ProfessionCreationError.alreadyExisted
        } else {
            try stack.perform(synchronous: { transaction in
                let entity = transaction.create(Into<ProfessionEntity>())
                entity.name = profession.name
                entity.id = profession.id
            })
            let professionEntity = try stack.fetchOne(
                From<ProfessionEntity>()
                    .where(\.id == profession.id)
            )

            print("profession created")
            return professionEntity!
        }
    }
    
    class func find(professionName: String, stack: DataStack) throws -> ProfessionEntity? {
        return try stack.fetchOne(
            From<ProfessionEntity>()
                .where(\.name == professionName)
        )
    }
    
    class func find(containigName name: String, stack: DataStack) throws -> [ProfessionEntity]? {
        return try stack.fetchAll(
            From<ProfessionEntity>()
                .where(format: "%K CONTAINS %@", #keyPath(ProfessionEntity.name).lowercased(), name.lowercased())
        )
    }
    
    class func findCountForProfession(_ professionName: String, stack: DataStack) throws -> Int {
        return try stack.queryValue(
            From<ProviderEntity>(),
            Select(.count(\.id)),
            Where<ProviderEntity>(\.profession?.name == professionName)
        )!
    }
    
    class func findAll(stack: DataStack) throws -> [ProfessionEntity] {
        return try stack.fetchAll(
            From<ProfessionEntity>()
        )
    }
}

enum ProfessionCreationError: Error {
    case alreadyExisted
}
