//
//  CreateServiceTableViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class CreateServiceTableViewController: UITableViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    //MARK: - LAZY
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addButtonTapped))
    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    //MARK: -
    
    private var coordinator: MainCoordinator?
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableAddButtonIfSavePossible()
        configureNavigationItem()
        configureServiceNameTextFieldPlaceholder()
        configureInstructionLabel()
        
    }
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    //MARK: - PRIVATE METHODS
    @discardableResult
    private func enableAddButtonIfSavePossible() -> Bool {
    if !(serviceNameTextField.text?.isEmpty ?? true)
        && serviceNameTextField.text?.last != " "
        && serviceNameTextField.text?.first != " " {
            addButton.isEnabled = true
            return true
        } else {
            addButton.isEnabled = false
            return false
        }
    }
    
    private func configureNavigationItem() {
        title = "Add Service"
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func configureInstructionLabel() {
        instructionLabel.text = "Name your service"
    }

    private func configureServiceNameTextFieldPlaceholder() {
        serviceNameTextField.placeholder = "Service Name"
    }
    
    @objc private func addButtonTapped() {
        if !enableAddButtonIfSavePossible() {
            return
        }
        
        guard let name = serviceNameTextField.text,
            !name.isEmpty,
            let user = coordinator?.currentUser else {
            return
        }
        do {
            let service = ServiceModel(name: name, providerID: user.id)
            try DataService.shared.create(service: service)
            let userInfo = [Constants.UserInfoKeys.service : service]
            NotificationCenter.default.post(name: .serviceCreated, object: nil, userInfo: userInfo)
        } catch ServiceCreationErrors.alreadyExisted {
            let alert = UIAlertController(title: "Service Creation", message: "You already have this service", preferredStyle: .alert)
            present(alert, animated: true)
        } catch {
            print(error)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func serviceNameTextFieldEditingChanged(_ sender: UITextField) {
        enableAddButtonIfSavePossible()
    }
    //MARK: -
}
