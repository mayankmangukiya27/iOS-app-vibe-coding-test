import AVFoundation
import UIKit

class CameraService: NSObject {
    static let shared = CameraService()
    
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    private var isConfigured = false
    private var isRunning = false
    
    private var completionHandler: ((Result<UIImage, Error>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    private func setupCaptureSession() throws {
        guard !isConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { 
            captureSession.commitConfiguration()
            isConfigured = true
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: currentPosition) else {
            throw FoodAIError.cameraUnavailable
        }
        
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        guard captureSession.canAddInput(videoInput) else {
            throw FoodAIError.cameraUnavailable
        }
        
        captureSession.addInput(videoInput)
        self.videoDeviceInput = videoInput
        
        // Add photo output
        guard captureSession.canAddOutput(photoOutput) else {
            throw FoodAIError.cameraUnavailable
        }
        
        captureSession.addOutput(photoOutput)
        captureSession.sessionPreset = .photo
    }
    
    private func startCaptureSession() {
        guard !isRunning else { return }
        
        // Start running on a background thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            self?.isRunning = true
        }
    }
    
    func configure() async throws {
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            throw FoodAIError.unauthorized
        }
        
        try setupCaptureSession()
        startCaptureSession()
        
        // Wait for the session to start
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: FoodAIError.cameraUnavailable)
                    return
                }
                
                // Wait for up to 2 seconds for the session to start
                let start = Date()
                while !self.captureSession.isRunning && Date().timeIntervalSince(start) < 2.0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
                
                if self.captureSession.isRunning {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: FoodAIError.cameraUnavailable)
                }
            }
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard isConfigured && isRunning && captureSession.isRunning else {
            completion(.failure(FoodAIError.cameraUnavailable))
            return
        }
        
        self.completionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func flipCamera() async throws {
        // Stop current session
        captureSession.stopRunning()
        isRunning = false
        
        // Remove current input
        if let currentInput = videoDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        // Switch position
        currentPosition = currentPosition == .back ? .front : .back
        
        // Reset configuration flag
        isConfigured = false
        
        // Reconfigure session
        try setupCaptureSession()
        startCaptureSession()
        
        // Wait for the session to restart
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: FoodAIError.cameraUnavailable)
                    return
                }
                
                // Wait for up to 2 seconds for the session to start
                let start = Date()
                while !self.captureSession.isRunning && Date().timeIntervalSince(start) < 2.0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
                
                if self.captureSession.isRunning {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: FoodAIError.cameraUnavailable)
                }
            }
        }
    }
    
    func stop() {
        captureSession.stopRunning()
        isRunning = false
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        
        if let error = error {
            completionHandler?(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completionHandler?(.failure(FoodAIError.imageProcessingFailed))
            return
        }
        
        completionHandler?(.success(image))
    }
} 