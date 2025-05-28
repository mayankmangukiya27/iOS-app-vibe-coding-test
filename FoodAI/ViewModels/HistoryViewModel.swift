import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    private let storageService = StorageService()
    
    @Published var dailyLogs: [DailyLog] = []
    @Published var selectedDate: Date = Date()
    @Published var error: FoodAIError?
    @Published var showError = false
    
    // MARK: - Loading Methods
    func loadAllLogs() async {
        do {
            dailyLogs = try storageService.getAllDailyLogs()
        } catch {
            self.error = error as? FoodAIError
            self.showError = true
        }
    }
    
    func loadLog(for date: Date) async {
        do {
            let log = try storageService.loadDailyLog(for: date)
            if let index = dailyLogs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                dailyLogs[index] = log
            } else {
                dailyLogs.append(log)
                dailyLogs.sort { $0.date > $1.date }
            }
        } catch {
            // If no log exists for this date, create a new one
            let newLog = DailyLog(date: date)
            dailyLogs.append(newLog)
            dailyLogs.sort { $0.date > $1.date }
        }
    }
    
    // MARK: - Delete Methods
    func deleteEntry(_ entry: FoodAnalysis, from date: Date) async {
        do {
            // Delete the analysis file
            try storageService.deleteFoodAnalysis(withID: entry.id)
            
            // Delete the image
            try storageService.deleteImage(at: entry.imageUrl)
            
            // Update the daily log
            var log = try storageService.loadDailyLog(for: date)
            log.entries.removeAll { $0.id == entry.id }
            try storageService.saveDailyLog(log)
            
            // Update the UI
            if let index = dailyLogs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                dailyLogs[index] = log
            }
        } catch {
            self.error = error as? FoodAIError ?? .saveFailed
            self.showError = true
        }
    }
    
    // MARK: - Helper Methods
    func totalCalories(for date: Date) -> Double {
        guard let log = dailyLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return 0
        }
        return log.totalCalories
    }
    
    func entries(for date: Date) -> [FoodAnalysis] {
        guard let log = dailyLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return []
        }
        return log.entries
    }
} 
