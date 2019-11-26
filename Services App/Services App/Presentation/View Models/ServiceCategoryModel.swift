//
//  ServiceCategoryModel.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class ServiceCategoryModel {
    var name: String
    var id = UUID()
    var standardLength: Double?
    
    init(entity: ServiceCategoryEntity) {
        self.id = entity.id!
        self.name = entity.name!
        self.standardLength = entity.standardLength
    }
    
    init(name: String, standardLength: Double? = nil) {
        self.name = name
        self.standardLength = standardLength
    }
}
