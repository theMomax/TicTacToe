//
//  Controller.swift
//  TicTacToe
//
//  Created by Max Obermeier on 12.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation


extension GameModel {
    
    /// Returns the winner
    func evaluate() -> FieldState? {
        for c in Position.columns() {
            if let s = evaluate(on: c) {
                return s
            }
        }
        
        for r in Position.rows() {
            if let s = evaluate(on: r) {
                return s
            }
        }
        
        for d in Position.diagonals() {
            if let s = evaluate(on: d) {
                return s
            }
        }
        
        return nil
    }
    
    private func evaluate(on set: [Position]) -> FieldState? {
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

extension FieldState {
    
    func toggle() -> FieldState {
        return self == .a ? .b : .a
    }
    
    static func random() -> FieldState {
        return Bool.random() ? FieldState.a : FieldState.b
    }
    
}

class GameFlowController {
    
    let queue = DispatchQueue(label: "io.github.themomax.gameflow")
    
    var ctx: Context? = nil
    
    func start(with context: Context, calling update: @escaping (Context, String?) -> ()) {
        if ctx == nil {
            ctx = context
            process(calling: update)
        } else {
            ctx?.iterations = context.iterations
        }
    }
    
    
    func process(calling update: @escaping (Context, String) -> ()) {
        queue.async {
            
            while self.ctx!.iterations > 0 {
                sleep(2)
                // reset game
                self.ctx!.gm = GameModel(gameboard: [:], a: self.ctx!.ai, b: self.ctx!.opponent)
                update(self.ctx!, "reset game for \(UIPlayer.playername(of: self.ctx!.opponent)) <-> \(UIPlayer.playername(of: self.ctx!.ai))")
                
                var activePlayer = FieldState.random()
                
                for i in 0..<9 {
                    sleep(1)
                    let pos = self.ctx!.gm.players[activePlayer]!.react(to: self.ctx!.gm.gameboard)
                    
                    // check for illegal reaction
                    if pos == nil || self.ctx!.gm.gameboard[pos!] != nil {
                        self.ctx!.gm.players[activePlayer]!.accept(.defeat)
                        self.ctx!.gm.players[activePlayer.toggle()]!.accept(.victory)
                        update(self.ctx!, "\(activePlayer) did a illegal move, with pos \(pos!)")
                        break
                    }
                    
                    self.ctx!.gm.gameboard[pos!] = activePlayer
                    update(self.ctx!, "\(activePlayer) moved to \(pos!)")
                    
                    if let e = self.ctx!.gm.evaluate() {
                        self.ctx!.gm.players[e]!.accept(.victory)
                        self.ctx!.gm.players[e.toggle()]!.accept(.defeat)
                        if e == .a {
                            self.ctx!.aistats.victories += 1
                            self.ctx!.opponentstats.defeats += 1
                        } else {
                            self.ctx!.aistats.defeats += 1
                            self.ctx!.opponentstats.victories += 1
                        }
                        break
                    }
                    
                    if i == 8 {
                        self.ctx!.gm.a.accept(.draw)
                        self.ctx!.gm.b.accept(.draw)
                        self.ctx!.aistats.draws += 1
                        self.ctx!.opponentstats.draws += 1
                    } else {
                        activePlayer = activePlayer.toggle()
                    }
                }
                self.ctx!.iterations -= 1
                update(self.ctx!, "completed game: \(self.ctx!.iterations) left")
                
                if self.ctx!.iterations == 0 {
                    // update(self.ctx!, "completed all iterations")
                }
            }
            update(self.ctx!, "Iterations: \(self.ctx!.iterations); AIPlayerStats: \(self.ctx!.aistats)")
            
            self.ctx = nil
            
        }
        
        /*queue.async {
            while self.ctx!.iterations > 0 {
                sleep(1)
                self.ctx!.iterations -= 1
                callback(self.ctx!)
            }
            self.ctx = nil
        }*/
    }
}
