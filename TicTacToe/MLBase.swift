//
//  MLBase.swift
//  TicTacToe
//
//  Created by Max Obermeier on 24.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import Foundation
import CoreML


extension Position {
    
    init?(description: String) {
        switch description.lowercased() {
        case "topleft":
            self = .topLeft
        case "top":
            self = .top
        case "topright":
            self = .topRight
        case "midleft":
            self = .midLeft
        case "mid":
            self = .mid
        case "midright":
            self = .midRight
        case "bottomleft":
            self = .bottomLeft
        case "bottom":
            self = .bottom
        case "bottomright":
            self = .bottomRight
        default:
            return nil
        }
    }
    
}

extension Position {
    func description() -> String {
        switch self {
        case .topLeft:
            return "topLeft"
        case .top:
            return "top"
        case .topRight:
            return "topRight"
        case .midLeft:
            return "midLeft"
        case .mid:
            return "mid"
        case .midRight:
            return "midRight"
        case .bottomLeft:
            return "bottomLeft"
        case .bottom:
            return "bottom"
        case .bottomRight:
            return "bottomRight"
        }
    }
}

class MLWrapper {
    
    var updateTasks: Int = 0
    
    var startedUpdateTasks: Int = 0
    
    var completedUpdateTasks: Int = 0
    
    let bundle = Bundle(for: UpdatableNNClassifier.self)
    
    let updatableModelURL: URL
    
    var model = UpdatableNNClassifier()
    
    var trainingData: [(gameboard: [Position: FieldState], pick: Position)] = []
    
    init() {
        self.updatableModelURL = bundle.url(forResource: "UpdatableNNClassifier", withExtension: "mlmodelc")!
    }
    
    private func other(than pick: Position, in gameboard: [Position: FieldState?]) -> Position? {
        var picked =  gameboard.compactMap({ (k, _) in
            k
            })
        picked.append(pick)
        return Position.others(picked).randomElement()
    }
    
    private func convertInput(gameboard: [Position: FieldState]) -> MLMultiArray {
        var gba: [Double] = []
        
        for p in Position.allCases {
            gba.append(gameboard[p] == nil ? 0 : gameboard[p] == .a ? 1 : -1)
        }
        
        return try! MLMultiArray(gba)
    }
    
    private func convertOutput(output: UpdatableNNClassifierOutput) -> Position? {
        return Position(description: output.pick)
    }
    
    func predict(on gameboard: [Position: FieldState]) -> Position? {
        let input = convertInput(gameboard: gameboard)
        if let output = try? model.prediction(gameboard: input) {
            if let result = convertOutput(output: output) {
                trainingData.append((gameboard, result))
                return result
            } else {
                return nil
            }
        } else {
            print("Unexpected runtime error in \(model).")
            return nil
        }
    }
    
    func reflect(on outcome: Outcome) {
        do {
            let bp: MLBatchProvider = try MLArrayBatchProvider(dictionary: ["gameboard": trainingData.compactMap { i in
                return convertInput(gameboard: i.gameboard)
            }, "pick": trainingData.compactMap({ i in
                outcome != .defeat ? i.pick.description() : other(than: i.pick, in: i.gameboard)?.description() ?? i.pick.description()
            })])
            
            let updateTask = try MLUpdateTask(forModelAt: updatableModelURL, trainingData: bp, configuration: self.model.model.configuration, completionHandler: { ctx in
                if ctx.task.error == nil {
                    self.updateTasks -= 1
                    self.completedUpdateTasks += 1
                    print("completed update task succescully (\(self.updateTasks) left) (\(self.completedUpdateTasks) total)")
                    self.model.model = ctx.model
                } else {
                    print(ctx.task.error!)
                }
            })
            print("resuming...")
            updateTask.resume()
            self.updateTasks += 1
            self.startedUpdateTasks += 1
            print("increased updateTasks to \(self.updateTasks) (\(self.startedUpdateTasks) total)")
        } catch {
            print(error)
        }
    }
    
}
