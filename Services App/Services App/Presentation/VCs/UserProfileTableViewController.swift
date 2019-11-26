//
//  UserProfileTableViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var userPhotoImageView: UIImageView!
    @IBOutlet private weak var userFirstNameLabel: UILabel!
    @IBOutlet private weak var userLastNameLabel: UILabel!
    @IBOutlet private weak var userAgeLabel: UILabel!
    @IBOutlet private weak var userEmailLabel: UILabel!
    @IBOutlet private weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var userProfession: UILabel!
    @IBOutlet weak var userMoneyLabel: UILabel!
    @IBOutlet private weak var logOutButton: UIButton!
    //MARK: -
    
    //MARK: - PRIVATE WEAK VARIABLES
    private weak var coordinator: MainCoordinator?
    //MARK: -

    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        configureUserPhoto()
        configureLogOutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = coordinator?.currentUser {
            userMoneyLabel.text = "\(user.money)$"
            userFirstNameLabel.text = user.firstName
            userLastNameLabel.text = user.lastName
            userAgeLabel.text = "\(user.age)"
            userEmailLabel.text = user.email
            userPhoneNumberLabel.text = user.phone
            if let profession = coordinator?.profession {
                userProfession.text = profession.name
            } else {
                userProfession.text = "you are a client"
            }
            
            if let image = user.image {
                userPhotoImageView.image = image
            } else {
                userPhotoImageView.createImageWith(text: "\(String(user.firstName.first ?? " "))\(String(user.lastName.first ?? " "))", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
            }
        }
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }
    
    //MARK: - PRIVATE METHODS
    private func configureNavigationItem() {
        title = "My Profile"
    }
    
    private func configureUserPhoto() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height / 2
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.layer.borderColor = UIColor.separator.cgColor
        userPhotoImageView.layer.borderWidth = 1
    }
    
    private func configureLogOutButton() {
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.tintColor = .systemRed
    }
    //MARK: -

    //MARK: PRIVATE IBACTIONS
    @IBAction private func logOutButtonTapped(_ sender: UIButton) {
        coordinator?.logOut()
    }
}
