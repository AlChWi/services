//
//  SettingsEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class SettingsEntity: NSManagedObject {
    
    //MARK: - CLASS FUNCTIONSS
    class func findOrCreate(stack: DataStack) throws -> SettingsEntity {
        if let settingsEntity = try? SettingsEntity.find(stack: stack) {
            return settingsEntity
        } else {
            try stack.perform(synchronous: { transaction in
                _ = transaction.create(Into<SettingsEntity>())
            })
            let settingsEntity = try find(stack: stack)
            return settingsEntity!
        }
    }
    
    class func find(stack: DataStack) throws -> SettingsEntity? {
        return try stack.fetchOne(
            From<SettingsEntity>()
        )
    }
    //MARK: -
}
