//
//  ServiceModel.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class ServiceModel {
    
    //MARK: - public variables
    var name: String
    var pricePerHour: Decimal?
    var category: ServiceCategoryModel?
    var providerID: UUID
    
    //MARK: - init
    init?(fromEntity entity: ServiceEntity) {
        guard let name = entity.name,
            let providerEntity = entity.toProvider,
            let providerID = providerEntity.id else {
                return nil
        }
        self.name = name
        self.pricePerHour = entity.pricePerHour! as Decimal
        self.category = ServiceCategoryModel(entity: entity.category!)
        self.providerID = providerID
    }
    
    init(name: String, providerID: UUID, category: ServiceCategoryModel, pricePerHour: Decimal) {
        self.name = name
        self.providerID = providerID
        self.category = category
        self.pricePerHour = pricePerHour
    }
    //MARK: -
}
