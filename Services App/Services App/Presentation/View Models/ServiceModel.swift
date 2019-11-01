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
    var providerID: UUID
    
    //MARK: - init
    init?(fromEntity entity: ServiceEntity) {
        guard let name = entity.name,
            let providerEntity = entity.toProvider,
            let providerID = providerEntity.id else {
                return nil
        }
        self.name = name
        self.providerID = providerID
    }
    
    init(name: String, providerID: UUID) {
        self.name = name
        self.providerID = providerID
    }
    //MARK: -
}
