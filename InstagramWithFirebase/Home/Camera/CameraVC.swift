//
//  CameraVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 22/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // Stored properties
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleDismissButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupHUD()
   }
    
    fileprivate func setupHUD() {
        
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 40, height: 40)
    }
    
    @objc func handleCapturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        guard let photoSample = photoSampleBuffer, let previewPhotoSample = previewPhotoSampleBuffer, let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSample, previewPhotoSampleBuffer: previewPhotoSample) else {
            return
        }
        
        let previewImage = UIImage(data: imageData)
        displayImageView(image: previewImage)
    }
    
    fileprivate func displayImageView(image: UIImage?) {
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = image
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        
        
    }
    
    // Needs to be a global property
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaptureSession() {
        
        let captureSession = AVCaptureSession()
        
        // 1. Setup inputs
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        guard let capturedDevice = captureDevice else { print("Could not setup capture device."); return }
        do {
            
            let input = try AVCaptureDeviceInput(device: capturedDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Could not configure captureVideo device input: ", error); return
        }
        
        // 2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // must set the frame !!!
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
     }
}
