//
//  Model.swift
//  TicTacToc
//
//  Created by Max Obermeier on 06.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation

public enum Position: Int, CaseIterable {
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

public enum FieldState {
    case a, b
}

public extension FieldState {
    
    func toggled() -> FieldState {
        return self == .a ? .b : .a
    }
    
    static func random() -> FieldState {
        return Bool.random() ? FieldState.a : FieldState.b
    }
    
}

public enum Outcome: Int {
    case victory = 1
    case defeat = -1
    case draw = 0
}

public struct GameModel {
    
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

public extension GameModel {
    
    func evaluate() -> FieldState? {
        return GameModel.evaluate(gameboard)
    }
    
    /// Returns the winner
    static func evaluate(_ gameboard: [Position:FieldState]) -> FieldState? {
        for c in Position.columns() {
            if let s = GameModel.evaluate(gameboard, at: c) {
                return s
            }
        }
        
        for r in Position.rows() {
            if let s = GameModel.evaluate(gameboard, at: r) {
                return s
            }
        }
        
        for d in Position.diagonals() {
            if let s = GameModel.evaluate(gameboard, at: d) {
                return s
            }
        }
        
        return nil
    }
    
    static func evaluate(_ gameboard: [Position:FieldState], at set: [Position]) -> FieldState? {
        if set.count == 0 {
            return nil
        }
        
        let player = gameboard[set[0]]
        if player == nil {
            return nil
        }
        
        if set.allSatisfy ({ pos in
            gameboard[pos] == player
        }) {
            return player
        } else {
            return nil
        }
    }
    
}
