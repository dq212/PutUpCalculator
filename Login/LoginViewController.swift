//
//  LoginViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/9/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import DataCache


class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    let userCache = DataCache(name: "userCache")
    var accepted = false
    
//    KEYBOARD
//    let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
//    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//    let toolBar = UIToolbar()
    
    //signInButton
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSignIn(_:)), for: .touchUpInside)
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    
    //logoButton
    let logoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "logo_sign_in_").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = true
        return button
    }()
    
//    let profileImageButton: UIButton = {
//        let button = UIButton()
//        button.setImage(#imageLiteral(resourceName: "add_userPhoto").withRenderingMode(.alwaysOriginal), for: .normal)
//
//        button.addTarget(self, action: #selector(handleProfileImage), for: .touchUpInside)
//        button.backgroundColor = .blue
//        return button
//    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Forgot Password? ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor:UIColor.black])
        
        attributedTitle.append(NSAttributedString(string:"Get new password", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainRed()]))
        //("Don't have and account? Register", for: .normal)
        button.isEnabled = true
        button.setAttributedTitle(attributedTitle, for: .normal)
        //button.tintColor = UIColor(r: 164, g: 8, b: 0)
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    
    let gotoRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor:UIColor.black])
        
        attributedTitle.append(NSAttributedString(string:"Register", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainRed()]))
        //("Don't have and account? Register", for: .normal)
        button.isEnabled = true
        button.setAttributedTitle(attributedTitle, for: .normal)
        //button.tintColor = UIColor(r: 164, g: 8, b: 0)
        button.addTarget(self, action: #selector(handleGoToRegister), for: .touchUpInside)
        return button
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
    
    @objc func doneClicked(){
       
    }
    
    @objc func handleForgotPassword() {
//        print("send me an email")
        guard let email = emailTextField.text else {return}
        if (isValidEmail(testStr: email) ) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
            // Your code here
                if error == nil {
                    self.didTapForgotPassword(self.forgotPasswordButton)
                } else {
                    print(error ?? "")
                }
            }
        } else {
            self.showAlert("Please enter a valid email address in the email field, then press \"Get new password\"\n\nThank you,\nThe MotoPreserve Team")
        }
       
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @objc func handleGoToRegister() {
        let signupController = SignUpViewController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc func handleProfileImage() { 
       // print(123)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
//        if let _ = FIRAuth.auth()?.currentUser {
//           // self.signIn()
//        }
    }
    
    
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signInButton.backgroundColor = .mainRed()
            signInButton.isEnabled = true
        } else {
            signInButton.backgroundColor = .darkGray
            signInButton.isEnabled = false
        }
    }
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = .white
        tf.backgroundColor = UIColor(white: 0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.keyboardAppearance = .dark
        return tf
    }()
    
    
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
    
    let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white:0, alpha:0.8)
        return v
    }()
    
    let tcView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 5
        return v
    }()
    
    let legalCopy: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .black
        tv.textAlignment = .center
        tv.isEditable = false
        tv.isSelectable = false
        tv.isEditable = false
        tv.text = "Please accept the\nTerms & Conditions to get started with MotoPreserve App."
        return tv
    }()
    
    let legalButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        button.setTitle("Agree", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapAgree(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.britishGreen()
        button.layer.cornerRadius = 2
        return button
    }()
    
    let disagreeButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        button.setTitle("Disagree", for: .normal)
        button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(didTapDisagree(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.mainRed()
        button.layer.cornerRadius = 2
        return button
    }()
    
    let readLegalButton : UIButton = {
    let button = UIButton(type: .system)
    button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
    button.setTitle("View full Terms & Conditons", for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.addTarget(self, action: #selector(didTapReadLegal(_:)), for: .touchUpInside)
   // button.backgroundColor = UIColor.mainRed()
    button.layer.cornerRadius = 2
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
    
    var stackView:UIStackView?
    
    

    let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
        // Print "OK Tapped" to the screen when the user taps OK
//        print("OK Tapped")
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
    func checkLegal() {
        print("CHCECKING")
       if (UserDefaults.standard.bool(forKey: "hasAgreedToLegal") == false) {

        bgView.anchor(top: svContentView.topAnchor, left: svContentView.leftAnchor, bottom: svContentView.bottomAnchor, right: svContentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tcView.anchor(top: svContentView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 200, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 300, height: 280)
        tcView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        legalCopy.anchor(top: tcView.topAnchor, left: tcView.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 240, height: 200)
        legalButton.anchor(top: nil, left: nil, bottom: tcView.bottomAnchor, right: tcView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 40, width: 100, height: 30)
        disagreeButton.anchor(top: nil, left: tcView.leftAnchor, bottom: tcView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom:20, paddingRight: 0, width: 100, height: 30)
        
        readLegalButton.anchor(top: nil, left: nil, bottom: tcView.bottomAnchor, right:nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 70, paddingRight: 0, width: 220, height: 30)
        readLegalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tcView.layer.transform = CATransform3DMakeScale(0, 0, 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.tcView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
        }
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height-60) * (show ? 1 : -1)
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        self.passwordTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        self.emailTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
      
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        //view.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//
        handleSignUp()

        registerDefaults()

        view.addSubview(scrollView)
        scrollView.addSubview(svContentView)
        svContentView.addSubview(gotoRegisterButton)
        svContentView.addSubview(forgotPasswordButton)
        svContentView.addSubview(stackView!)
        svContentView.addSubview(logoButton)
        
        scrollView.addSubview(bgView)
        
        bgView.addSubview(tcView)
        tcView.addSubview(legalButton)
        tcView.addSubview(disagreeButton)
        tcView.addSubview(legalCopy)
        tcView.addSubview(readLegalButton)
        
   
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop:0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height*1.25)
        
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 10
      
        stackView?.anchor(top: logoButton.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 20, paddingLeft: 70, paddingBottom: 0, paddingRight: 70, width: 0, height: 120)
        svContentView.addSubview(stackView!)
        gotoRegisterButton.anchor(top: stackView?.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        forgotPasswordButton.anchor(top: gotoRegisterButton.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        logoButton.anchor(top: svContentView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:180, height: 180)
        logoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

       //setupInputFields()
        
        checkLegal()
    }
    
    func registerDefaults() {
        let dictionary: [String: Any] = [ "hasViewedVideo": false, "hasAgreedToLegal": false ]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    fileprivate func setupInputFields() {
        
     
    }
    
   
     func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
    
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            self.userCache.write(object:uid as NSCoding, forKey: "uid")
            
            let usernameValues = ["email": email, "password": password]
            let values = [uid: usernameValues]
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: {
                (err, ref) in
                if let err = err {
                    print("Failed to save user info in db:", err)
                    return
                }
                print ("Successfully save user info to db")
                //self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @objc func didTapReadLegal(_ sender: UIButton) {
        print("read legal clicked")
        let legalController = LegalViewController()
        let navController = UINavigationController(rootViewController: legalController)
        self.present(navController, animated:true, completion:nil)
    }
    
    @objc func didTapAgree(_ sender: UIButton) {
        print("agree button tapped")
        UserDefaults.standard.set(true, forKey: "hasAgreedToLegal")
       tcView.removeFromSuperview()
        showLegalAgreementSuccessAnimation(vc: self, v: bgView)
    }
    @objc func didTapDisagree(_ sender: UIButton) {
        print("disagree button tapped")
        showLegalDisgreementSuccessAnimation(vc: self)
       // bgView.removeFromSuperview()
    }
    
    @objc func didTapForgotPassword(_ sender: UIButton) {
       self.showAlert("If you are a current user, an email will be sent to your registered address.\n\nIf you do not receive an email, please check your spam folder or email us directly at info@motopreserve.com.")
    }
    
    @objc func didTapSignIn(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            guard let _ = user else {
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .userNotFound:
                            self.showAlert("User account not found. Try registering or reset your password.")
                        case .wrongPassword:
                            self.showAlert("Incorrect username/password combination")
                        default:
                            self.showAlert("Error: \(error.localizedDescription)")
                        }
                    }
                    return
                }
                assertionFailure("user and error are nil")

                return
            }
                  self.signIn()
        })
    }
    
   
    
    func showAlert(_ message: String) {
       

        let attributedTitle = NSMutableAttributedString(string: "MotoPreserve ", attributes: [ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.mainRed()])
        let str = attributedTitle.string
        let alertController = UIAlertController(title: str as String, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor.mainRed()
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signIn() {
//      
        let allBikesViewController = AllBikesViewController()
        let navController = UINavigationController(rootViewController: allBikesViewController)
        self.present(navController, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
}
//
//extension UIView {
//    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right:NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
//        \
//        translatesAutoresizingMaskIntoConstraints = false
//        
//        if let top = top {
//            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
//        }
//        if let left = left {
//            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
//        }
//        if let bottom = bottom {
//            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
//        }
//        if let right = right {
//            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
//        }
//        
//        if width != 0 {
//            self.widthAnchor.constraint(equalToConstant: width).isActive = true
//        }
//        
//        if height != 0 {
//            self.heightAnchor.constraint(equalToConstant: height).isActive = true
//        }
//        
//    }
//}
