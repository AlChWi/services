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
    var startDate: Date
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
        guard let startDate = entity.startDate,
            let serviceName = entity.service?.name,
            let clientID = entity.client?.id,
            let providerID = entity.service?.toProvider?.id else {
                return nil
        }
        self.startDate = startDate

        self.serviceName = serviceName
        self.clientName = "\(entity.client?.firstName ?? "") \(entity.client?.lastName ?? "")"
        if let data = entity.client?.image {
            self.clientPhoto = UIImage(data: data)
        }
        self.clientID = clientID
        self.providerName = "\(entity.service?.toProvider?.firstName ?? "") \(entity.service?.toProvider?.lastName ?? "")"
        if let data = entity.service?.toProvider?.image {
            self.providerPhoto = UIImage(data: data)
        }
        self.providerID = providerID
    }
    
    init(date: Date, clientID: UUID, providerID: UUID, serviceName: String) {
        self.startDate = date
        self.clientID = clientID
        self.providerID = providerID
        self.serviceName = serviceName
    }
    //MARK: -
}
