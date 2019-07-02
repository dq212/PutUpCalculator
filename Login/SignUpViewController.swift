//
//  SignUpViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/9/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import CoreData

class SignUpViewController: UIViewController, UIScrollViewDelegate {
    
    //logoButton
    let logoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "logo_sign_in_").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
   
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    var svContentView:UIView = {
        let v = UIView()
        return v
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.returnKeyType = .done
        tf.keyboardAppearance = .dark
        // tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    var stackView = UIStackView()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            createAccountButton.backgroundColor = .mainRed()
            createAccountButton.isEnabled = true
        } else {
            createAccountButton.backgroundColor = .darkGray
            createAccountButton.isEnabled = false
        }
    }
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.keyboardAppearance = .dark
        tf.returnKeyType = .done
        return tf
    }()
    
    //createAccountButton
    let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let alreadyRegisteredButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor:UIColor.black])
        
        attributedTitle.append(NSAttributedString(string:"Sign In", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainRed()]))

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.isEnabled = true
        //button.tintColor = UIColor(r: 164, g: 8, b: 0)
        button.addTarget(self, action: #selector(handleGoToSignIn), for: .touchUpInside)
        return button
    }()
    
    @objc func handleGoToSignIn() {
        
        //let loginController = LoginViewController()
        navigationController?.popViewController(animated: true)
        // present(signupController, animated: true, completion: nil)
        //performSegue(withIdentifier: "GoToRegister", sender: nil)
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height - 60) * (show ? 1 : -1)
        
        if !show {
            let returnHeight = 0
            kbHeight = CGFloat(returnHeight)
        }
        let point:CGPoint = CGPoint(x: 0.0, y: kbHeight)
        scrollView.setContentOffset(point, animated: true)
        //scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }

    
    
    var r:AnyObject!
    
    //var managedObjectContext:NSManagedObjectContext?
    
    @objc func didTapSignUp(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
    Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showAlert("Enter a valid email.")
                    case .emailAlreadyInUse:
                        self.showAlert("Email already in use.")
                    default:
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
                return
            }
            
              let values = ["email":self.emailTextField.text, "password":password]
            
            guard let uid = user?.uid else {
                return
            }
          
            self.signIn(uid: uid, values: values as [String : AnyObject])
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, createAccountButton])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(svContentView)
        svContentView.addSubview(stackView)
        svContentView.addSubview(logoButton)
        
        view.backgroundColor = .white
        svContentView.addSubview(logoButton)
        
        logoButton.anchor(top: svContentView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 180)
       
        logoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        view.addSubview(alreadyRegisteredButton)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop:0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height*1.25)
        
        stackView.anchor(top: logoButton.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 70, paddingBottom: 0, paddingRight: 70, width: 0, height: 120)
        view.addSubview(stackView)
        
        alreadyRegisteredButton.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //setupInputFields()
        
        //createAccountButton.layer.cornerRadius = 5
    }
    
    fileprivate func setupInputFields() {
        
       
        
       
    }
    
    
 func didTapBackToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "MotoPreserve", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.view.tintColor = UIColor.mainRed()
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signIn(uid:String, values:[String: AnyObject]) {
        
        let ref = Database.database().reference(fromURL: "https://motopreserve-ebd6b.firebaseio.com/")
        let usersReference = ref.child("users").child((uid))
        self.r = ref
      
        usersReference.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
           // print("Saved the user successfully")
        }
        let allBikesViewController = AllBikesViewController()
        let navController = UINavigationController(rootViewController: allBikesViewController)
        self.present(navController, animated: true, completion: nil)

    }
    
}

