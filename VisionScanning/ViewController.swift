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

  // TODO: Make VNDetectBarcodesRequest variable

    
    
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
    // TODO: Checking permissions
  }

  private func setupCameraLiveView() {
    // TODO: Setup captureSession

    // TODO: Add input

    // TODO: Add output

    configurePreviewLayer()

    // TODO: Run session
  }

    
    
  // MARK: - Vision
  func processClassification(_ request: VNRequest) {
    // TODO: Main logic
  }

    
    
  // MARK: - Handler
  func observationHandler(payload: String?) {
    // TODO: Open it in Safari
  }
}



// MARK: - AVCaptureDelegation
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // TODO: Live Vision
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
