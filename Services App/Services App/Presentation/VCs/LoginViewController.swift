//
//  LoginViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var loginTextField: UITextField! {
        didSet {
            loginTextField.delegate = self
        }
    }
    @IBOutlet private weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var didCheckLogin = false
    private var coordinator: MainCoordinator?
    private var canFindUserWithLogin = false
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        configureTextFields()
        setGoTextForLoginButton()
        configureAppNameLabel()
        addKeyboardObservers(for: self)
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureNavigationItem() {
        title = "Login"
    }
    
    private func configureTextFields() {
        loginTextField.placeholder = "Login"
        passwordTextField.placeholder = "Password"
    }
    
    private func setGoTextForLoginButton() {
        loginButton.setTitle("Go", for: .normal)
    }
    
    private func configureAppNameLabel() {
        appNameLabel.text = "Services"
    }
    
    private func addKeyboardObservers(for: UIViewController) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleKeyboard(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
        }

        if notification.name == UIResponder.keyboardWillShowNotification {
            let animatorForKeyboardUp = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
                self.loginButton.snp.updateConstraints { (make) in
                    make.top.equalTo(self.passwordTextField.snp.bottom).offset(45)
                }
                self.view.layoutIfNeeded()
            }
            animatorForKeyboardUp.startAnimation()
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            let animatorForKeyboardDown = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
                 self.loginButton.snp.updateConstraints { (make) in
                     make.top.equalTo(self.passwordTextField.snp.bottom).offset(150)
                 }
                self.view.layoutIfNeeded()
             }
             animatorForKeyboardDown.startAnimation()
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func loginTextFieldEditingChanged(_ sender: UITextField) {
        didCheckLogin = false
        canFindUserWithLogin = false
        passwordTextField.isHidden = true
        setGoTextForLoginButton()
    }
    
    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        if didCheckLogin {
            if canFindUserWithLogin {
                guard let password = passwordTextField.text,
                    let login = loginTextField.text else {
                        return
                }
                if let user = DataService.shared.findUser(withLogin: login, andPassword: password) {
                    if let client = user as? ClientModel {
                        coordinator?.logIn(forRole: .client, withUser: client, fromModalScreen: nil, profession: nil)
                    }
                    if let provider = user as? ProviderModel {
                        coordinator?.logIn(forRole: .provider, withUser: provider , fromModalScreen: nil, profession: provider.profession)
                    }
                } else {
                    let alert = UIAlertController(title: "Sign In", message: "Wrong password", preferredStyle: .alert)
                    present(alert, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                coordinator?.register(fromScreen: self, withLogin: loginTextField.text, andPassword: passwordTextField.text)
            }
        } else {
            guard let login = loginTextField.text else {
                didCheckLogin = false
                passwordTextField.isHidden = true
                return
            }
            didCheckLogin = true
            passwordTextField.isHidden = false
            
            if DataService.shared.canFindUser(withLogin: login) {
                canFindUserWithLogin = true
                loginButton.setTitle("Login", for: .normal)
            } else {
                canFindUserWithLogin = false
                loginButton.setTitle("Sign Up", for: .normal)
            }
            
        }
    }
    //MARK: -
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !didCheckLogin {
            loginButtonTapped(loginButton)
        }
        textField.resignFirstResponder()
        return false
    }
}
//MARK: -
