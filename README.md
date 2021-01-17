# QR-BarcodeScanner
Scanner to read common types of QR-Codes and Barcodes

## Screenshots

Scanner Lightmode            |  No Authorization Light             |  Scanner Darkmode |  No Authorization Dark
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![ScannerLight](https://github.com/miappks/QR-BarcodeScanner/blob/main/Screenshots/ScannerLight.PNG)  |  ![SettingsLight](https://github.com/miappks/QR-BarcodeScanner/blob/main/Screenshots/SettingsLight.PNG) | ![ScannerDark](https://github.com/miappks/QR-BarcodeScanner/blob/main/Screenshots/ScannerDark.PNG) | ![SettingsDark](https://github.com/miappks/QR-BarcodeScanner/blob/main/Screenshots/SettingsDark.PNG)

## Supported types

QR-Code, Aztec-Code, DataMatrix-Code, PDF417, Interleaved 2 of 5

EAN-8, EAN-13, Code39, Code39Mod43, Code93, Code128, ITF14, UPCE

## Installation

Simply add **QRBarcodeScanner.swift** to your Project.

Add `<key>NSCameraUsageDescription</key>` to your Info.plist

## Requirements

| Target            | Version |
|-------------------|---------|
| iOS               |  => 13.0 |
| Swift             |  => 5.2 |

## How to use

```swift
let scanner = QRBarcodeScanner(delegate:self, feedbackType: .haptic, autoDismissWhenFoundCode: false)

//OR

let scanner = QRBarcodeScanner()
scanner.delegate = self
```

#### QRBarcodeScannerDelegate

```swift
func foundContent(code: String, scanner:QRBarcodeScanner, tag: Int, stringTag: String)
func scannerDidDisappear()
```

License
=======

QR-BarcodeScanner is available under the MIT license. [See the LICENSE file for more info.](https://github.com/miappks/QR-BarcodeScanner/blob/main/LICENSE)
