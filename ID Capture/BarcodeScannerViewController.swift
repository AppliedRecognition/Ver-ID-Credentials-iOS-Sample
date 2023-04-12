//
//  BarcodeScannerViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/04/2023.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAdaptivePresentationControllerDelegate {
    
    let cameraDevice: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var titleBackgroundView: UIView!
    @IBOutlet var cameraView: UIView!
    weak var delegate: BarcodeScannerViewControllerDelegate?
    
    var avCaptureVideoOrientation: AVCaptureVideoOrientation {
        if #available(iOS 13, *) {
            if let orientation = self.view.window?.windowScene?.interfaceOrientation {
                switch orientation {
                case .portraitUpsideDown:
                    return .portraitUpsideDown
                case .landscapeLeft:
                    return .landscapeLeft
                case .landscapeRight:
                    return .landscapeRight
                default:
                    return .portrait
                }
            } else {
                return .portrait
            }
        } else {
            switch UIApplication.shared.statusBarOrientation {
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            default:
                return .portrait
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self
        do {
            try self.setupCamera()
        } catch {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.delegate?.barcodeScannerViewController(self, didFailWithError: error)
                }
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        gradientLayer.frame = self.titleBackgroundView.bounds
        self.titleBackgroundView.layer.addSublayer(gradientLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: self.view, animation: nil) { context in
            guard !context.isCancelled else {
                return
            }
            self.previewLayer.frame = self.cameraView.bounds
            self.titleBackgroundView.layer.sublayers?.forEach({ $0.frame = self.titleBackgroundView.bounds })
            if let videoPreviewLayerConnection = self.previewLayer.connection, videoPreviewLayerConnection.isVideoOrientationSupported {
                videoPreviewLayerConnection.videoOrientation = self.avCaptureVideoOrientation
            }
        }
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true) {
            self.delegate?.barcodeScannerViewControllerDidCancelScan(self)
        }
    }
    
    private func setupCamera() throws {
        guard let device = self.cameraDevice else {
            throw BarcodeScannerError.failedToObtainCameraDevice
        }
        let input = try AVCaptureDeviceInput(device: device)
        guard self.captureSession.canAddInput(input) else {
            throw BarcodeScannerError.failedToAddCaptureInput
        }
        self.captureSession.addInput(input)
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.view.bounds
        self.cameraView.layer.addSublayer(self.previewLayer)
        let metadataOutput = AVCaptureMetadataOutput()
        guard self.captureSession.canAddOutput(metadataOutput) else {
            throw BarcodeScannerError.failedToAddCaptureOutput
        }
        self.captureSession.addOutput(metadataOutput)
        guard metadataOutput.availableMetadataObjectTypes.contains(.pdf417) else {
            NSLog("Available metadata object types: %@", metadataOutput.availableMetadataObjectTypes.map({ $0.rawValue }).joined(separator: ", "))
            throw BarcodeScannerError.barcodeScanUnavailable
        }
        metadataOutput.metadataObjectTypes = [.pdf417]
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global())
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let barcode = metadataObjects.compactMap({ $0 as? AVMetadataMachineReadableCodeObject }).first?.stringValue else {
            return
        }
        if let delegate = self.delegate {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    delegate.barcodeScannerViewController(self, didScanBarcode: barcode)
                }
            }
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.delegate?.barcodeScannerViewControllerDidCancelScan(self)
    }
}

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    
    func barcodeScannerViewController(_ barcodeScannerViewController: BarcodeScannerViewController, didScanBarcode barcode: String)
    
    func barcodeScannerViewController(_ barcodeScannerViewController: BarcodeScannerViewController, didFailWithError error: Error)
    
    func barcodeScannerViewControllerDidCancelScan(_ barcodeScannerViewController: BarcodeScannerViewController)
}

enum BarcodeScannerError: LocalizedError {
    case failedToObtainCameraDevice, failedToAddCaptureInput, failedToAddCaptureOutput, barcodeScanUnavailable
    
    var errorDescription: String? {
        switch self {
        case .failedToObtainCameraDevice:
            return "Failed to obtain camera device"
        case .failedToAddCaptureInput:
            return "Failed to add capture input"
        case .failedToAddCaptureOutput:
            return "Failed to add capture output"
        case .barcodeScanUnavailable:
            return "Barcode scanning is not available"
        @unknown default:
            return "Something went wrong"
        }
    }
}
