//
//  UserModel.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

class UserModel {
    
    //MARK: - PUBLIC VARIABLES
    var login: String
    var password: String
    var firstName: String
    var lastName: String
    var age: Int16
    var email: String
    var phone: String
    var money: Decimal
    var image: UIImage?
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private(set) var id: UUID
    //MARK: -
    
    //MARK: - INIT
    init?(fromEntity entity: UserEntity) {
        guard let id = entity.id,
            let login = entity.login,
            let password = entity.password,
            let firstName = entity.firstName,
            let lastName = entity.lastName,
            let email = entity.email,
            let phone = entity.phone else {
                return nil
        }
        self.id = id
        self.login = login
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.age = entity.age
        self.email = email
        self.phone = phone
        self.money = entity.money as Decimal? ?? 0.0
        if let image = UIImage(data: entity.image ?? Data()) {
            self.image = image
        }
    }
    
    init(login: String,
         password: String,
         firstName: String,
         lastname: String,
         age: Int16,
         email: String,
         phone: String,
         image: Data?) {
        self.id = UUID()
        self.login = login
        self.password = password
        self.firstName = firstName
        self.lastName = lastname
        self.age = age
        self.email = email
        self.phone = phone
        self.money = 100000.0
        if let data = image, let uiImage = UIImage(data: data) {
            self.image = uiImage
        }
    }
    //MARK: -
}
