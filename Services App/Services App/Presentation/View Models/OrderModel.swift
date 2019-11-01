//
//  OrderModel.swift
//  Services App
//
//  Created by Perov Alexey on 14.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

class OrderModel {
    
    //MARK: - PUBLIC VARIABLES
    var date: Date
    var clientID: UUID
    var clientName: String?
    var clientPhoto: UIImage?
    var providerID: UUID
    var providerName: String?
    var providerPhoto: UIImage?
    var serviceName: String
    //MARK: -
    
    //MARK: - INIT
    init?(fromEntity entity: OrderEntity) {
        guard let date = entity.date,
            let serviceName = entity.service?.name,
            let clientID = entity.client?.id,
            let providerID = entity.provider?.id else {
                return nil
        }
        self.date = date

        self.serviceName = serviceName
        self.clientName = "\(entity.client?.firstName ?? "") \(entity.client?.lastName ?? "")"
        if let data = entity.client?.image {
            self.clientPhoto = UIImage(data: data)
        }
        self.clientID = clientID
        self.providerName = "\(entity.provider?.firstName ?? "") \(entity.provider?.lastName ?? "")"
        if let data = entity.provider?.image {
            self.providerPhoto = UIImage(data: data)
        }
        self.providerID = providerID
    }
    
    init(date: Date, clientID: UUID, providerID: UUID, serviceName: String) {
        self.date = date
        self.clientID = clientID
        self.providerID = providerID
        self.serviceName = serviceName
    }
    //MARK: -
}
