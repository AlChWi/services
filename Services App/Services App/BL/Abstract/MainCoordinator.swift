//
//  MainCoordinator.swift
//  Services App
//
//  Created by Perov Alexey on 21.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

protocol MainCoordinator: class {
    var currentUser: UserModel? { get set }
    var currentVC: UIViewController? { get }
    var profession: ProfessionModel? { get set }
    
    func entryForNewUser()
    func logIn(forRole role: Role,
               withUser user: UserModel,
               fromModalScreen vc: UIViewController?, profession: ProfessionModel?)
    func register(fromScreen viewController: UIViewController,
                  withLogin login: String?,
                  andPassword password: String?)
    func didChoose(role: Role,
                   withLogin login: String?,
                   andPassword password: String?,
                   fromScreen vc: UIViewController)
    func addService(fromScreen vc: UIViewController)
    func showServicesForClient(fromScreen vc: UIViewController)
    func chooseDate(forService service: ServiceModel, fromScreen vc: UIViewController)
    func showProfessionSelection(navVC: UINavigationController)
    func showCategorySelection(navVC: UINavigationController)
    func logOut()
}
