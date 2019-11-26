//
//  Notification+extensions.swift
//  Services App
//
//  Created by Perov Alexey on 22.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let orderCreated = Notification.Name(Constants.NotificationNames.orderCreated)
    static let serviceCreated = Notification.Name(Constants.NotificationNames.serviceCreated)
    static let professionSelected = Notification.Name("Profession selected")
    static let categorySelected = Notification.Name("Category selected")
}
