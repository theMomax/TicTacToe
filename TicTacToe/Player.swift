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

extension Player {
    
    func name() -> String {
        switch self {
        case _ as UIPlayer:
            return "You"
        case _ as AIPlayer:
            return "Robot"
        case _ as AlgorithmicPlayer:
            return "Math"
        case _ as RandomPlayer:
            return "Drunk Fool"
        default:
            return "unknown"
        }
    }
    
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

class UIPlayer: Player, ObservableObject {
    
    @Published var enabled: Bool = false
    
    private var choice: Position? = nil
    
    func receive(choice: Position) {
        self.choice = choice
    }
    
    func react(to gameboard: [Position : FieldState]) -> Position? {
        DispatchQueue.main.sync {
            enabled  = true
        }
        choice = nil
        
        // TODO: manage this using signal instead of await-loop
        
        while self.choice == nil {
            usleep(50000)
            DispatchQueue.main.async {
                print("\(String(describing: self.choice))")
            }
        }
        DispatchQueue.main.sync {
            enabled = false
        }
        return choice
    }
    
    
    func accept(_ outcome: Outcome) {
        
    }
}

class AIPlayer: RandomPlayer { // ai does random stuff for now
    
}

class AlgorithmicPlayer: RandomPlayer { // so does the algorithm
    
}
