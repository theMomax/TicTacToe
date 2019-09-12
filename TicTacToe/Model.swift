//
//  Model.swift
//  TicTacToc
//
//  Created by Max Obermeier on 06.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation

enum Position: Int, CaseIterable {
    case topLeft, top, topRight, midLeft, mid, midRight, bottomLeft, bottom, bottomRight
}

enum FieldState {
    case a, b
}

enum Outcome: Int {
    case victory = 1
    case defeat = -1
    case draw = 0
}

struct GameModel {
    
    var gameboard: [Position:FieldState] = [:]
    
    let a: Player
    let b: Player
    
    var outcome: Outcome?
}

struct Statistics: Identifiable {
    
    var id = UUID()
    
    let opponent: Player
    
    var matches: Int {
        get {
            victories + defeats + draws
        }
    }
    
    var victories = 0
    var defeats = 0
    var draws = 0
    
    var winrate: Double {
        Double(victories) / Double(matches)
    }
    
    var lossrate: Double {
        Double(defeats) / Double(matches)
    }
    
    var drawrate: Double {
        Double(draws) / Double(matches)
    }
    
}

struct Context {
    
    var iterations: Int = 1
    
    var iterationcontrol: Double {
        get {
            Double(iterations)
        }
        set {
            iterations = Int(newValue)
        }
    }
    
    var gm: GameModel
    
    var ai: AIPlayer
    
    var stats: [Statistics]
    
    var opponent: Int = 0
}


