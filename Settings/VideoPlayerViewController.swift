//
//  VideoPlayerViewController.swift
//  MotoPreserve-App
//
//  Created by Daniel I Quintero on 11/25/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//

import UIKit
import Foundation

class VideoPlayerViewController: UIViewController, UIWebViewDelegate {
    
    var wv:UIWebView = UIWebView()
    var url:String?

    let dismissButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(wv)
        view.addSubview(dismissButton)
        wv.backgroundColor = .black
        view.backgroundColor = .black
        
        wv.delegate = self
        
       dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        wv.anchor(top: dismissButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.width * 0.5625)
        
       getVideo(videoCode: url!)
    }
    
    @objc func handleDismiss() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    func getVideo(videoCode:String) {
        let url:URL = URL(string: "\(videoCode)")!
        wv.loadRequest(URLRequest(url: url))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        var text=""
        switch UIDevice.current.orientation{
        case .portrait:
            text="Portrait"
        case .portraitUpsideDown:
            text="PortraitUpsideDown"
        case .landscapeLeft:
            text="LandscapeLeft"
        case .landscapeRight:
            text="LandscapeRight"
        default:
            text="Another"
        }
        NSLog("You have moved: \(text)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        //UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }
}
