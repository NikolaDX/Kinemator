//
//  CameraService.swift
//  Kinemator
//
//  Created by Nikola Ristic on 17. 5. 2025..
//

import AVFoundation
import Photos
import UIKit

enum CameraError: Error {
    case addInputFailed
    case addOutputFailed
}

class CameraService: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    private let session = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    @Published var isRecording = false
    
    override init() {
        super.init()
    }

    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Input configuration
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Failed to add camera input")
            return
        }
        session.addInput(input)
        
        
        // Audio input configuration
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        } else {
            print("Failed to add audio input")
        }
        
        // Photo output configuration
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // Video output configuration
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        // Set landscape orientation
        if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeRight
        }
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeRight
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func startRecording(to url: URL) {
        if !videoOutput.isRecording {
            videoOutput.startRecording(to: url, recordingDelegate: self)
            isRecording = true
        }
    }
    
    func stopRecording() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
            isRecording = false
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspect
        }
        return previewLayer!
    }
    
    func saveVideoToPhotoLibrary(from url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("Photo library access denied.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                if let error = error {
                    print("Failed to save video: \(error.localizedDescription)")
                } else {
                    print("Video saved to photo library successfully!")
                }
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        saveVideoToPhotoLibrary(from: outputFileURL)
    }
}
