import Foundation

// MARK: - Food Analysis Models
struct FoodAnalysis: Identifiable, Codable {
    let id: UUID
    var timestamp: Date
    var imageUrl: URL
    var foodName: String
    var calories: Double
    var nutrients: Nutrients
    var ingredients: [String]
    
    init(id: UUID = UUID(), timestamp: Date = Date(), imageUrl: URL, foodName: String, calories: Double, nutrients: Nutrients, ingredients: [String]) {
        self.id = id
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.foodName = foodName
        self.calories = calories
        self.nutrients = nutrients
        self.ingredients = ingredients
    }
}

struct Nutrients: Codable {
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    
    var totalCalories: Double {
        // Calories calculation based on macronutrients
        return (protein * 4) + (carbs * 4) + (fat * 9)
    }
}

// MARK: - API Response Models
struct OpenAIResponse: Codable {
    let foodItem: String
    let calories: Double
    let nutrients: Nutrients
    let ingredients: [String]
    
    enum CodingKeys: String, CodingKey {
        case foodItem = "food_item"
        case calories
        case nutrients
        case ingredients
    }
}

// MARK: - Daily Log Models
struct DailyLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var entries: [FoodAnalysis]
    
    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    init(id: UUID = UUID(), date: Date, entries: [FoodAnalysis] = []) {
        self.id = id
        self.date = date
        self.entries = entries
    }
} 