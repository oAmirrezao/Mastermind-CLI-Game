#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Dispatch

// MARK: - ANSI Colors (moved outside for global access)
struct ANSIColors {
    static let reset = "\u{001B}[0m"
    static let black = "\u{001B}[30m"
    static let red = "\u{001B}[31m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
    static let magenta = "\u{001B}[35m"
    static let cyan = "\u{001B}[36m"
    static let white = "\u{001B}[37m"
    static let backgroundCyan = "\u{001B}[46m"
    static let backgroundYellow = "\u{001B}[43m"
    static let bold = "\u{001B}[1m"
}

// MARK: - API Models
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

// MARK: - Error Handling
enum GameError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case noActiveGame
    case invalidGuess

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .serverError(let message): return "Server error: \(message)"
        case .noActiveGame: return "No active game. Please start a new game first."
        case .invalidGuess: return "Invalid guess. Please enter exactly 4 digits between 1 and 6."
        }
    }
}

// MARK: - Game Manager
class MastermindGame {
    private let baseURL = "https://mastermind.darkube.app"
    private var gameID: String?

    // Start a new game
    func startNewGame() async throws {
        guard let url = URL(string: "\(baseURL)/game") else { throw GameError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw GameError.invalidResponse }
        guard httpResponse.statusCode == 200 else {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw GameError.serverError(errorResponse.error)
        }
        let createGameResponse = try JSONDecoder().decode(CreateGameResponse.self, from: data)
        self.gameID = createGameResponse.game_id

        print("\(ANSIColors.green)🎮 New game started!\(ANSIColors.reset)")
        print("\(ANSIColors.cyan)Game ID: \(createGameResponse.game_id)\(ANSIColors.reset)")
    }

    // Make a guess
    func makeGuess(_ guess: String) async throws -> (black: Int, white: Int) {
        guard let gameID = gameID else { throw GameError.noActiveGame }
        guard isValidGuess(guess) else { throw GameError.invalidGuess }
        guard let url = URL(string: "\(baseURL)/guess") else { throw GameError.invalidURL }

        let guessRequest = GuessRequest(game_id: gameID, guess: guess)
        let requestData = try JSONEncoder().encode(guessRequest)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw GameError.invalidResponse }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 400 || httpResponse.statusCode == 404 {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw GameError.serverError(errorResponse.error)
            } else {
                throw GameError.serverError("Unknown server error")
            }
        }

        let guessResponse = try JSONDecoder().decode(GuessResponse.self, from: data)
        return (guessResponse.black, guessResponse.white)
    }

    // Delete the current game
    func deleteGame() async throws {
        guard let gameID = gameID else { throw GameError.noActiveGame }
        guard let url = URL(string: "\(baseURL)/game/\(gameID)") else { throw GameError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw GameError.invalidResponse }
        guard httpResponse.statusCode == 204 else { throw GameError.serverError("Failed to delete game") }

        self.gameID = nil
        print("\(ANSIColors.yellow)Game deleted successfully.\(ANSIColors.reset)")
    }

    // Validate guess format
    private func isValidGuess(_ guess: String) -> Bool {
        let pattern = "^[1-6]{4}$"
        return guess.range(of: pattern, options: .regularExpression) != nil
    }

    // Format guess with colors
    func formatGuess(_ guess: String) -> String {
        var coloredGuess = ""
        for char in guess {
            switch char {
            case "1": coloredGuess += "\(ANSIColors.red)1\(ANSIColors.reset)"
            case "2": coloredGuess += "\(ANSIColors.green)2\(ANSIColors.reset)"
            case "3": coloredGuess += "\(ANSIColors.yellow)3\(ANSIColors.reset)"
            case "4": coloredGuess += "\(ANSIColors.blue)4\(ANSIColors.reset)"
            case "5": coloredGuess += "\(ANSIColors.magenta)5\(ANSIColors.reset)"
            case "6": coloredGuess += "\(ANSIColors.cyan)6\(ANSIColors.reset)"
            default: coloredGuess += String(char)
            }
        }
        return coloredGuess
    }

    // Format result with pegs
    func formatResult(black: Int, white: Int) -> String {
        let blackPegs = String(repeating: "●", count: black)
        let whitePegs = String(repeating: "○", count: white)
        return "\(ANSIColors.black)\(blackPegs)\(ANSIColors.reset)\(ANSIColors.white)\(whitePegs)\(ANSIColors.reset)"
    }
}

