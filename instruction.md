# FoodAI - Food Analysis iOS App

## Product Requirements Document (PRD)

### Overview
FoodAI is an iOS application that allows users to analyze food through photos using OpenAI's Vision API. The app provides calorie and nutrient information for captured food items and maintains a history of food logs.

### Core Features

1. **Camera Integration**
   - Custom camera interface
   - Photo capture functionality
   - Image preview and retake option
   - Gallery photo selection option

2. **Food Analysis**
   - OpenAI Vision API integration
   - Real-time food recognition
   - Calorie estimation
   - Nutrient breakdown
   - Structured JSON response parsing

3. **Data Management**
   - Editable analysis results
   - Real-time calorie updates
   - Food log storage
   - Calendar-based history view

### Technical Specifications

#### Architecture
- MVVM (Model-View-ViewModel) architecture
- SwiftUI for UI components
- Combine framework for reactive programming

#### Data Models

```swift
struct FoodAnalysis {
    let id: UUID
    var timestamp: Date
    var imageUrl: URL
    var foodName: String
    var calories: Double
    var nutrients: Nutrients
    var ingredients: [String]
}

struct Nutrients {
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
}

struct DailyLog {
    let date: Date
    var entries: [FoodAnalysis]
    var totalCalories: Double
}
```

#### API Integration

OpenAI Vision API Endpoint:
```
POST https://api.openai.com/v1/chat/completions
```

Expected JSON Response Structure:
```json
{
    "food_item": "string",
    "calories": number,
    "nutrients": {
        "protein": number,
        "carbs": number,
        "fat": number,
        "fiber": number
    },
    "ingredients": ["string"]
}
```

### User Interface

1. **Main Tab View**
   - Camera/Analysis Tab
   - History Tab
   - Settings Tab

2. **Camera Screen**
   - Camera preview
   - Capture button
   - Gallery access button
   - Flash toggle

3. **Analysis Screen**
   - Food image display
   - Analyzed results
   - Editable fields
   - Save button

4. **History Screen**
   - Calendar view
   - Daily log entries
   - Total calories per day
   - Detailed entry view

### Data Storage
- CoreData for local storage
- FileManager for image storage
- UserDefaults for app settings

### Security
- Secure API key storage using Keychain
- Image compression before API transmission
- Data encryption for stored information

### Performance Requirements
- Camera initialization < 2 seconds
- API response handling < 5 seconds
- Image compression to max 1MB
- Smooth scrolling in history view (60 fps)

### Error Handling
- Network connectivity checks
- API error handling
- Camera permission handling
- Storage permission handling

### Future Enhancements
- Machine learning model caching
- Offline mode support
- Social sharing features
- Meal planning integration
- Nutritional goals tracking 