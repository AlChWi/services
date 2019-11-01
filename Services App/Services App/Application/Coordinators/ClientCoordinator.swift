//
//  ClientCoordinator.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

class ClientCoordinator: SecondaryCoordinator {
    
    //MARK: - WEAK PUBLIC VARIABLES
    weak var coordinator: MainCoordinator?
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func constructTabBar() -> UIViewController {
        let mainTabBar = MainTabBarController.instantiate()
        
        let ordersTab = UINavigationController()
        ordersTab.tabBarItem = UITabBarItem(title: "Ordered", image: UIImage(systemName: "cart.fill"), tag: 0)
        let ordersVC = OrderedServicesViewController.instantiate()
        ordersVC.configureFor(role: .client)
        ordersVC.setCoordinator(coordinator)
        ordersTab.pushViewController(ordersVC, animated: false)
        
        let profileTab = UINavigationController()
        profileTab.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        let profileVC = UserProfileTableViewController.instantiate()
        profileVC.setCoordinator(coordinator)
        profileTab.pushViewController(profileVC, animated: false)
        
        mainTabBar.viewControllers = [ordersTab, profileTab]
        
        return mainTabBar
    }
    //MARK: -
    
    //MARK: - INIT
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    //MARK: -
}
