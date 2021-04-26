//
//  ViewController.swift
//  VisionScanning
//
//  Created by Sergey Lukaschuk on 26.04.2021.
//

import UIKit
import Vision
import AVFoundation
import SafariServices

class ViewController: UIViewController {
    
    // MARK: - Private Variables
    var captureSession = AVCaptureSession()
    
    lazy var textRequest = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Received invalid observations")
        }
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                print("No candidate")
                continue
            }
            print("Found this candidate: \(bestCandidate.string)")
        }
    }
    
    
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        setupCameraLiveView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: Stop Session
    }
}


extension ViewController {
    // MARK: - Camera
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
                if !granted {
                    showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }
    
    private func setupCameraLiveView() {
        captureSession.sessionPreset = .hd1280x720
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard
            let device = videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput)
        else {
            showAlert(
                withTitle: "Cannot Find Camera",
                message: "There seems to be a problem with the camera on your device.")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        let captureOutput = AVCaptureVideoDataOutput()
        
        captureOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        captureSession.addOutput(captureOutput)
        configurePreviewLayer()
        captureSession.startRunning()
    }
    
    
    
    // MARK: - Vision
    func processClassification(_ request: VNRequest) {
        guard let text = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                view.layer.sublayers?.removeSubrange(1...)
                
                // 2
                for text in text {
                    guard
                        // TODO: Check for QR Code symbology and confidence score
                        let potentialQRCode = text as? VNBarcodeObservation
                    else { return }
                    
                    // 3
                    showAlert(
                        withTitle: potentialQRCode.symbology.rawValue,
                        // TODO: Check the confidence score
                        message: potentialQRCode.payloadStringValue ?? "" )
                }
            }
        }
    }
    
    
    
    // MARK: - Handler
    func observationHandler(payload: String?) {
        // TODO: Open it in Safari
    }
}



// MARK: - AVCaptureDelegation
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right)
        
        do {
            try imageRequestHandler.perform([textRequest])
        } catch {
            print(error)
        }
    }
}



// MARK: - Helper
extension ViewController {
    private func configurePreviewLayer() {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = view.frame
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    private func showPermissionsAlert() {
        showAlert(
            withTitle: "Camera Permissions",
            message: "Please open Settings and grant permission for this app to use your camera.")
    }
}

// MARK: - SafariViewControllerDelegate
extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        captureSession.startRunning()
    }
}
