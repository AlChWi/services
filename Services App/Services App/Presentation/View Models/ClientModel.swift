//
//  ClientModel.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class ClientModel: UserModel {
    
    //MARK: - PUBLIC VARIABLES
    var orders: [OrderModel]?
    //MARK: -
    
    //MARK: - INIT
    init?(fromEntity entity: ClientEntity) {
        let orderEntities = entity.orders?.allObjects as? [OrderEntity]
        self.orders = orderEntities?.compactMap { OrderModel(fromEntity: $0) } ?? []
        
        super.init(fromEntity: entity)
    }
    
    override init(login: String, password: String, firstName: String, lastname: String, age: Int16, email: String, phone: String, image: Data?) {
        super.init(login: login, password: password, firstName: firstName, lastname: lastname, age: age, email: email, phone: phone, image: image)
    }
    //MARK: -
}
