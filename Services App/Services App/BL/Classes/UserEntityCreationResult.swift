//
//  UserEntityCreationResult.swift
//  Services App
//
//  Created by Perov Alexey on 14.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

struct UserEntityCreationResult {
    //MARK: - CONSTANTS -
    let resultEntity: UserEntity
    let creationStatus: CreationStatus
    
    //MARK: - INIT -
    init(entity: UserEntity, status: CreationStatus) {
        self.resultEntity = entity
        self.creationStatus = status
    }
}

//MARK: - CREATION STATUS ENUM -
enum CreationStatus {
    case alreadyExisted
    case created
}
