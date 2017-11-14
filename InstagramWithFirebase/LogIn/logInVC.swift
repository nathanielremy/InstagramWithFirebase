//
//  logInVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 14/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit

class LogInVC: UIViewController {
    
    //MARK: Stored properties
    let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(0, 120, 175)
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(149, 204, 244)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    let switchToSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Dont have an account?  ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up.", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.rgb(17, 154, 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSwitchToSignUp), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleSwitchToSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 150)
        
        view.addSubview(switchToSignUpButton)
        switchToSignUpButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        setUpInputFields()
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.backgroundColor = UIColor.rgb(17, 154, 237)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.rgb(149, 204, 244)
            loginButton.isEnabled = false
        }
    }
    
    fileprivate func setUpInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: self.logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: 140)
    }
}
