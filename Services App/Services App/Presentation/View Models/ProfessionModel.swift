//
//  ProfessionModel.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class ProfessionModel {
    
    //MARK: - public variables
    var name: String
    var id = UUID()
    
    //MARK: - init
    init?(fromEntity entity: ProfessionEntity) {
        guard let name = entity.name,
            let id = entity.id else {
                return nil
        }
        self.name = name
        self.id = id
    }
    
    init(name: String) {
        self.name = name
    }
    //MARK: -
}
