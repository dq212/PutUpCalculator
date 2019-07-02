//
//  SettingViewController.swift
//  MotoPreserve
//
//  Created by DQ on 10/6/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import MessageUI

class ContactViewController: UIViewController, MFMailComposeViewControllerDelegate, UIScrollViewDelegate {
    
    var backBarButton:UIBarButtonItem?
    
    let contactView:UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return view
    }()
    
    let contactText:UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir-Medium", size: 16)
        tv.textAlignment = .left
        tv.textColor = UIColor.black
        tv.isEditable = false
        tv.isSelectable = false
        tv.backgroundColor = UIColor(white: 0, alpha: 0.0)
        tv.text = "See and error?\n\nHave a feature request?\n\nNeed specific STOCK DATA? \n\nSend us an email to help make the MotoPreserve App the best moto-specific productivity tool.\n\nThanks so much for using our app and letting us help you stay tuned."
        return tv
    }()
    
    let contactEmailButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("E-mail Us", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        return button
    }()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isUserInteractionEnabled = true
        scrollView.delegate = self
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        
          adjustUITextViewHeight(arg: contactText)
        
        contactEmailButton.addTarget(self, action: #selector(emailButtonHandler), for: .touchUpInside)
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contactView)
        contactView.addSubview(contactText)
        contactView.addSubview(contactEmailButton)
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        contactView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height)
        
         contactText.anchor(top: contactView.topAnchor, left: contactView.leftAnchor, bottom:nil , right: contactView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height:0)
        
        
        let fixedWidth = contactText.frame.size.width
        let newSize = contactText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        contactText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        let contentSize = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 100)
        contactView.frame.size = contentSize
   
        contactEmailButton.anchor(top: contactText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop:20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        contactEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }

    
    @objc func cancelThisView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func emailButtonHandler() {
                
        if !MFMailComposeViewController.canSendMail() {
//            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["info@motopreserve.com"])
        composeVC.setSubject("MotoPreserve Customer Feedback")
        //composeVC.setMessageBody("Hello from California!", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}
