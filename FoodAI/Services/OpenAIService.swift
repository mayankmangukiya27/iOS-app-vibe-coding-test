import Foundation
import UIKit

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let timeoutInterval: TimeInterval = 30 // 30 seconds timeout
    private let model = "gpt-4-vision-preview"  // Updated to correct model name
    
    init() {
        // Get API key from configuration
//        guard let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
//            fatalError("OpenAI API key not found in configuration")
//        }
        let apiKey = ""
        
        // Validate API key format
        guard apiKey.hasPrefix("sk-") && apiKey.count > 20 else {
            fatalError("Invalid OpenAI API key format. Key should start with 'sk-' and be longer than 20 characters")
        }
        
        self.apiKey = apiKey
    }
    
    func analyzeFood(image: UIImage) async throws -> OpenAIResponse {
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let base64String = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw FoodAIError.imageProcessingFailed
        }
        
        // Create URL request
        guard let url = URL(string: baseURL) else {
            throw FoodAIError.apiRequestFailed("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeoutInterval
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this food image and provide nutritional information in the following JSON format exactly: {\"food_item\": \"name\", \"calories\": number, \"nutrients\": {\"protein\": number, \"carbs\": number, \"fat\": number, \"fiber\": number}, \"ingredients\": [\"ingredient1\", \"ingredient2\"]}"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64String)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        do {
            // Make API request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FoodAIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to get error message from response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any] {
                    let message = error["message"] as? String ?? "Unknown error"
                    let type = error["type"] as? String ?? ""
                    let code = error["code"] as? String ?? ""
                    
                    // Check for specific error types
                    if code == "insufficient_quota" {
                        throw FoodAIError.quotaExceeded
                    }
                    
                    if code == "model_not_found" {
                        throw FoodAIError.apiRequestFailed("The OpenAI Vision model is currently unavailable. Please try again later.")
                    }
                    
                    if httpResponse.statusCode == 401 {
                        throw FoodAIError.unauthorized
                    }
                    
                    let fullError = "\(type)\(code.isEmpty ? "" : " (\(code))"): \(message)"
                    print("OpenAI Error: \(fullError)")
                    throw FoodAIError.apiRequestFailed(fullError)
                }
                
                // Handle unauthorized access without error details
                if httpResponse.statusCode == 401 {
                    throw FoodAIError.unauthorized
                }
                
                throw FoodAIError.apiRequestFailed("Status code: \(httpResponse.statusCode)")
            }
            
            // Parse response
            struct GPTResponse: Codable {
                let choices: [Choice]
                
                struct Choice: Codable {
                    let message: Message
                    
                    struct Message: Codable {
                        let content: String
                    }
                }
            }
            
            let gptResponse = try JSONDecoder().decode(GPTResponse.self, from: data)
            guard let content = gptResponse.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8) else {
                throw FoodAIError.invalidResponse
            }
            
            do {
                return try JSONDecoder().decode(OpenAIResponse.self, from: jsonData)
            } catch {
                print("Failed to decode OpenAIResponse: \(error)")
                throw FoodAIError.invalidResponse
            }
            
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    throw FoodAIError.apiRequestFailed("Request timed out")
                case .notConnectedToInternet:
                    throw FoodAIError.apiRequestFailed("No internet connection")
                default:
                    throw FoodAIError.apiRequestFailed(urlError.localizedDescription)
                }
            }
            
            if let apiError = error as? FoodAIError {
                throw apiError
            }
            
            throw FoodAIError.apiRequestFailed(error.localizedDescription)
        }
    }
}

// MARK: - Image Compression Extension
extension UIImage {
    func compressed() -> UIImage? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return UIImage(data: imageData)
    }
} 
