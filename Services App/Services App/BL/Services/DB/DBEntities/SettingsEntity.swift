//
//  SettingsEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class SettingsEntity: NSManagedObject {
    
    //MARK: - CLASS FUNCTIONSS
    class func findOrCreate(context: NSManagedObjectContext) throws -> SettingsEntity {
        if let settingsEntity = try? SettingsEntity.find(context: context) {
            
            return settingsEntity
        } else {
            let settingsEntity = SettingsEntity(context: context)

            return settingsEntity
        }
    }
    
    class func find(context: NSManagedObjectContext) throws -> SettingsEntity? {
        let request: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    //MARK: -
}
