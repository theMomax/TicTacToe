//
//  Player.swift
//  TicTacToc
//
//  Created by Max Obermeier on 06.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation

public protocol Player {
    
    /// Provides the `Player`'s next pick given the current situation on the `gameboard`.
    ///
    /// The `gameboard` is manipulated, so that the `Player`'s picks are represented
    /// by `Fieldstate.a`.
    func react(to gameboard: [Position:FieldState]) -> Position?
    
    func accept(_ outcome: Outcome)
}

public extension Player {
    func accept(_ outcome: Outcome) {}
}

public extension Player {
    
    func name() -> String {
        switch self {
        case _ as AlgorithmicPlayer:
            return "Math"
        case _ as RandomPlayer:
            return "Drunk Fool"
        default:
            return "unknown"
        }
    }
    
}


public class RandomPlayer: Player {
    
    public init(){ }
    
    public func react(to gameboard: [Position : FieldState]) -> Position? {
        var options: [Position] = Position.allCases
        options.removeAll(where: {(p) in
            gameboard[p] != nil
            })
        return options.randomElement()
    }
    
}

public extension Position {
    static func others(_ positions: [Position]) -> [Position] {
        return Position.allCases.filter { p in
            return !positions.contains(p)
            }
    }
}

extension Position: Comparable {
    public static func < (lhs: Position, rhs: Position) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}



extension Sequence where Self.Element : Comparable {
 
    @inlinable func bisorted() -> [Self.Element] {
        var evens: [Self.Element] = []
        var unevens: [Self.Element] = []
        var even = true
        for e in self {
            even ? evens.append(e) : unevens.append(e)
            even.toggle()
        }
        evens.sort()
        unevens.sort()
        
        var all: [Self.Element] = []
        
        for i in 0..<evens.count + unevens.count {
            all.append((i % 2 == 0) ? evens[i/2] : unevens[i/2])
        }
        
        return all
    }
    
}

public class AlgorithmicPlayer: Player {
    
    private class Node {
        
        init(from activePlayer: FieldState, with children: [Position:Node] = [:], after gameboard: [Position:FieldState] = [:], inOrder picks: [Position] = []) {
            self.children = children
            
            let options = Position.others(gameboard.compactMap({ (pos, state) in
                return pos
            }))
            let winner = GameModel.evaluate(gameboard)
            if options.count > 0 && winner == nil {
                for p in options {
                    var newPicks = picks
                    
                    if newPicks.count <= 1 || newPicks[newPicks.count - 2] < p {
                        newPicks.append(p)
                        var newGameboard = gameboard
                        newGameboard[p] = activePlayer
                        
                        self.children[p] = Node(from: activePlayer.toggled(), after: newGameboard, inOrder: newPicks)
                    } else {
                        self.children[p] = Node()
                    }
                }
            } else {
                self.o = winner == nil ? 0 : winner! == .a ? -1 : 1
            }
        }
        
        init() {
            self.children = [:]
            self.o = nil
            self.linknode = true
        }
        
        var linknode: Bool = false
        
        var o : Double?
        
        var outcome: Double {
            get {
                return max(-1, min(1, o ?? -1))
            }
            set {
                o = newValue
            }
        }
        
        var children: [Position:Node]
        
        
        func best() -> Position? {
            if children.count == 0 {
                return nil
            }
            
            var best: [(key: Position, value: Node)] = []
            for c in children {
                if best.count == 0 || c.value.outcome > best[0].value.outcome {
                    best = [c]
                } else if c.value.outcome == best[0].value.outcome {
                    best.append(c)
                }
            }
            return best.randomElement()?.key
        }
        
    }
    
    
    
    
    
    public init() {
        connectLinkNodesAndCalcOutcomes()
    }
    
    
    
    private func connectLinkNodesAndCalcOutcomes() {
        connectLinkNodes(of: decisionTreeFirst, in: decisionTreeFirst)
        calcOutcomes(of: decisionTreeFirst, from: .b)
        connectLinkNodes(of: decisionTreeSecond, in: decisionTreeSecond)
        calcOutcomes(of: decisionTreeSecond, from: .a)
    }
    
    private func connectLinkNodes(of node: Node, following path: [Position] = [], in tree: Node) {
        
        for (p, n) in node.children {
            var newPath = path
            newPath.append(p)
            
            if !n.linknode {
                connectLinkNodes(of: n, following: newPath, in: tree)
            } else {
                node.children[p] = trace(path: newPath.bisorted(), tree: tree)
                
            }
        }
    }
    
    private func calcOutcomes(of node: Node, from activePlayer: FieldState) {
        if node.o == nil {
            var sum = 0.0
            var forcePrevent = false
            for (_, n) in node.children {
                calcOutcomes(of: n, from: activePlayer.toggled())
                
                // make sure player can't be tricked into a defeat, if more paths lead to victory
                if activePlayer == .a && n.outcome == -1 {
                    forcePrevent = true
                    break
                }
                
                sum += n.outcome
            }
            
            node.o = forcePrevent ? -1 : sum / Double(node.children.count)
        }
    }
    
    private var decisionTreeSecond: Node = Node(from: .a)
    
    private var decisionTreeFirst: Node = Node(from: .b)
        
    
    
    
    public func react(to gb: [Position : FieldState]) -> Position? {
        // Toggle gameboard, since this algorithm was originally written to play as
        // player .b, but now the interface was normalized, so that every player
        // plays as .a.
        var gameboard = gb
        for (p, s) in gameboard {
            gameboard[p] = s.toggled()
        }
        
        let apicks: [Position] = gameboard.filter({ (_, state) in
            return state == .a
            }).map({ (pos, _) in
                return pos
            }).sorted()
        
        let bpicks: [Position] = gameboard.filter({ (_, state) in
        return state == .b
        }).map({ (pos, _) in
            return pos
            }).sorted()
        
        let astarted = apicks.count > bpicks.count
        
        return trace(first: astarted ? apicks : bpicks, second: astarted ? bpicks : apicks, tree: astarted ? decisionTreeSecond : decisionTreeFirst)?.best()
    }
    
    private func trace(path: [Position], tree: Node) -> Node? {
        var node: Node = tree
        
        for p in path {
            if let n = node.children[p] {
                node = n
            } else {
                return node
            }
        }
        
        return node
    }
    
    private func trace(first: [Position], second: [Position], tree: Node) -> Node? {
        var node: Node? = tree
        
        for i in 0..<first.count + second.count {
            node = node?.children[(i % 2 == 0) ? first[i/2] : second[i/2]]
        }
        return node
    }
    
}
