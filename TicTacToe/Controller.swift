//
//  Controller.swift
//  TicTacToe
//
//  Created by Max Obermeier on 12.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation


extension GameModel {
    
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

extension FieldState {
    
    func toggled() -> FieldState {
        return self == .a ? .b : .a
    }
    
    static func random() -> FieldState {
        return Bool.random() ? FieldState.a : FieldState.b
    }
    
}

class GameFlowController {
    
    let queue = DispatchQueue(label: "io.github.themomax.gameflow")
    
    var ctx: Context
    
    var running: Bool = false
    
    func start() {
        if !running {
            process()
        }
    }
    
    init(ctx: Context) {
        self.ctx = ctx
    }
    
    
    func process() {
        running = true
        queue.async {
            
            while self.ctx.iterations > 0 {
                // reset game
                DispatchQueue.main.sync {
                    self.ctx.gm.gameboard = [:]
                    self.ctx.gm.a = self.ctx.ai
                    self.ctx.gm.b = self.ctx.opponent
                }
                
                var activePlayer = FieldState.random()
                
                for i in 0..<9 {
                    usleep(1000000 / useconds_t(max(Double(self.ctx.iterations), 1)))
                    let pos = self.ctx.gm.players[activePlayer]!.react(to: self.ctx.gm.gameboard)
                    print("\(activePlayer): \(String(describing: pos))")
                    
                    // check for illegal reaction
                    if pos == nil || self.ctx.gm.gameboard[pos!] != nil {
                        self.ctx.gm.players[activePlayer]!.accept(.defeat)
                        self.ctx.gm.players[activePlayer.toggled()]!.accept(.victory)
                        break
                    }
                    
                    DispatchQueue.main.sync {
                        self.ctx.gm.gameboard[pos!] = activePlayer
                    }
                    
                    if let e = self.ctx.gm.evaluate() {
                        print("\(e) has won")
                        
                        self.ctx.gm.players[e]!.accept(.victory)
                        self.ctx.gm.players[e.toggled()]!.accept(.defeat)
                        if e == .a {
                            DispatchQueue.main.sync {
                                self.ctx.aistats.victories += 1
                                self.ctx.opponentstats.defeats += 1
                            }
                        } else {
                            DispatchQueue.main.sync {
                                self.ctx.aistats.defeats += 1
                                self.ctx.opponentstats.victories += 1
                            }
                        }
                        break
                    }
                    
                    if i == 8 {
                        print("draw")
                        self.ctx.gm.a.accept(.draw)
                        self.ctx.gm.b.accept(.draw)
                        DispatchQueue.main.sync {
                            self.ctx.aistats.draws += 1
                            self.ctx.opponentstats.draws += 1
                        }
                    } else {
                        activePlayer = activePlayer.toggled()
                    }
                }
                
                DispatchQueue.main.sync {
                    self.ctx.iterations -= 1
                }
                
                if self.ctx.iterations > 0 {
                    usleep(2000000 / useconds_t(max(Double(self.ctx.iterations), 1)))
                }
            }
            
            self.running = false
        }
    }
}
