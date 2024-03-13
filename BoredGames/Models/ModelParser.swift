//
//  ModelParser.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/8/24.
//

import Foundation

struct Credentials: Decodable {
    let clientId: String
    let clientSecret: String
    let uaaUrl: String
    let url: String
}

func getService() -> (String, String)? {
    let credentialsPath = Bundle.main.path(forResource: "credentials", ofType: "json")
    guard let path = credentialsPath else {
        print("Credentials file not found")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let credentials = try JSONDecoder().decode(Credentials.self, from: data)
        guard let token = requestToken(credentials: credentials) else { return .none }
        return (token, credentials.url)
    } catch {
        print("Error loading credentials: \(error)")
        return nil
    }
}

func requestToken(credentials: Credentials) -> String? {
    let authString = "\(credentials.clientId):\(credentials.clientSecret)"
    guard let authData = authString.data(using: .utf8) else {
        print("Error encoding auth data")
        return nil
    }
    
    let base64Auth = authData.base64EncodedString()
    let tokenUrl = URL(string: "\(credentials.uaaUrl)/oauth/token")!
    var request = URLRequest(url: tokenUrl)
    request.httpMethod = "POST"
    request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var token: String?
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }
        guard let data = data, error == nil else {
            print("Error requesting token: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                token = accessToken
            }
        } catch {
            print("Error parsing token response: \(error)")
        }
    }
    
    task.resume()
    semaphore.wait()
    return token
}

func promptLLM(prior: String, prompt: String, contexts: [String] = [], temp: Float = 0.7) -> String? {
    guard let (token, svcUrl) = getService() else {
        print("Error getting service")
        return nil
    }
    
    let editedPrompt = prompt.isEmpty ? "" : prompt
    var messages = contexts.map { context in
        ["role": "assistant", "content": context]
    }
    messages.append(["role": "user", "content": editedPrompt])
    messages.insert(["role": "system", "content": prior], at: 0)
    
    guard let requestBody = try? JSONSerialization.data(withJSONObject: [
        "deployment_id": "gpt-4-32k",
        "messages": messages,
        "max_tokens": 500,
        "temperature": temp,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "top_p": 0.95,
        "stop": "null"
    ]) else {
        print("Error creating request body")
        return nil
    }
    
    var request = URLRequest(url: URL(string: "\(svcUrl)/api/v1/completions")!)
    request.httpMethod = "POST"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = requestBody
    
    let semaphore = DispatchSemaphore(value: 0)
    var responseString: String?
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }
        guard let data = data, error == nil else {
            print("Error requesting LLM prompt: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                responseString = content
            }
        } catch {
            print("Error parsing LLM response: \(error)")
        }
    }
    
    task.resume()
    semaphore.wait()
    return responseString
}

func extractCode(from text: String) -> String? {
    let codeParts = text.components(separatedBy: "```")
    guard codeParts.count > 1 else { return nil }
    return String(codeParts[1].dropFirst("swift".count))
}

func generateCode(prompt: String, contexts: [String] = [], temp: Float = 0.2) -> String? {
    guard let response = promptLLM(
        prior: "You are a coding assistant. You are helping a user write a Swift program. Only respond with relevant code; no explanation or comments.",
        prompt: prompt,
        contexts: contexts,
        temp: temp
    ) else {
        print("Error generating code")
        return .none
    }
    return extractCode(from: response)
}

func numberedListToArray(text: String) -> [String] {
    return text.components(separatedBy: "\n").map { line in
        let startIndex = line.index(after: line.firstIndex(of: ".")!)
        return String(line[startIndex...])
    }.filter { !$0.isEmpty }
}

func generateGame(prompt: String) -> String? {
    let prior = """
    Your job will be to look for a fun way to combine real-world objects to make a sequential game (game theory). Your response should be formatted as:

    Representative Emoji: eg. 🎲

    Game Title: eg. Dice Roll

    Set-Up Instructions: eg.
    1. Place the dice in the center of the table.
    2. Each player takes turns rolling the dice.

    Turn-Instructions: eg.
    1. Player rolls the dice.
    2. Player reads the number at the top of the dice.

    Winning/Losing Condition: e.
    1. The player who rolls the highest number wins.
    2. The player who rolls the lowest number loses.

    Winning/Losing Condition: eg.
    1. The player who rolls the highest number wins.
    2. The player who rolls the lowest number loses.

    Ignored-Objects: eg.
    1. Coin
    2. Chess Board

    -------------------

    Your response should have NO ambiguity. You also do not need to use all objects (IGNORE IRRELEVANT SURFACES AND FURNITURE).
    """
    guard let response = promptLLM(prior: prior, prompt: prompt) else {
        print("Error generating game")
        return nil
    }
    return response
}

func generateGameFunction(objects: [String], quantities: [Int]) -> String? {
    guard objects.count == quantities.count else {
        print("Error: The number of objects and quantities must be the same")
        return nil
    }
    
    let prompt = objects.enumerated().map { index, obj in
        return quantities[index] > 1 ? "\(quantities[index]) \(obj)s" : obj
    }.joined(separator: ", ")
    
    guard let gameResponse = generateGame(prompt: prompt) else {
        print("Error generating game function")
        return nil
    }
    
    let structuredResponse = gameResponse.components(separatedBy: "\n\n").map { line in
        return line.components(separatedBy: ":")
    }
    
    var metaGame = [String: Any]()
    for responsePart in structuredResponse {
        let key = responsePart[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let value = responsePart[1].trimmingCharacters(in: .whitespacesAndNewlines)
        if value.range(of: #"^\s*\d+\.\s+.+"#, options: .regularExpression) != nil {
            metaGame[key] = numberedListToArray(text: value)
        } else {
            metaGame[key] = value
        }
    }
    
    let formattedIgnoredObjects = (metaGame["Ignored-Objects"] as? [String] ?? []).map { $0.lowercased() }
    let usedObjects = objects.filter { !formattedIgnoredObjects.contains($0) }
    
    guard let actionsPayoffsResp = promptLLM(
        prior: "You are building a sequential game in game theory. Answer with just the actions that a player can do on their turn and their payoffs in a numbered list. Answer ONLY with the numbered list in the form: 1. Action, Payoff (eg. +3)",
        prompt: "Here are the objects in the game: \(usedObjects). MAKE SURE YOUR ACTIONS ARE MUTUALLY INDEPENDENT",
        contexts: [gameResponse],
        temp: 0.3
    ) else {
        print("Error generating actions and payoffs")
        return nil
    }
    
    let actionsPayoffs = numberedListToArray(text: actionsPayoffsResp).map { $0.components(separatedBy: ", ") }
    let actions = actionsPayoffs.map { $0[0] }
    
    guard let gameCode = generateCode(
        prompt: "Write a Swift function that takes as input an array of action strings and number of players and returns the winner.",
        contexts: [gameResponse, "Actions and Payoffs:\n\(actionsPayoffsResp)"]
    ) else {
        print("Error generating game code")
        return nil
    }
    
    return gameCode
}

