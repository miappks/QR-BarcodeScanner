//
//  ViewController.swift
//  QR-Code Reader
//
//  Created by Marcin Kessler on 28.04.19.
//  Copyright © 2019 Marcin Kessler. All rights reserved.
//

import AVFoundation
import UIKit

class QRBarcodeScanner: UIViewController {
    
//    Add NSCameraUsageDescription to Info.plist
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let cameraAutorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    let torchButton = UIButton(type: .roundedRect)
    var settingsButton = UIButton() // for No Autorization
    
    var delegate:QRBarcodeScannerDelegate?
    
    var stringTag: String?
    var tag: Int?
    
    //MARK:-Einstellungen
    var feedbackType:FeedbackType = .haptic
    
    enum FeedbackType {
        case vibrate, haptic, none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch cameraAutorizationStatus {
        case .denied,.restricted:
            showNoAutorization()
            setupUI(autorized: false)
        default:
            setupAVCaptureSession()
            setupUI()
        }
        
    }
    
    init(tag:Int? = nil, stringTag:String? = nil, delegate:QRBarcodeScannerDelegate? = nil, feedbackType:FeedbackType = .haptic) {
        super.init(nibName: nil, bundle: nil)
        
        self.tag = tag
        self.stringTag = stringTag
        self.delegate = delegate
        self.feedbackType = feedbackType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        
        flashActive(toggle: false, toState: .off)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.scannerDidDisappear?()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        
    }
    
    @objc func dismissSelf() {
        flashActive(toggle: false, toState: .off)
    }
    
    @objc func flash() {
        flashActive()
    }
 
    func flashActive(toggle:Bool = true, toState:AVCaptureDevice.TorchMode = .on) {
        if let currentDevice = AVCaptureDevice.default(for: AVMediaType.video), currentDevice.hasTorch {
            do {
                try currentDevice.lockForConfiguration()
                let torchOn = !currentDevice.isTorchActive
                if !toggle {
                    if toState == .on {
                        try currentDevice.setTorchModeOn(level:0.3)
                    }
                    currentDevice.torchMode = toState
                    toState == .on ? torchButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal) : torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                }else {
                    try currentDevice.setTorchModeOn(level:0.3)
                    currentDevice.torchMode = torchOn ? .on : .off
                    torchOn ? torchButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal) : torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                }
                
                currentDevice.unlockForConfiguration()
            } catch {
                print("Error set TorchMode")
            }
        }
    }
    
    //MARK:- Setup UI
    
    private func setupAVCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            deviceHasNoCamera()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8,.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.ean13,.pdf417,.dataMatrix,.interleaved2of5,.itf14,.upce,.face]
        } else {
            deviceHasNoCamera()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.layer.bounds
        captureSession.startRunning()
    }
    
    private func setupUI(autorized:Bool = true) {
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        
        view.backgroundColor = .secondarySystemGroupedBackground
        
        //MARK:- Close Button
        let closeButton = UIButton(type: .roundedRect)
        closeButton.frame = CGRect(x: 10, y: 10, width: 70, height: 50)
        closeButton.layer.cornerRadius = 20
        closeButton.layer.masksToBounds = true
        closeButton.backgroundColor = UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? .quaternaryLabel : (autorized ? .secondaryLabel : .tertiaryLabel)
        }
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        closeButton.addTarget(self, action:#selector(dismissSelf) , for: .touchUpInside)
        view.addSubview(closeButton)
        
        //MARK:- Torch Button
        torchButton.frame = CGRect(x: 90, y: 10, width: 70, height: 50)
        torchButton.layer.cornerRadius = 20
        torchButton.layer.masksToBounds = true
        torchButton.backgroundColor = UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? .quaternaryLabel : .secondaryLabel
        }
        torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        torchButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        torchButton.addTarget(self, action: #selector(flash) , for: .touchUpInside)
        if autorized {
        view.addSubview(torchButton)
        }
    }
    
    private func showNoAutorization() {
        let messageLabel = UILabel()
        messageLabel.text = NSLocalizedString("""
            Keine Kameraberechtigung
            Erlauben Sie den Zugriff auf die Kamera
            """, comment: "No autorization for Camera")
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel
        view.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            messageLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40)
        ])
        
        settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        settingsButton.setTitle("  \(NSLocalizedString("Einstellungen", comment: "Settings")) ", for: .normal)
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        settingsButton.setTitleColor(.secondaryLabel, for: .normal)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            settingsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
        ])
    }
    
    private func deviceHasNoCamera() {

        captureSession = nil
        
        let messageLabel = UILabel()
        messageLabel.text = NSLocalizedString("""
            Scannen wird nicht unterstützt

            Ihr Gerät unterstützt das Scannen eines QR-Codes nicht. Bitte verwenden Sie ein Gerät mit einer Kamera.
            """, comment: "Device can't scann Code")
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel
        view.addSubview(messageLabel)
        messageLabel.center = view.center
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            messageLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40)
        ])

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            settingsButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
    
}

extension QRBarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { print("error occured on scanning"); return }
            captureSession.stopRunning()
            
            if feedbackType == .vibrate {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }else  if feedbackType == .haptic {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            }
            
            // Found Code
            self.dismiss(animated: true) {
                self.delegate?.foundContent(code: stringValue, tag: self.tag ?? 0, stringTag: self.stringTag ?? "")
            }
        }
    }
}

@objc protocol QRBarcodeScannerDelegate {
    func foundContent(code:String, tag:Int, stringTag:String)
    @objc optional func scannerDidDisappear()
}
