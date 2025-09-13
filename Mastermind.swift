import Foundation
import FoundationNetworking

// Model definitions for API responses
struct CreateGameResponse: Codable {
    let game_id: String
}

struct GuessRequest: Codable {
    let game_id: String
    let guess: String
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

struct ErrorResponse: Codable {
    let error: String
}

// Helper function to create a new game
func createNewGame() async throws -> String {
    let url = URL(string: "https://mastermind.darkube.app/game")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, 
                     userInfo: [NSLocalizedDescriptionKey: "Failed to create game"])
    }
    
    let decoded = try JSONDecoder().decode(CreateGameResponse.self, from: data)
    return decoded.game_id
}

// Helper function to submit a guess
func makeGuess(gameID: String, guess: String) async throws -> (black: Int, white: Int) {
    let url = URL(string: "https://mastermind.darkube.app/guess")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody = GuessRequest(game_id: gameID, guess: guess)
    request.httpBody = try JSONEncoder().encode(requestBody)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "HTTPError", code: 500, 
                     userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
    
    if (200...299).contains(httpResponse.statusCode) {
        let decoded = try JSONDecoder().decode(GuessResponse.self, from: data)
        return (decoded.black, decoded.white)
    } else if httpResponse.statusCode == 400 {
        let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
        throw NSError(domain: "APIError", code: 400, 
                     userInfo: [NSLocalizedDescriptionKey: error.error])
    } else if httpResponse.statusCode == 404 {
        let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
        throw NSError(domain: "APIError", code: 404, 
                     userInfo: [NSLocalizedDescriptionKey: error.error])
    } else {
        throw NSError(domain: "HTTPError", code: httpResponse.statusCode, 
                     userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])
    }
}

// Input validation function
func validateInput(_ input: String) -> Bool {
    if input.count != 4 { return false }
    for char in input {
        guard let digit = Int(String(char)), digit >= 1, digit <= 6 else {
            return false
        }
    }
    return true
}

// Main application
@main
struct MastermindApp {
    static func main() async {
        print("Mastermind Game - Terminal Edition")
        print("Type 'exit' at any time to quit")
        print("-------------------------------")
        
        // Create new game
        var gameID: String
        do {
            gameID = try await createNewGame()
            print("\nNew game created! Game ID: \(gameID)")
            print("Guess a 4-digit code (digits 1-6)")
        } catch {
            print("❌ Failed to create game: \(error.localizedDescription)")
            return
        }
        
        // Main game loop
        while true {
            print("\nEnter your guess (or 'exit'): ", terminator: "")
            guard let input = readLine() else { break }
            
            if input.lowercased() == "exit" {
                print("\nExiting game...")
                break
            }
            
            // Validate input
            if !validateInput(input) {
                print("❌ Error: Invalid input. Please enter 4 digits between 1 and 6.")
                continue
            }
            
            // Submit guess to API
            do {
                let (black, white) = try await makeGuess(gameID: gameID, guess: input)
                let feedback = String(repeating: "B", count: black) + String(repeating: "W", count: white)
                print("✅ Feedback: \(feedback)")
                
                if black == 4 {
                    print("\n🎉 Congratulations! You guessed the code correctly!")
                    break
                }
            } catch {
                // Handle API errors specifically
                if let nsError = error as? NSError, nsError.domain == "APIError" {
                    print("❌ API Error: \(nsError.localizedDescription)")
                } else {
                    print("❌ Network Error: \(error.localizedDescription)")
                }
            }
        }
    }
}