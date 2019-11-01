//
//  OrdersForDate.swift
//  Services App
//
//  Created by Perov Alexey on 16.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

class OrdersForDate {
    let date: Date
    var orders: [OrderModel]?
    
    init(date: Date, orders: [OrderModel]?) {
        self.date = date
        self.orders = orders
    }
}
