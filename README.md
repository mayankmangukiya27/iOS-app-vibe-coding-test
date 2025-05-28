# FoodAI

FoodAI is an iOS application that analyzes food photos to provide calorie and nutrient information using OpenAI's Vision API.

Note: 

Added a food calorie measurement feature for enhanced health tracking

This feature requires access to premium AI services and is available in the paid version

Improved overall app performance and stability

## Features

- 📸 Take photos of food or select from gallery
- 🔍 AI-powered food recognition and analysis
- 📊 Detailed nutritional information
- 📅 Calendar-based food logging
- ✏️ Editable analysis results
- 📱 Modern SwiftUI interface

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+
- OpenAI API Key
- Physical iOS device or Simulator

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/FoodAI.git
cd FoodAI
```

2. Install dependencies (if using CocoaPods):
```bash
pod install
```

3. Open `FoodAI.xcodeproj` in Xcode

4. Create a new file named `Config.xcconfig` in the project root and add your OpenAI API key:
```
OPENAI_API_KEY = your_api_key_here
// "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"
        
```

5. Build and run the project (⌘+R)

## Configuration

### OpenAI API Setup

1. Get an API key from [OpenAI](https://platform.openai.com)
2. Add the key to `Config.xcconfig`
3. Ensure the key is properly loaded in the app configuration

### Camera Permissions

Add the following keys to your Info.plist:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses SwiftUI for the user interface.

### Key Components

- `FoodAnalysisView`: Main camera and analysis interface
- `HistoryView`: Calendar-based log viewer
- `FoodAnalysisViewModel`: Handles business logic and API calls
- `CoreDataManager`: Manages local data persistence
- `OpenAIService`: Handles API communication

## Building

1. Open `FoodAI.xcodeproj`
2. Select your target device/simulator
3. Build the project (⌘+B)
4. Run the app (⌘+R)

## Testing

Run the tests using ⌘+U in Xcode. The test suite includes:
- Unit tests for view models
- Integration tests for API services
- UI tests for critical user flows

## Troubleshooting

Common issues and solutions:

1. Camera not working in simulator
   - Use a physical device or use the photo library instead

2. API key not working
   - Verify the key in Config.xcconfig
   - Check API quota and billing status
   - Ensure proper network connectivity

3. Build errors
   - Clean build folder (⇧+⌘+K)
   - Clean build cache (⌥+⌘+⇧+K)
   - Re-install dependencies if using CocoaPods

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
