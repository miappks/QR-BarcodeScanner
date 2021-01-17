//
//  ViewController.swift
//  QR-BarcodeScanner
//
//  Created by Marcin Kessler on 17.01.21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func openScanner(_ sender: UIButton) {
        
        let scanner = QRBarcodeScanner(delegate:self, feedbackType: .haptic ,autoDismissWhenFoundCode: false)
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
}

extension ViewController:QRBarcodeScannerDelegate {
    func foundContent(code: String, scanner:QRBarcodeScanner, tag: Int, stringTag: String) {
        scanner.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Code found",
                                      message: code,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func scannerDidDisappear() {
        print("disappear")
    }
}

