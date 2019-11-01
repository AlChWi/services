//
//  ChooseRoleViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class ChooseRoleViewController: UIViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var clientRoleButton: UIButton!
    @IBOutlet private weak var providerRoleButton: UIButton!
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var rememberedPassword: String?
    private var rememberedLogin: String?
    //MARK: -
    
    //MARK: - WEAK PRIVATE VARIABLES
    private weak var coordinator: MainCoordinator?
    //MARK: -

    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        configureInstractionLabel()
        configureRoleButtons()
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    func rememberCredentials(login: String?, password: String?) {
        self.rememberedLogin = login
        self.rememberedPassword = password
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureNavigationItem() {
        title = "Create Account"
        let backButton = UIBarButtonItem()
        backButton.title = "Roles"
        navigationItem.backBarButtonItem = backButton
    }
    
    private func configureInstractionLabel() {
        instructionLabel.text = "Choose your role"
    }
    
    private func configureRoleButtons() {
        clientRoleButton.setTitle("Client", for: .normal)
        clientRoleButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        clientRoleButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        providerRoleButton.setTitle("provider", for: .normal)
        providerRoleButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        providerRoleButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func clientRoleButtonTapped(_ sender: UIButton) {
        coordinator?.didChoose(role: .client, withLogin: rememberedLogin, andPassword: rememberedPassword, fromScreen: self)
    }
    
    @IBAction private func providerRoleButtonTapped(_ sender: UIButton) {
        coordinator?.didChoose(role: .provider, withLogin: rememberedLogin, andPassword: rememberedPassword, fromScreen: self)
    }
    //MARK: -
}
