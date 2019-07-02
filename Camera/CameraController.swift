//
//  CameraController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/20/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import AVFoundation
//import DataCache

protocol CameraControllerDelegate: class {
    func cameraController(_ controller:CameraController, didFinishAddingThumbnail item: FB_ProjectItem)
}

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {

    var project:FB_ProjectItem?
    var projects:[FB_ProjectItem]?
    var bike:FB_Bike?
    var bikes:[FB_Bike]?
    //var imagesCache:DataCache?
    
    var selectedIndexPath:IndexPath?
    var projectIndexPath:IndexPath?
    
    weak var delegate: CameraControllerDelegate?
    
    let dismissButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "camera_shutter_button").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupHUD()
    }
    
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 75, height: 75)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 60, height: 60)
    }
    
    @objc func handleDismiss() {
        guard self.project != nil else {return}
        self.delegate?.cameraController(self, didFinishAddingThumbnail: project!)   
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
        //dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.__availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        let previewImage = UIImage(data: imageData!)
        
        
        
        let containerView = PreviewPhotoContainerView()
        containerView.project = self.project
        containerView.projects = self.projects
        containerView.bike = self.bike
        containerView.bikes = self.bikes
        //containerView.imagesCache = self.imagesCache
        containerView.projectIndexPath = self.projectIndexPath
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        containerView.previewImageView.image = previewImage
        //

//        let previewImageView = UIImageView(image:previewImage)
//        view.addSubview(previewImageView)
//        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//
//        print("finshed processing photo sample buffer...")
    }
    
 
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        //1. setup input
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
           
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
              captureSession.addInput(input)
            }
        } catch let err {
                print("Could not setup camera input", err)
        }
        
        //2. setup output
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        //3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    
}
