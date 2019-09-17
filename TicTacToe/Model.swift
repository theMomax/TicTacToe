//
//  Model.swift
//  TicTacToc
//
//  Created by Max Obermeier on 06.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation
import SwiftUI

enum Position: Int, CaseIterable {
    case topLeft, top, topRight, midLeft, mid, midRight, bottomLeft, bottom, bottomRight
    
    func row() -> [Position] {
        var row: [Position] = []
        
        let first = Position.init(rawValue: rawValue - (rawValue % 3))!
        row.append(first)
        row.append(Position.init(rawValue: first.rawValue + 1)!)
        row.append(Position.init(rawValue: first.rawValue + 2)!)
        
        return row
    }
    
    static func rows() -> [[Position]] {
        return [Position.top.row(), Position.mid.row(), Position.bottom.row()]
    }
    
    func column() -> [Position] {
        var column: [Position] = []
        
        var pval = rawValue
        while pval >= 3 {
            pval -= 3
        }
        
        column.append(Position.init(rawValue: pval)!)
        column.append(Position.init(rawValue: pval+3)!)
        column.append(Position.init(rawValue: pval+6)!)
        
        return column
    }
    
    static func columns() -> [[Position]] {
        return [Position.midLeft.column(), Position.mid.column(), Position.midRight.column()]
    }
    
    static func diagonals() -> [[Position]] {
        return [[.topLeft, .mid, .bottomRight], [.topRight, .mid, .bottomLeft]]
    }
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
    
    var a: Player {
        get {
            players[.a]!
        }
        set {
            players[.a] = newValue
        }
    }
    
    var b: Player {
        get {
            players[.b]!
        }
        set {
            players[.b] = newValue
        }
    }
    
    var players: [FieldState: Player]
    
    var outcome: Outcome?
    
    init(gameboard: [Position: FieldState] = [:], a: Player, b: Player) {
        self.gameboard = gameboard
        self.players = [.a: a, .b: b]
        self.outcome = nil
    }
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

class Context: ObservableObject {
    
    @Published private var i: Int = 0
    
    var iterations: Int {
        get {
            max(0, i)
        }
        set {
            i = newValue
        }
    }
    
    var iterationcontrol: Double {
        get {
            pow(Double(iterations), (1.0/3.0))
        }
        set {
            iterations = Int(newValue * newValue * newValue)
        }
    }
    
    @Published var gm: GameModel
    
    @Published var ai: AIPlayer
    
    var opponent: Player {
        get {
            stats[opponentNr].opponent
        }
    }
    
    var aistats: Statistics {
        get {
            stats[stats.count-1]
        }
        set {
            stats[stats.count-1] = newValue
        }
    }
    
    var opponentstats: Statistics {
        get {
            stats[opponentNr]
        }
        set {
            stats[opponentNr] = newValue
        }
    }
    
    /// - Invariant: count may not change after initialization
    @Published var stats: [Statistics]
    
    @Published private var o: Int = 0
    
    var opponentNr: Int {
        get {
            o
        }
        set {
            o = max(0, min(stats.count, newValue))
        }
    }
    
    init(ai: AIPlayer, opponents: [Player]) {
        self.ai = ai
        var allplayers = opponents
        allplayers.append(ai)
        var stats: [Statistics] = []
        allplayers.forEach({ p in
            stats.append(Statistics(opponent: p))
        })
        self.stats = stats
        self.gm = GameModel(gameboard: [:], a: ai, b: allplayers[0])
    }
}


