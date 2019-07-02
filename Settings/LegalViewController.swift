//
//  LegalViewController.swift
//  MotoPreserve-App
//
//  Created by DANIEL I QUINTERO on 4/9/18.
//  Copyright © 2018 DANIEL I QUINTERO. All rights reserved.
//


import UIKit
import FirebaseAuth
import Firebase
import MessageUI

class LegalViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    var backBarButton:UIBarButtonItem?
    
    var titleBar:TitleBar = TitleBar()
    
    let scrollView: UIScrollView = {
       let sv = UIScrollView()
        return sv
    }()
    
    let legalView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return view
    }()
    
//    \n\nPurchases\n\nIf you wish to purchase any product or service made available through the Service (\"Purchase\"), you may be asked to supply certain information relevant to your Purchase including, without limitation, your …
    
    let legalText:UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir-Medium", size: 16)
        tv.textAlignment = .left
        tv.isEditable = false
        tv.isSelectable = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(white: 0, alpha: 0.0)
       tv.text = "Please read these Terms and Conditions (\"Terms\", \"Terms and Conditions\") carefully before using the MotoPreserve mobile application (the \"Service\") and www.motopreserve.com operated by MotoPreserve, LLC (\"us\", \"we\", or \"our\").\n\nYour access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Service.\n\nBy accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.\n\nContent\n\nOur Service allows you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material (\"Content\"). You are responsible for adhering to any third-party Terms & Conditions.\n\nLegal\n\nOur Service may contain information or services that are not owned or controlled by MotoPreserve, LLC.\n\nMotoPreserve, LLC has no control over, and assumes no responsibility for, the content, information, or practices of any third party services. You further acknowledge and agree that MotoPreserve, LLC shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such services.\n\nLinks To Other Web Sites and Apps\n\nOur Service may contain links to third-party web sites or services that are not owned or controlled by MotoPreserve, LLC.\n\nMotoPreserve, LLC has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third party web sites or services. You further acknowledge and agree that MotoPreserve, LLC shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such web sites or services.\n\nPurchases\n\nIf you wish to purchase any product or service made available through the Service (\"Purchase\"), you may be asked to supply certain information relevant to your Purchase including, without limitation, your credit card number, the expiration date of your credit card, your billing address, and your shipping information.\n\nYou represent and warrant that: (i) you have the legal right to use any credit card(s) or other payment method(s) in connection with any Purchase; and that (ii) the information you supply to us is true, correct and complete.\n\nThe service may employ the use of third party services for the purpose of facilitating payment and the completion of Purchases. By submitting your information, you grant us the right to provide the information to these third parties subject to our Privacy Policy.\n\nWe reserve the right to refuse or cancel your order at any time for reasons including but not limited to: product or service availability, errors in the description or price of the product or service, error in your order or other reasons.\n\nWe reserve the right to refuse or cancel your order if fraud or an unauthorized or illegal transaction is suspected.\n\nAvailability, Errors and Inaccuracies\n\nWe are constantly updating product and service offerings on the Service. We may experience delays in updating information on the Service and in our advertising on other web sites. The information found on the Service may contain errors or inaccuracies and may not be complete or current. Products or services may be mispriced, described inaccurately, or unavailable on the Service and we cannot guarantee the accuracy or completeness of any information found on the Service.\n\nWe therefore reserve the right to change or update information and to correct errors, inaccuracies, or omissions at any time without prior notice.\n\n\n\nWe reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 10 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion. MotoPreserve reserves the right in its sole discretion, to change, limit, of discontinue any aspect, content, or feature of the app, as well as any aspect pertaining to any use of the app.\n\nTermination\n\nMotoPreserve may terminate or suspend any and all Services and/or your MotoPreserve account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination of your account, your right to use the Services will immediately cease. All provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity and limitations of liability.\n\nContact Us\n\nIf you have any questions about these Terms, please contact us."
        return tv
    }()
    
    let legalAcceptButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("E-mail Us", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.addSubview(scrollView)
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        
//        contactEmailButton.addTarget(self, action: #selector(emailButtonHandler), for: .touchUpInside)
        
        view.backgroundColor = .white
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        //view.addSubview(contactView)
        // contactView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 44, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollView.addSubview(legalText)
        legalText.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 95, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, width: 0, height:0)
        
//        view.addSubview(contactEmailButton)
//        contactEmailButton.anchor(top: contactText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
//        contactEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "Legal - Terms & Conditons", ypos: 64, color:.black)
        
    }
    
    @objc func cancelThisView() {
        dismiss(animated: true, completion: nil)
    }
    
//    @objc func emailButtonHandler() {
//
//        if !MFMailComposeViewController.canSendMail() {
//            //            print("Mail services are not available")
//            return
//        }
//
//        let composeVC = MFMailComposeViewController()
//        composeVC.mailComposeDelegate = self
//
//        // Configure the fields of the interface.
//        composeVC.setToRecipients(["motopreserve@gmail.com"])
//        composeVC.setSubject("MotoPreserve Customer Feedback")
//        //composeVC.setMessageBody("Hello from California!", isHTML: false)
//
//        // Present the view controller modally.
//        self.present(composeVC, animated: true, completion: nil)
//
//    }
    
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//
//        // Dismiss the mail compose view controller.
//        controller.dismiss(animated: true, completion: nil)
//    }
    
    
    
}
