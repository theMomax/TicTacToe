//
//  Player.swift
//  TicTacToc
//
//  Created by Max Obermeier on 06.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation


protocol Player {
    
    func react(to gameboard: [Position:FieldState]) -> Position?
    
    func accept(_ outcome: Outcome)
}

extension Player {
    func accept(_ outcome: Outcome) {}
}


class RandomPlayer: Player {
    
    func react(to gameboard: [Position : FieldState]) -> Position? {
        var options: [Position] = Position.allCases
        options.removeAll(where: {(p) in
            gameboard[p] != nil
            })
        return options.randomElement()
    }
    
}

class UIPlayer: Player {
    
    func react(to gameboard: [Position : FieldState]) -> Position? {
        return Position.mid
    }
    
    
    func accept(_ outcome: Outcome) {
        
    }
}

class AIPlayer: RandomPlayer { // the ai is just doing random stuff for now
    
}

class AlgorithmicPlayer: RandomPlayer { // so does the algorithm
    
}
