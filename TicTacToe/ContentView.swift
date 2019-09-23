//
//  ContentView.swift
//  TicTacToe
//
//  Created by Max Obermeier on 07.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import SwiftUI



extension Player {
    
    func icon() -> some View {
        switch self {
        case _ as UIPlayer:
            return Image(systemName: "person.circle")
        case _ as AlgorithmicPlayer:
            return Image(systemName: "divide.square")
        case _ as AIPlayer:
            return Image(systemName: "circle.grid.hex")
        case _ as RandomPlayer:
            return Image(systemName: "questionmark.diamond")
        default:
            return Image(systemName: "questionmark")
        }
    }
    
}

struct ContentView: View {
    
    @ObservedObject var ctx: Context = initContext
    
    var ctr: GameFlowController = gameFlowController
    
    var body: some View {
        
        
        VStack {
            GameBoardView(gb: $ctx.gm.gameboard).padding()
            Divider().padding()
            
            Picker("opponent", selection: $ctx.opponentNr) {
                ForEach(0 ..< ctx.stats.count) { index in
                    Text(self.ctx.stats[index].opponent.name())
                        .tag(index)
                }

            }
            .disabled(ctr.running)
                .pickerStyle(SegmentedPickerStyle())
                .padding(.leading).padding(.trailing)
            
            HStack {
                
                Slider(value: $ctx.iterationcontrol, in: 0...10, onEditingChanged: { stillEditing in
                    if !stillEditing {
                        self.ctr.start()
                    }
                }).padding(.trailing).padding(.leading)
                
                Text("\(ctx.iterations)").frame(width: 50, alignment: .trailing).padding(.trailing)
                
            }.padding().flipsForRightToLeftLayoutDirection(false)
            
            Divider().padding(.leading).padding(.trailing).padding(.bottom)
            
            ScrollView {
                VStack {
                    ForEach(ctx.stats, content: { stat in
                        StatsView(stats: stat)
                    })
                }.padding(.top)
                Divider().padding(.leading).padding(.trailing).padding(.bottom)
                StatsView(stats: ctx.aistats)
            }
            
        }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


struct GameBoardView: View {
    
    @Binding var gb: [Position:FieldState]
    
    var body: some View {
        
        ZStack {
            
            VStack{
                Spacer()
                Divider()
                Spacer()
                Divider()
                Spacer()
            }
            
            HStack{
                Spacer()
                Divider()
                Spacer()
                Divider()
                Spacer()
            }
            
            GameBoardLayerView(gb: $gb)
        }
        
    }
}

struct GameBoardLayerView: View {
    
    @Binding var gb: [Position:FieldState]
    
    var body: some View {
        HStack{
            VStack{
                GameFieldView(state: gb[.topLeft], pos: .topLeft)
                GameFieldView(state: gb[.midLeft], pos: .midLeft)
                GameFieldView(state: gb[.bottomLeft], pos: .bottomLeft)
                }
                
            VStack{
                GameFieldView(state: gb[.top], pos: .top)
                GameFieldView(state: gb[.mid], pos: .mid)
                GameFieldView(state: gb[.bottom], pos: .bottom)
            }
            VStack{
                GameFieldView(state: gb[.topRight], pos: .topRight)
                GameFieldView(state: gb[.midRight], pos: .midRight)
                GameFieldView(state: gb[.bottomRight], pos: .bottomRight)
            }
        }.flipsForRightToLeftLayoutDirection(false).frame(alignment: .center).aspectRatio(1, contentMode: .fill)
    }
    
}

struct GameFieldView: View {
    var state: FieldState?
    var pos: Position
    @ObservedObject var player: UIPlayer = hp
    
    var body: some View {
        Group{
            if state == nil {
                if player.enabled {
                    Image(systemName:"questionmark").font(.largeTitle).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                } else {
                    Image("unset").resizable().aspectRatio(1, contentMode: .fit)
                }
                
            } else {
                Image(state! == FieldState.a ? "circle" : "cross").resizable().aspectRatio(1, contentMode: .fit)
            }
        }.disabled(state != nil && !player.enabled).onTapGesture {
            self.player.receive(choice: self.pos)
        }
    }
}

struct StatsView: View {
    var stats: Statistics
    
    var body: some View {
        HStack{
            PlayerIconView(player: stats.opponent)
            
            if stats.matches > 0 {
                Text("\(String(format: "%.2f", stats.winrate*100))%").foregroundColor(.green)
                Spacer()
                Text("\(String(format: "%.2f", stats.drawrate*100))%").foregroundColor(.blue)
                Spacer()
                Text("\(String(format: "%.2f", stats.lossrate*100))%").foregroundColor(.red)
            }
            Spacer()
            Text("\(stats.matches)")
        }.padding(.bottom).padding(.leading).padding(.trailing)
    }
}

struct PlayerIconView: View {
    var player: Player
    
    var body: some View {
        
        var icon: some View {
            switch player {
            case _ as UIPlayer:
                return Image(systemName: "person.circle").resizable().frame(width: 40, height: 40, alignment: .center).offset(x: 0)
            case _ as AIPlayer:
                return Image("ai").resizable().frame(width: 40, height: 40, alignment: .center).offset(x: 0)
            case _ as AlgorithmicPlayer:
                return Image(systemName: "divide.square").resizable().frame(width: 40, height: 40, alignment: .center).offset(x: 1)
            case _ as RandomPlayer:
                return Image("random").resizable().frame(width: 40, height: 40, alignment: .center).offset(x: 0)
            default:
                return Image(systemName: "questionmark").resizable().frame(width: 40, height: 40, alignment: .center).offset(x: 0)
            }
        }
        
        return icon.padding(.trailing).font(Font.system(.largeTitle))
    }
}

let rp = RandomPlayer()
let hp = UIPlayer()
let aip = AIPlayer()
let aiop = AIPlayer()
let algp = AlgorithmicPlayer()
let initContext = Context(ai: aip, opponents: [rp, hp, algp, aiop])
let gameFlowController = GameFlowController(ctx: initContext)

#if DEBUG
/*
let r = RandomPlayer()
let h = UIPlayer()
let ai = AIPlayer()
let alg = AlgorithmicPlayer()
let testContext1 = Context(
    gm: GameModel(a: r, b: ai),
    ai: ai,
    stats: [
        Statistics(opponent: r, victories: 100000),
        Statistics(opponent: h),
        Statistics(opponent: alg, draws: 100),
        Statistics(opponent: ai, draws: 1000)
])*/


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //ContentView(ctx: testContext1)
            ContentView(ctx: initContext, ctr: gameFlowController)
        }
    }
}
#endif
