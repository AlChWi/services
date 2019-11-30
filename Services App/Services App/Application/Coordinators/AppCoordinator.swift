//
//  AppCoordinator.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit
import CoreStore

class AppCoordinator: MainCoordinator {
    
    //MARK: - STATIC CONSTANTS
    static let shared = AppCoordinator()
    //MARK: -
    
    //MARK: - PUBLIC VARIABLES
    private(set) var currentVC: UIViewController?
    var currentUser: UserModel?
    var profession: ProfessionModel?
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var currentStrategy: SecondaryCoordinator?
    private var navigationController = UINavigationController()
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func entryForNewUser() {
        let loginVC = LoginViewController.instantiate()
        loginVC.setCoordinator(self)
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    func addService(fromScreen vc: UIViewController) {
        let addServiceStory = UINavigationController()
        let addingScreen = CreateServiceTableViewController.instantiate()
        addingScreen.setCoordinator(self)
        addServiceStory.pushViewController(addingScreen, animated: false)
        
        vc.present(addServiceStory, animated: true)
    }
    
    func showServicesForClient(fromScreen vc: UIViewController) {
        let servicesStory = UINavigationController()
        let availableServicesScreen = AllServicesViewController.instantiate()
        availableServicesScreen.setCoordinator(self)
        servicesStory.modalPresentationStyle = .fullScreen
        servicesStory.pushViewController(availableServicesScreen, animated: false)
        
        vc.present(servicesStory, animated: true)
    }
    
    func chooseDate(forService service: ServiceModel, fromScreen vc: UIViewController) {
        let chooseDateVC = ChooseDateViewController.instantiate()
        chooseDateVC.modalPresentationStyle = .overFullScreen
        guard let client = currentUser as? ClientModel else {
            return
        }
        chooseDateVC.configure(forService: service, andClient: client)

        vc.present(chooseDateVC, animated: true)
    }
    
    func logIn(forRole role: Role, withUser user: UserModel, fromModalScreen modalVC: UIViewController?, profession: ProfessionModel?) {
        setCoordinatorStrategy: switch role {
        case .provider:
            if let profession = profession {
                self.profession = profession
            }
            currentStrategy = ProviderCoordinator(coordinator: self)
        case .client:
            currentStrategy = ClientCoordinator(coordinator: self)
        }
        
        try? DataService.shared.rememberUser(user)
        
        currentUser = user
        navigationController.pushViewController(currentStrategy?.constructTabBar() ?? UIViewController(), animated: true)
        
        if let vc = modalVC {
            vc.dismiss(animated: true, completion: nil)
        }
        
        if let loginScreenIndex = navigationController.viewControllers.firstIndex(where: { $0 is LoginViewController } ) {
            navigationController.viewControllers.remove(at: loginScreenIndex)
        }
    }
    
    func showProfessionSelection(navVC: UINavigationController) {
        let vc = ProfessionSelectionViewController()
        vc.coordinator = self
        navVC.pushViewController(vc, animated: true)
    }
    
    func showCategorySelection(navVC: UINavigationController) {
        let vc = CategorySelectionViewController()
        vc.coordinator = self
        navVC.pushViewController(vc, animated: true)
    }
    
    func didFinishEditingUser(withResult result: UserModel) {
        currentUser = result
    }
    
    func openEdit(from screen: UIViewController) {
        guard
            let currentUser = currentUser else {
                return
        }
        let vc = EditProfileTableViewController.instantiate()
        vc.setCoordinator(self)
        switch currentUser {
        case is ProviderModel:
            vc.prepareEditing(forRole: .provider, user: currentUser)
        case is ClientModel:
            vc.prepareEditing(forRole: .client, user: currentUser)
        default:
            return
        }
        let navVC = UINavigationController()
        navVC.pushViewController(vc, animated: false)
        navVC.modalPresentationStyle = .fullScreen
        screen.present(navVC, animated: true, completion: nil)
    }
    
    func logOut() {
        DataService.shared.logOut()
        currentUser = nil
        profession = nil
        
        let loginScreen = LoginViewController.instantiate()
        loginScreen.setCoordinator(self)
        
        navigationController.viewControllers = [loginScreen]
    }
    
    func register(fromScreen viewController: UIViewController,
                  withLogin login: String?,
                  andPassword password: String?) {
        let signUpStory = UINavigationController()
        let chooseRoleVC = ChooseRoleViewController.instantiate()
        chooseRoleVC.rememberCredentials(login: login, password: password)
        chooseRoleVC.setCoordinator(self)
        signUpStory.pushViewController(chooseRoleVC, animated: false)
        
        viewController.present(signUpStory, animated: true)
    }
    
    func didChoose(role: Role,
                   withLogin login: String?,
                   andPassword password: String?,
                   fromScreen vc: UIViewController) {
        let editProfileVC = EditProfileTableViewController.instantiate()
        editProfileVC.prepareCreation(forRole: role, withLogin: login, andPassword: password)
        editProfileVC.setCoordinator(self)
        if let navigation = vc.navigationController {
            navigation.pushViewController(editProfileVC, animated: true)
        } else {
            vc.present(editProfileVC, animated: true)
        }
    }
    //MARK: -
    
    //MARK: - INIT
    private init() {
        currentVC = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        
        //MARK: - FIND LOGGED USER
        if let user = try? DataService.shared.getCurrentUser() {
            currentUser = user
            if let user = user as? ProviderModel {
                profession = user.profession
            }
        }
        //MARK: -
        let result = try? UserEntity.findWithMostMoney(inDataStack: DataService.shared.sharedCoreStore)
        print(result?.money)
        ProviderEntity.createWithCoreStore(store: DataService.shared.sharedCoreStore)

    }
    //MARK: -
}
