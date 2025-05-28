import SwiftUI
import AVFoundation
import Combine

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    // MARK: - Services
    private let openAIService = OpenAIService()
    private let storageService = StorageService()
    private let cameraService = CameraService.shared
    
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var foodAnalysis: FoodAnalysis?
    @Published var isAnalyzing = false
    @Published var error: FoodAIError?
    @Published var showError = false
    
    // MARK: - Camera Methods
    func setupCamera() async {
        do {
            try await cameraService.configure()
        } catch {
            self.error = error as? FoodAIError ?? .cameraUnavailable
            self.showError = true
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return cameraService.getPreviewLayer()
    }
    
    func flipCamera() async throws {
        try await cameraService.flipCamera()
    }
    
    func capturePhoto() {
        cameraService.capturePhoto { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                Task { @MainActor in
                    self.capturedImage = image
                }
            case .failure(let error):
                Task { @MainActor in
                    self.error = error as? FoodAIError ?? .imageProcessingFailed
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Analysis Methods
    func analyzeFood() async {
        guard let image = capturedImage else {
            error = .imageProcessingFailed
            showError = true
            return
        }
        
        isAnalyzing = true
        error = nil
        showError = false
        foodAnalysis = nil
        
        do {
            // Compress image if needed
            guard let compressedImage = image.compressed() else {
                throw FoodAIError.imageProcessingFailed
            }
            
            // Get analysis from OpenAI
            let response = try await openAIService.analyzeFood(image: compressedImage)
            
            // Save image
            let imageData = compressedImage.jpegData(compressionQuality: 0.8)!
            let id = UUID()
            let imageUrl = try storageService.saveImage(imageData, withID: id)
            
            // Create and save analysis
            let analysis = FoodAnalysis(
                id: id,
                imageUrl: imageUrl,
                foodName: response.foodItem,
                calories: response.calories,
                nutrients: response.nutrients,
                ingredients: response.ingredients
            )
            
            try storageService.saveFoodAnalysis(analysis)
            
            // Update daily log
            let date = Date()
            var dailyLog: DailyLog
            do {
                dailyLog = try storageService.loadDailyLog(for: date)
            } catch {
                dailyLog = DailyLog(date: date)
            }
            
            dailyLog.entries.append(analysis)
            try storageService.saveDailyLog(dailyLog)
            
            // Update UI
            await MainActor.run {
                self.foodAnalysis = analysis
                self.isAnalyzing = false
                self.error = nil
                self.showError = false
            }
            
        } catch {
            await MainActor.run {
                self.foodAnalysis = nil
                self.error = error as? FoodAIError ?? .apiRequestFailed("Unknown error")
                self.showError = true
                self.isAnalyzing = false
            }
        }
    }
    
    // MARK: - Update Methods
    func updateAnalysis(_ analysis: FoodAnalysis) async {
        do {
            try storageService.saveFoodAnalysis(analysis)
            self.foodAnalysis = analysis
            
            // Update daily log
            let date = analysis.timestamp
            var dailyLog = try storageService.loadDailyLog(for: date)
            
            if let index = dailyLog.entries.firstIndex(where: { $0.id == analysis.id }) {
                dailyLog.entries[index] = analysis
                try storageService.saveDailyLog(dailyLog)
            }
            
        } catch {
            self.error = error as? FoodAIError ?? .saveFailed
            self.showError = true
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        cameraService.stop()
        capturedImage = nil
        foodAnalysis = nil
    }
}
