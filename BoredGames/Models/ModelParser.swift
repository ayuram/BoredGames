//
//  ModelParser.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/8/24.
//

import Foundation

struct ModelParser {
    static func parse(response: String) -> GameType? {
        // Split the response into lines
        let lines = response.components(separatedBy: "\n")
        
        guard let firstLine = lines.first else {
            print("Error: Response is empty.")
            return nil
        }
        
        // Determine the game type based on the first line of the response
        let gameType: GameType
        
        // Remove the first line from the response
        let contentLines = Array(lines.dropFirst())
        
        var setUp: String = ""
        var turnInstructions: String = ""
        var winningCondition: String = ""
        var losingCondition: String?
        
        // Iterate through each line to extract relevant information
        var parsingContent = false
        for line in contentLines {
            if line.starts(with: "Set-Up:") {
                parsingContent = true
            } else if line.starts(with: "Turn-Instructions:") {
                parsingContent = true
            } else if line.starts(with: "Winning Condition:") {
                parsingContent = true
            } else if line.starts(with: "Losing Condition:") {
                parsingContent = true
            } else {
                if parsingContent {
                    if line.isEmpty {
                        parsingContent = false
                    } else {
                        if line.starts(with: "Losing Condition:") && losingCondition != nil {
                            losingCondition! += "\(line)\n"
                        } else {
                            switch line {
                            case let text where text.hasPrefix("Set-Up:"):
                                setUp = String(text.dropFirst(7))
                            case let text where text.hasPrefix("Turn-Instructions:"):
                                turnInstructions = String(text.dropFirst(19))
                            case let text where text.hasPrefix("Winning Condition:"):
                                winningCondition = String(text.dropFirst(19))
                            case let text where text.hasPrefix("Losing Condition:"):
                                losingCondition = String(text.dropFirst(18))
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        // Create a game model based on the parsed information
        guard let playersRange = winningCondition.range(of: "\\d+", options: .regularExpression),
              let players = Int(winningCondition[playersRange]) else {
            print("Error: Could not extract number of players.")
            return nil
        }
        
        let rules = setUp.trimmingCharacters(in: .whitespacesAndNewlines)
        let objective = turnInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
        let winning = winningCondition.trimmingCharacters(in: .whitespacesAndNewlines)
        let losing = losingCondition?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Determine the appropriate game model based on the parsed information
        return .sequential(SequentialGame(players: players, rules: rules, objective: objective, instructions: "", winningCondition: winning, losingCondition: losing))
    }
}

func generateGame(objects: [String]) async throws -> GameType? {
    // Define your API key and endpoint
    let apiKey = "your_api_key"
    let endpoint = "https://api.openai.com/v1/engines/davinci-codex/completions"
    
    // Create the request
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let prompt = "Your job will be to look for a fun way to combine real-world objects (which I will provide) to make a game. Your response should be formatted as:\n\nRepresentative Emoji:\n\nGame Theory Game Type\n\nSet-Up:\n\nTurn-Instructions:\n\nWinning/Losing Condition:\n\n-------------------\n\nYour answer should have NO ambiguity. You do NOT need to use all objects\n" + objects.joined(separator: ",")
    // Define the prompt and other parameters
    let parameters: [String: Any] = [
        "prompt": prompt,
        "max_tokens": 150, // Adjust max_tokens as needed
        "temperature": 0.7, // Adjust temperature as needed
        "stop": ["\n"] // Stop generation at new line
    ]
    
    // Convert parameters to JSON data
    let httpBody = try JSONSerialization.data(withJSONObject: parameters)
    
    // Attach the JSON data to the request
    request.httpBody = httpBody
    
    // Send the request and await the response
    let (data, _) = try await URLSession.shared.data(for: request)
    
    // Parse the response JSON
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let choices = json["choices"] as? [[String: Any]],
          let text = choices.first?["text"] as? String else {
        throw NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
    }
    
    // Return the generated text
    return ModelParser.parse(response: text)
}
