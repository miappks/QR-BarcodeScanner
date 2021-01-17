# QR-BarcodeScanner
Scanner for common types of QR-Codes and Barcodes

## Supported types

QR-Code, Aztec-Code, DataMatrix-Code, PDF417, Interleaved 2 of 5

EAN-8, EAN-13, Code39, Code39Mod43, Code93, Code128, ITF14, UPCE

## Installation

Simply add **QRBarcodeScanner.swift** to your Project.

Add NSCameraUsageDescription to your Info.plist

## Requirements

| Target            | Version |
|-------------------|---------|
| iOS               |  => 13.0 |
| Swift             |  => 5.2 |

## How to use

```swift
let scanner = QRBarcodeScanner(delegate:self)

//OR

let scanner = QRBarcodeScanner()
scanner.delegate = self
```

#### QRBarcodeScannerDelegate

```swift
func foundContent(code: String, tag: Int, stringTag: String)
func scannerDidDisappear()
```