// MARK: - CLI Controller (no @main, script style)
struct MastermindCLI {
    static let game = MastermindGame()

    static func run() async {
        print("\(ANSIColors.bold)\(ANSIColors.cyan)=================================\(ANSIColors.reset)")
        print("\(ANSIColors.bold)\(ANSIColors.cyan)        MASTERMIND GAME         \(ANSIColors.reset)")
        print("\(ANSIColors.bold)\(ANSIColors.cyan)=================================\(ANSIColors.reset)")
        print("\(ANSIColors.yellow)Welcome to Mastermind!\(ANSIColors.reset)")
        print("\(ANSIColors.white)Try to guess the 4-digit code.\(ANSIColors.reset)")
        print("\(ANSIColors.white)Each digit is between 1 and 6.\(ANSIColors.reset)")
        print("\(ANSIColors.white)● = Correct digit in correct position\(ANSIColors.reset)")
        print("\(ANSIColors.white)○ = Correct digit in wrong position\(ANSIColors.reset)")
        print("\(ANSIColors.white)Type 'exit' at any time to quit.\(ANSIColors.reset)")
        print()

        var isRunning = true
        while isRunning {
            print("\(ANSIColors.bold)\(ANSIColors.green)Choose an option:\(ANSIColors.reset)")
            print("\(ANSIColors.white)1. Start a new game\(ANSIColors.reset)")
            print("\(ANSIColors.white)2. Exit\(ANSIColors.reset)")
            print("\(ANSIColors.cyan)Enter your choice (1-2): \(ANSIColors.reset)", terminator: "")

            if let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
                switch choice {
                case "1":
                    await startGame()
                case "2", "exit":
                    isRunning = false
                    print("\(ANSIColors.yellow)Thank you for playing! Goodbye!\(ANSIColors.reset)")
                default:
                    print("\(ANSIColors.red)Invalid choice. Please try again.\(ANSIColors.reset)")
                }
            }
        }
    }

    static func startGame() async {
        do {
            try await game.startNewGame()
            print("\(ANSIColors.green)Enter your 4-digit guess (digits 1-6):\(ANSIColors.reset)")

            var gameActive = true
            var attemptCount = 0
            while gameActive {
                print("\(ANSIColors.cyan)Guess #\(attemptCount + 1): \(ANSIColors.reset)", terminator: "")
                guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    continue
                }
                if input.lowercased() == "exit" {
                    try await game.deleteGame()
                    gameActive = false
                    continue
                }
                do {
                    let result = try await game.makeGuess(input)
                    attemptCount += 1
                    let formattedGuess = game.formatGuess(input)
                    let formattedResult = game.formatResult(black: result.black, white: result.white)
                    print("\(ANSIColors.white)Guess: \(formattedGuess) | Result: \(formattedResult)\(ANSIColors.reset)")
                    if result.black == 4 {
                        print("\(ANSIColors.bold)\(ANSIColors.green)🎉 Congratulations! You've cracked the code in \(attemptCount) attempts!\(ANSIColors.reset)")
                        try await game.deleteGame()
                        gameActive = false
                    }
                } catch GameError.invalidGuess {
                    print("\(ANSIColors.red)Invalid guess. Please enter exactly 4 digits between 1 and 6.\(ANSIColors.reset)")
                } catch {
                    print("\(ANSIColors.red)Error: \(error.localizedDescription)\(ANSIColors.reset)")
                }
            }
        } catch {
            print("\(ANSIColors.red)Error starting game: \(error.localizedDescription)\(ANSIColors.reset)")
        }
        print()
    }
}

// Run asynchronously
Task { await MastermindCLI.run(); exit(EXIT_SUCCESS) }
dispatchMain()
