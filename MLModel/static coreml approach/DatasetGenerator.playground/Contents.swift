import Foundation

//: Constants

let SIZE = 100000
let NAME = "TestingData"


//: Generate data.

let alg = AlgorithmicPlayer()

var csv: String = "topLeft, top, topRight, midLeft, mid, midRight, bottomLeft, bottom, bottomRight, pick\n"


func normalized(_ gb: [Position: FieldState], if isNotNormalized: Bool = true) -> [Position: FieldState] {
    if isNotNormalized {
        var ngb = gb
        for (p, s) in ngb {
            ngb[p] = s.toggled()
        }
        return ngb
    } else {
        return gb
    }
}

extension FieldState {
    static func describe(_ fieldState: FieldState?) -> String {
        switch fieldState {
        case .a:
            return "a"
        case .b:
            return "b"
        default:
            return " "
        }
    }
}

func describe(_ gb: [Position: FieldState]) -> String {
    return " \(FieldState.describe(gb[.topLeft])) | \(FieldState.describe(gb[.top])) | \(FieldState.describe(gb[.topRight])) \n" +
    "-----------\n" +
    " \(FieldState.describe(gb[.midLeft])) | \(FieldState.describe(gb[.mid])) | \(FieldState.describe(gb[.midRight])) \n" +
    "-----------\n" +
    " \(FieldState.describe(gb[.bottomLeft])) | \(FieldState.describe(gb[.bottom])) | \(FieldState.describe(gb[.bottomRight])) \n"
}

var i = SIZE
while i > 0 {
    let alreadyFilled = Int.random(in: 0...8)
    
    var picks = [Position]()
    
    for _ in 0..<alreadyFilled {
        picks.append(Position.others(picks).randomElement()!)
    }
    
    var gameboard = [Position:FieldState]()
    
    var player = alreadyFilled % 2 == 0 ? FieldState.a  : FieldState.b
    
    for p in picks {
        gameboard[p] = player
        player = player.toggled()
    }
    
    if GameModel.evaluate(gameboard) != nil {
        continue
    }
    
    let correctPick = alg.react(to: gameboard)
    print(correctPick)
    
    for p in Position.allCases {
        if let s = gameboard[p] {
            if s == .a {
                csv.append("1")
            } else {
                csv.append("-1")
            }
        } else {
            csv.append("0")
        }
        csv.append(", ")
        
        csv.append("\(gameboard[p] == nil ? 0 : gameboard[p]! == .a ? 1 : -1), ")
    }
    
    csv.append("\(correctPick!.rawValue)\n")
    
    i -= 1
}




//: Save generated data as csv.

let fileManager = FileManager.default

let path = try fileManager.url(for: .desktopDirectory, in: .allDomainsMask, appropriateFor: nil , create: true )

let fileURL = path.appendingPathComponent(NAME + ".csv")
    
try csv.write(to: fileURL, atomically: true , encoding: .utf8)


