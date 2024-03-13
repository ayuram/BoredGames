//
//  GameModel.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/8/24.
//

import Foundation

// Enum for different types of game theory games
enum GameType {
//    case cooperative(CooperativeGame)
//    case nonCooperative(NonCooperativeGame)
//    case simultaneous(SimultaneousGame)
    case sequential(SequentialGame)
//    case zeroSum(ZeroSumGame)
//    case nonZeroSum(NonZeroSumGame)
//    case symmetric(SymmetricGame)
//    case asymmetric(AsymmetricGame)
}

let MODEL_ARGUMENTS: [String] = ["Game-Name", "Representative-Emoji", "Set-Up Instructions", "Turn-Instructions", "Point-Evaluation Method", "Transition-Instructions", "Winning/Losing Condition", "Game Hyperparameters ($type)"]

// Protocol defining the structure for a game model
protocol GameModel {
    var players: Int { get }
    var rules: String { get }
    var objective: String { get }
    var instructions: String { get }
    var winningCondition: String { get }
    var losingCondition: String? { get }
}

// Model for a sequential game
struct SequentialGame: GameModel {
    var players: Int
    var rules: String
    var objective: String
    var instructions: String
    var winningCondition: String
    var losingCondition: String?
}
