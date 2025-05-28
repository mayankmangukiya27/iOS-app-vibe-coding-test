import Foundation

enum FoodAIError: LocalizedError {
    case imageProcessingFailed
    case apiRequestFailed(String)
    case invalidResponse
    case quotaExceeded
    case cameraUnavailable
    case saveFailed
    case fileProviderError
    case fileNotFound
    case fileSystemError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .apiRequestFailed(let message):
            return "API request failed: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .quotaExceeded:
            return "OpenAI API quota exceeded. Please check your billing details at platform.openai.com"
        case .cameraUnavailable:
            return "Camera is not available"
        case .saveFailed:
            return "Failed to save data"
        case .fileProviderError:
            return "Unable to access file system. Please check app permissions."
        case .fileNotFound:
            return "File not found"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .unauthorized:
            return "Unauthorized access. Please check your API key."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .imageProcessingFailed:
            return "The image could not be processed or is in an unsupported format."
        case .apiRequestFailed(let message):
            return message
        case .invalidResponse:
            return "The server response was not in the expected format."
        case .quotaExceeded:
            return "Your OpenAI API quota has been exceeded."
        case .cameraUnavailable:
            return "The device camera is not available or permission was denied."
        case .saveFailed:
            return "Could not save data to device storage."
        case .fileProviderError:
            return "File system access was denied."
        case .fileNotFound:
            return "The requested file does not exist."
        case .fileSystemError(let message):
            return message
        case .unauthorized:
            return "Invalid or expired API key."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .imageProcessingFailed:
            return "Try taking a new photo with better lighting."
        case .apiRequestFailed:
            return "Please try again later."
        case .invalidResponse:
            return "Please try again or check for app updates."
        case .quotaExceeded:
            return "Visit platform.openai.com to manage your API quota."
        case .cameraUnavailable:
            return "Check camera permissions in Settings."
        case .saveFailed:
            return "Check your device storage and try again."
        case .fileProviderError:
            return "Check app permissions in Settings."
        case .fileNotFound:
            return "Try refreshing or recreating the data."
        case .fileSystemError:
            return "Check device storage and permissions."
        case .unauthorized:
            return "Update your API key in the app settings."
        }
    }
} 