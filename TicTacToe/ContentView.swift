//
//  ContentView.swift
//  TicTacToe
//
//  Created by Max Obermeier on 07.09.19.
//  Copyright © 2019 Max Obermeier. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var ctx = initContext
    
    var body: some View {
        
        
        VStack {
            GameBoardView(gb: ctx.gm.gameboard).padding()
            Divider().padding()
            
            Picker("opponent", selection: $ctx.opponent) {
                ForEach(0 ..< ctx.stats.count) { index in
                    
                    Text("hallo")
                        .tag(index)
                }

            }.pickerStyle(SegmentedPickerStyle()).padding(.leading).padding(.trailing)
            
            Slider(value: $ctx.iterationcontrol, in: 1...1000).padding()
            
            VStack {
                ForEach(ctx.stats, content: { stat in
                    StatsView(stats: stat)
                })
            }
            
            
            
        }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


struct GameBoardView: View {
    
    var gb: [Position:FieldState]
    
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
        }.flipsForRightToLeftLayoutDirection(false)
        
    }
}

struct GameFieldView: View {
    @State var state: FieldState? = nil
    var pos: Position
    var player: UIPlayer = h
    
    var body: some View {
        ZStack{
            if state == nil {
                Image(systemName: "xmark.icloud").resizable().aspectRatio(1, contentMode: .fit)//Spacer()//EmptyView().aspectRatio(1, contentMode: .fit)
                
            } else {
                Image(systemName: state! == FieldState.a ? "clock" : "camera").resizable().aspectRatio(1, contentMode: .fit)
            }
        }.disabled(state != nil).onTapGesture {
            self.state = self.state == .a ? .b : .a
        }
    }
}

struct StatsView: View {
    @State var stats: Statistics
    
    var body: some View {
        HStack{
            Image(systemName: "faceid").font(Font.system(.largeTitle)).padding(.trailing)
            
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

let rp = RandomPlayer()
let hp = UIPlayer()
let aip = AIPlayer()
let algp = AlgorithmicPlayer()
let initContext = Context(
    gm: GameModel(a: hp, b: aip),
    ai: aip,
    stats: [
        Statistics(opponent: rp),
        Statistics(opponent: hp),
        Statistics(opponent: algp),
        Statistics(opponent: aip)
])

#if DEBUG
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
])


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(ctx: testContext1)
            ContentView()
        }
    }
}
#endif
