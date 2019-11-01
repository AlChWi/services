//
//  ProviderModel.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class ProviderModel: UserModel {
    
    //MARK: - PUBLIC VARIABLES
    var orders: [OrderModel]?
    var services: [ServiceModel]?
    //MARK: -
    
    //MARK: - INIT
    init?(fromEntity entity: ProviderEntity?) {
        guard let entity = entity else {
            return nil
        }
        let orderEntities = entity.orders?.allObjects as? [OrderEntity]
        self.orders = orderEntities?.compactMap { OrderModel(fromEntity: $0) } ?? []
        let serviceEntities = entity.services?.allObjects as? [ServiceEntity]
        self.services = serviceEntities?.compactMap { ServiceModel(fromEntity: $0) } ?? []
        
        super.init(fromEntity: entity)
    }
        
    override init(login: String, password: String, firstName: String, lastname: String, age: Int16, email: String, phone: String, image: Data?) {
        super.init(login: login, password: password, firstName: firstName, lastname: lastname, age: age, email: email, phone: phone, image: image)
    }
    //MARK: -
}
