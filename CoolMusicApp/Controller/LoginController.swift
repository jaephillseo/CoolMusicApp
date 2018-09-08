//
//  LoginController.swift
//  CoolMusicApp
//
//  Created by Alex Kong on 10/21/17.
//  Copyright © 2017 AlexKong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit

class LoginController: UIViewController {
    
    // container view of text fields
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    // Facebook login button
    lazy var facebookLoginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 59, g: 89, b: 152)
        button.setTitle("Login with Facebook", for: .normal)
         button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handleFBLogin), for: .touchUpInside)
        return button
    }()
    
    // Handles FB login
    @objc func handleFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) {
            (result, err) in
            if err != nil {
                print("FB Login failed:", err ?? "")
                return
            }
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {
                return
            }
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            Auth.auth().signIn(with: credentials, completion: {
                (user, error) in
                if error != nil {
                    print("Something went wrong with FB user: ", error ?? "")
                    return
                }
                
                // Successfully logged in to user
                self.dismiss(animated: true, completion: nil)
            })
            
            // Facebook logging debugging
            //self.showEmailAddress()
        }
    }
    
    // Shows graph request of FB user
    func showEmailAddress() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    
    // Firebase user Register button
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 244, g: 244, b: 200)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    // Handles Login/Register dending on selected segment index
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    // Handles Firebase login
    @objc func handleLogin() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                print("Form is not valid")
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            // Successfully logged in to user
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // Handles Firebase register
    @objc func handleRegister() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user: User?, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // Successfully authenticated user
            let ref = Database.database().reference(fromURL: "https://coolmusicapp.firebaseio.com/")
            let usersRef = ref.child("users").child(uid)
            let name = firstName + " " + lastName
            let values = ["name": name, "email": email]
            usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    // Register first name text field
    let firstNameTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "First Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Register last name text field
    let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // First name separator view
    let firstNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Last name separator view
    let lastNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Email text field
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Email separator
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Password text field
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // CMA logo
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "apple-music-icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let appTitleLabel: UILabel = {
       let label = UILabel()
        label.text = "Cool Music App"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // login/register segments
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Login", "Register"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = UIColor.white
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLogingRegisterChange), for: .valueChanged)
        return segmentedControl
    }()
    
    @objc func handleLogingRegisterChange() {
        let selectedSegIndex = loginRegisterSegmentedControl.selectedSegmentIndex
        
        // change facebook login button visablilty
        facebookLoginRegisterButton.isHidden = selectedSegIndex == 1 ? true : false
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: selectedSegIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // change height of inputContainerView
        inputsContainerViewHeightAnchor?.constant = selectedSegIndex == 0 ? 100 : 200
        
        // change height of firstNameTextField
        firstNameTextFieldHeightAnchor?.isActive = false
        firstNameTextFieldHeightAnchor = firstNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                          multiplier: selectedSegIndex == 0 ? 0 : 1/4)
        firstNameTextFieldHeightAnchor?.isActive = true
        
        // change height of lastNameTextField
        lastNameTextFieldHeightAnchor?.isActive = false
        lastNameTextFieldHeightAnchor = lastNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                                    multiplier: selectedSegIndex == 0 ? 0 : 1/4)
        lastNameTextFieldHeightAnchor?.isActive = true
        
        // change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                          multiplier: selectedSegIndex == 0 ? 1/2 : 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                          multiplier: selectedSegIndex == 0 ? 1/2 : 1/4)
        passwordTextFieldHeightAnchor?.isActive = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 240, g: 200, b: 0)
        
        // add subviews to current view
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(iconImageView)
        view.addSubview(appTitleLabel)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(facebookLoginRegisterButton)
    
        // setup sub views
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupFacebookLoginRegisterButton()
        setupAppTitleLabel()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func setupAppTitleLabel() {
        // iconImageView x, y width, height constraints
        appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appTitleLabel.bottomAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 12).isActive = true
        appTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        appTitleLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        appTitleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupFacebookLoginRegisterButton() {
        // facebookLoginRegisterButton x, y width, height constraints
        facebookLoginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookLoginRegisterButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 12).isActive = true
        facebookLoginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        facebookLoginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupLoginRegisterSegmentedControl() {
        // loginRegisterSegmentedControl x, y width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var firstNameTextFieldHeightAnchor: NSLayoutConstraint?
    var lastNameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        
        // inputsContainerView x, y width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 200)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(firstNameTextField)
        inputsContainerView.addSubview(firstNameSeparatorView)
        inputsContainerView.addSubview(lastNameTextField)
        inputsContainerView.addSubview(lastNameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        // firstNameTextField x, y width, height constraints
        firstNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        firstNameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        firstNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        firstNameTextFieldHeightAnchor = firstNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        firstNameTextFieldHeightAnchor?.isActive = true
        
        // lastNameSeparatorView x, y width, height constraints
        firstNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        firstNameSeparatorView.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor).isActive = true
        firstNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        firstNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // lastNameTextField x, y width, height constraints
        lastNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor).isActive = true
        lastNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        lastNameTextFieldHeightAnchor = lastNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        lastNameTextFieldHeightAnchor?.isActive = true
        
        // lastNameSeparatorView x, y width, height constraints
        lastNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        lastNameSeparatorView.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor).isActive = true
        lastNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        lastNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // emailTextField x, y width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        // emailSeparatorView x, y width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // passwordTextField x, y width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        passwordTextFieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton() {
        // loginRegisterButton x, y width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupProfileImageView() {
        // iconImageView x, y width, height constraints
        iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
