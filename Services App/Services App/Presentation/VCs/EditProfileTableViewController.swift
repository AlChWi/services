//
//  EditProfileTableViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, Instantiatable {
    
    private enum State {
        case creating
        case editing
    }
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var userPhotoImageView: UIImageView!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var chooseProfessionButton: UIButton!
    //MARK: -
    
    //MARK: - WEAK PRIVATE VARIABLES
    private weak var coordinator: MainCoordinator?
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var role: Role?
    private var rememberedLogin: String?
    private var rememberedPassword: String?
    private var state: State = .creating
    private var initialData: UserModel?
    
    //MARK: - PRIVATE USER INFO VARIABLES
    private var photo: Data?
    private var firstName: String {
        return firstNameTextField.text ?? ""
    }
    private var lastName: String {
        return lastNameTextField.text ?? ""
    }
    private var age: Int16? {
        guard let age = ageTextField.text else {
            return nil
        }
        return Int16(age)
    }
    private var email: String {
        return emailTextField.text ?? ""
    }
    private var phoneNumber: String {
        return phoneNumberTextField.text ?? ""
    }
    private var login: String {
        return loginTextField.text ?? ""
    }
    private var password: String {
        return passwordTextField.text ?? ""
    }
    private var profession: ProfessionModel?
    //MARK: -
    
    private lazy var imageTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    private lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let role = role else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if role == .client {
            chooseProfessionButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(professionSelected(_:)), name: .professionSelected, object: nil)
        configureNavigationItem()
        enableDoneButtonIfSavePossible()
        fillRememberedCredentials()
        configureUserPhotoImageView()
    }
    @objc
    func professionSelected(_ notidication: Notification) {
        guard
            let professionFromNotification = notidication.userInfo?["profession"] as? ProfessionModel else {
                print("ERRRORRRR")
                return
        }
        profession = professionFromNotification
        chooseProfessionButton.setTitle(profession?.name, for: .normal)
        enableDoneButtonIfSavePossible()
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func prepareCreation(forRole role: Role, withLogin login: String?, andPassword password: String?) {
        self.state = .creating
        self.role = role
        self.rememberedLogin = login
        self.rememberedPassword = password
    }
    
    func prepareEditing(forRole role: Role, user: UserModel) {
        self.state = .editing
        self.role = role
        self.initialData = user
    }
    
    func setCoordinator(_ coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureNavigationItem() {
        title = "Create Account"
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func configureUserPhotoImageView() {
        userPhotoImageView.isUserInteractionEnabled = true
        userPhotoImageView.addGestureRecognizer(imageTap)
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.createImageWith(text: "Add Image", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
    }
    
    private func fillRememberedCredentials() {
        if let login = rememberedLogin {
            loginTextField.text = login
        }
        if let password = rememberedPassword {
            passwordTextField.text = password
        }
        if state == .editing {
            firstNameTextField.text = initialData?.firstName
            lastNameTextField.text = initialData?.lastName
            emailTextField.text = initialData?.email
            ageTextField.text = "\(initialData?.age ?? 18)"
            phoneNumberTextField.text = initialData?.phone
            passwordTextField.text = initialData?.password
            loginTextField.text = initialData?.login
            if let image = initialData?.image {
                userPhotoImageView.image = image
                photo = image.pngData()
            }
        }
    }
    
    private func checkUserNameAvailability() -> Bool {
        return !DataService.shared.canFindUser(withLogin: login)
    }
    
    @discardableResult
    private func enableDoneButtonIfSavePossible() -> Bool {
        if !firstName.isEmpty, !lastName.isEmpty, let age = age, age > 17, !email.isEmpty, !phoneNumber.isEmpty, !login.isEmpty, !password.isEmpty, email.isValidEmail(), phoneNumber.isValidPhoneNumber(), phoneNumber.count > 4, phoneNumber.count < 20 {
            doneButton.isEnabled = true
            return true
        } else {
            doneButton.isEnabled = false
            return false
        }
    }
    
    private func checkSpacesInNames() {
        while firstName.last == " " {
            firstNameTextField.text?.removeLast()
         }
         while firstName.first == " " {
             firstNameTextField.text?.removeFirst()
         }
         while lastName.last == " " {
             lastNameTextField.text?.removeLast()
         }
         while lastName.first == " " {
             lastNameTextField.text?.removeFirst()
         }
    }
    
    @objc private func doneButtonTapped() {
        checkSpacesInNames()
        
        if !enableDoneButtonIfSavePossible() {
            let alert = UIAlertController(title: "User Info", message: "Check info in textfields", preferredStyle: .alert)
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        guard let age = age else {
            return
        }
        
        switch state {
        case .creating:
            if !checkUserNameAvailability() {
                let alert = UIAlertController(title: "User Info", message: "There's another user with such login", preferredStyle: .alert)
                present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alert.dismiss(animated: true, completion: nil)
                }
                loginTextField.layer.borderColor = UIColor.red.cgColor
                loginTextField.layer.borderWidth = 1
                loginTextField.layer.cornerRadius = 6
                loginTextField.layer.masksToBounds = true
                return
            }
            switch role {
            case .client:
                do {
                    let client = ClientModel(login: login, password: password, firstName: firstName, lastname: lastName, age: age, email: email, phone: phoneNumber, image: photo)
                    try DataService.shared.create(client: client)
                    coordinator?.logIn(forRole: role!, withUser: client, fromModalScreen: self, profession: nil)
                } catch {
                    print(error)
                }
            case .provider:
                guard
                    let profession = profession else {
                        let alert = UIAlertController(title: "Not enough info", message: "Choose your profession", preferredStyle: .alert)
                        present(alert, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                        return
                }
                do {
                    let provider = ProviderModel(login: login, password: password, firstName: firstName, lastname: lastName, age: age, email: email, phone: phoneNumber, image: photo, profession: profession)
                    try DataService.shared.create(provider: provider, profession: profession)
                    coordinator?.logIn(forRole: role!, withUser: provider, fromModalScreen: self, profession: provider.profession)
                } catch {
                    print(error)
                }
            case .none:
                print("Somethings is wrong")
            }
        case .editing:
            guard
                let userID = initialData?.id else {
                    return
            }
            let entity = DataService.shared.findUser(byID: userID)
            try? DataService.shared.sharedCoreStore.perform(synchronous: { transaction in
                let entityToEdit = transaction.edit(entity)!
                entityToEdit.firstName = firstName
                entityToEdit.lastName = lastName
                entityToEdit.age = age
                entityToEdit.email = email
                entityToEdit.phone = phoneNumber
                entityToEdit.image = photo
                entityToEdit.login = login
                entityToEdit.password = password
            })
            let finalEntity = DataService.shared.findUser(byID: userID)
            switch role {
            case .provider:
                guard let result = ProviderModel(fromEntity: finalEntity as? ProviderEntity) else { return  }
                coordinator?.didFinishEditingUser(withResult: result)
            case .client:
                guard let result = ClientModel(fromEntity: finalEntity as? ClientEntity) else { return }
                coordinator?.didFinishEditingUser(withResult: result)
            case .none:
                return
            }
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    @objc private func handleTap() {
        let alertSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        let chooseFromPhotoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) { (UIAlertAction) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        alertSheet.addAction(chooseFromPhotoLibraryAction)
        
        let removePhotoAction = UIAlertAction(title: "Remove photo", style: .destructive) { (UIAlertAction) in
            self.userPhotoImageView.createImageWith(text: "Add Image", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
            self.photo = nil
        }
        alertSheet.addAction(removePhotoAction)
        
        removePhotoAction.isEnabled = photo == nil ? false : true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            
        }
        
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true)
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func firstNameTextFieldEditingChanged(_ sender: UITextField) {
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func lastNameTextFieldEditingChanged(_ sender: UITextField) {
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func ageTextFieldEditingChanged(_ sender: UITextField) {
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func emailTextFieldEditingChanged(_ sender: UITextField) {
        while emailTextField.text?.last == " " {
            emailTextField.text?.removeLast()
        }
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func phoneNumberTextFieldEditingChanged(_ sender: UITextField) {
        while phoneNumberTextField.text?.last == " " {
            phoneNumberTextField.text?.removeLast()
        }
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func loginTextFieldEditingChanged(_ sender: UITextField) {
        while loginTextField.text?.last == " " {
            loginTextField.text?.removeLast()
        }
        enableDoneButtonIfSavePossible()
    }
    
    @IBAction private func passwordTextFieldEditingChanged(_ sender: UITextField) {
        while passwordTextField.text?.last == " " {
            passwordTextField.text?.removeLast()
        }
        enableDoneButtonIfSavePossible()
    }
    @IBAction func didTapChooseProfession(_ sender: UIButton) {
        coordinator?.showProfessionSelection(navVC: self.navigationController!)
    }
    //MARK: -
}

//MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension EditProfileTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        userPhotoImageView.image = image
        photo = image?.jpegData(compressionQuality: 1)
        
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK: -


extension String {
     func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRexEx = "^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$"
        
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRexEx)
        return phonePredicate.evaluate(with: self)
    }
}
