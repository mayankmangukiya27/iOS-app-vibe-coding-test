import Foundation

class StorageService {
    private let fileManager = FileManager.default
    private let documentsPath: URL
    
    init() {
        do {
            documentsPath = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            fatalError("Failed to initialize storage service: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Storage
    func saveImage(_ image: Data, withID id: UUID) throws -> URL {
        let imageURL = documentsPath.appendingPathComponent("\(id.uuidString).jpg")
        do {
            try image.write(to: imageURL)
            return imageURL
        } catch {
            if (error as NSError).domain == NSCocoaErrorDomain && (error as NSError).code == 4097 {
                throw FoodAIError.fileProviderError
            }
            throw FoodAIError.fileSystemError(error.localizedDescription)
        }
    }
    
    func deleteImage(at url: URL) throws {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } else {
                throw FoodAIError.fileNotFound
            }
        } catch {
            if (error as NSError).domain == NSCocoaErrorDomain && (error as NSError).code == 4097 {
                throw FoodAIError.fileProviderError
            }
            throw FoodAIError.fileSystemError(error.localizedDescription)
        }
    }
    
    // MARK: - Food Analysis Storage
    func saveFoodAnalysis(_ analysis: FoodAnalysis) throws {
        let analysisURL = documentsPath.appendingPathComponent("\(analysis.id.uuidString).json")
        do {
            let data = try JSONEncoder().encode(analysis)
            try data.write(to: analysisURL)
        } catch {
            throw FoodAIError.saveFailed
        }
    }
    
    func loadFoodAnalysis(withID id: UUID) throws -> FoodAnalysis {
        let analysisURL = documentsPath.appendingPathComponent("\(id.uuidString).json")
        do {
            let data = try Data(contentsOf: analysisURL)
            return try JSONDecoder().decode(FoodAnalysis.self, from: data)
        } catch {
            throw FoodAIError.fileNotFound
        }
    }
    
    func deleteFoodAnalysis(withID id: UUID) throws {
        let analysisURL = documentsPath.appendingPathComponent("\(id.uuidString).json")
        if fileManager.fileExists(atPath: analysisURL.path) {
            try fileManager.removeItem(at: analysisURL)
        }
    }
    
    // MARK: - Daily Logs Storage
    func saveDailyLog(_ log: DailyLog) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: log.date)
        
        let logURL = documentsPath.appendingPathComponent("log_\(dateString).json")
        do {
            let data = try JSONEncoder().encode(log)
            try data.write(to: logURL)
        } catch {
            throw FoodAIError.saveFailed
        }
    }
    
    func loadDailyLog(for date: Date) throws -> DailyLog {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let logURL = documentsPath.appendingPathComponent("log_\(dateString).json")
        do {
            let data = try Data(contentsOf: logURL)
            return try JSONDecoder().decode(DailyLog.self, from: data)
        } catch {
            throw FoodAIError.fileNotFound
        }
    }
    
    func getAllDailyLogs() throws -> [DailyLog] {
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: documentsPath,
                                                             includingPropertiesForKeys: nil,
                                                             options: .skipsHiddenFiles)
            
            return try logFiles
                .filter { $0.lastPathComponent.starts(with: "log_") }
                .map { try loadDailyLog(from: $0) }
                .sorted { $0.date > $1.date }
        } catch {
            throw FoodAIError.fileSystemError(error.localizedDescription)
        }
    }
    
    private func loadDailyLog(from url: URL) throws -> DailyLog {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(DailyLog.self, from: data)
        } catch {
            throw FoodAIError.fileNotFound
        }
    }
}

// MARK: - Date Extension
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
} 