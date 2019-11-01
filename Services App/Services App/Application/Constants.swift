//
//  Constants.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation

enum Constants {
    //MARK: - STORYBOARDNAMES
    enum StoryboardNames {
        static let main = "Main"
    }
    //MARK: -
    
    //MARK: - NOTIFICATIONNAMES
    enum NotificationNames {
        static let orderCreated = "Order created"
        static let serviceCreated = "Service created"
    }
    //MARK: -
    
    //MARK: - NIBNAMES
    enum NibNames {
        static let serviceWithProviderCell = "ServiceWithProviderTableViewCell"
        static let serviceCell = "ServiceTableViewCell"
        static let orderCell = "OrderTableViewCell"
    }
    //MARK: -
    
    //MARK: - CELLIDS
    enum CellIDs {
        static let serviceCell = "ServiceCell"
        static let orderCell = "OrderCell"
    }
    //MARK: -
    
    //MARK: - USERINFOKEYS
    enum UserInfoKeys {
        static let service = "Service"
        static let order = "Order"
    }
    //MARK: -
}
