//
//  RecordPlayView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI
import AVFoundation


func requestRecordPermission() {
    AVAudioApplication.requestRecordPermission()
        { granted in
        if granted {
            // Permission granted
            print("Audio recording permission granted.")
        } else {
            // Handle permission denied
        }
    }
}


struct RecordPlayView: View {
    
    @State private var viewModel = ViewModel()      // RecordPlayView-ViewModel
    
    var numCells:Int = 30
    var colors: [Color] = [.red, .yellow, .green]
    
    var body: some View {
        VStack {
            Text("A Nice Long Title For A Test")
                .padding(.bottom, 30.0)
                .font(.system(size: 20))
            HStack() {
                VStack {
                    Image("4'33\" Label")
                        .frame(width: 140)
                    Spacer()
                }
                HStack {
                    AudioView(level: viewModel.levelOne, numCells: numCells, colors: colors)
                        .frame(minWidth: 30, idealWidth: 60, maxWidth: 60, minHeight: 1, idealHeight: CGFloat(18 * numCells), maxHeight: CGFloat(18 * numCells), alignment: .center)
                }
                VStack {
                    Spacer()
                    Text(viewModel.elapsedTime)
                        .frame(width: 140, height: 80)
                        .font(.system(size: 20))
                    Text(viewModel.intermissionTime)
                        .frame(width: 140, height: 80)
                        .font(.system(size: 20))
                }
            }
            
            VStack {
                MovementProgressView(label_text:"Movement I", bar_length:52, prog_val:viewModel.move1prog)
                MovementProgressView(label_text:"Movement II", bar_length:250, prog_val:viewModel.move2prog)
                MovementProgressView(label_text:"Movement III", bar_length:175, prog_val:viewModel.move3prog)
            }
            .padding([.bottom, .leading], 12.0)
            
            HStack {
                if (viewModel.isRecording) {
                    recordButtonView(name: "Stop", image:"stop_wht-512", action:viewModel.stopRecording)
                } else {
                    recordButtonView(name: "Record", image:"record_wht_red-512", action:viewModel.startRecording)
                }
                
                recordButtonView(name: "Reset", image:"skip_to_start_wht-512", action:viewModel.resetRecordPlayback)
    
                if (viewModel.isPlaying) {
                    recordButtonView(name: "Pause", image:"pause_wht-512", action:viewModel.stopPlaying)
                } else {
                    recordButtonView(name: "Play", image:"play_wht-512", action:viewModel.startPlaying)
                }
            }
        }
    }
}

struct recordButtonView: View {
    let name:String
    let image:String
    let action:() -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.system(size: 12))
                .padding(.top)
                .frame(height: 0.1)
            Button(action: {
                action()
            }) {
                Image(image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
        }
    }
}

struct AudioView: View {
    let level: Double
    let numCells: Int
    let colors: [Color]
    var body: some View {
        VStack(alignment: .trailing) {
            ForEach(1...numCells, id: \.self) { cell in
                HStack {
                    CellView(level: self.level, cell: cell, numCells: self.numCells, colors: self.colors)
                        .padding(2)
                }
            }
        }
    }
}

struct CellView: View {
    let level: Double
    let cell: Int
    let numCells: Int
    let colors: [Color]
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.black).padding(1)
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Double(cell) <= 0.17 * Double(numCells) ?
                                 colors[0] : (Double(cell) <= 0.4 * Double(numCells) ?
                                              colors[1] : colors[2]))
                .opacity(Double(cell) <= Double(numCells) - level * Double(numCells) ? 0.32 : 1)
        }//.frame(maxWidth: 100, maxHeight: 30, alignment: .center)
        .animation(cell == 1 ? .easeIn(duration: Double(numCells + 1 - cell) == level * Double(numCells) ?
                                                0 : 0.2).delay(Double(numCells + 1 - cell) == level * Double(numCells) ?
                                                               0 : 0.5) : .none, value: level)
    }
}

struct MovementProgressView: View {
    let label_text: String
    let bar_length: CGFloat
    let prog_val: CGFloat
    var body: some View {
        VStack {
            HStack {
                Text(label_text)
                    .font(.system(size: 16))
                    .frame(height: 1.0)
                Spacer()
            }.padding(.bottom, 6.0)
            HStack {
                ProgressView(value: prog_val)
                    .frame(width: bar_length, height: 10.0)
                Spacer()
            }
        }.padding(.bottom, 6.0)

    }

}

/*
#Preview {
    RecordPlayView(eventType: <#timerEvent#>, percentProgress: <#Double#>, pieceElapsed: <#CFTimeInterval#>, movementSecondsRemaining: <#CFTimeInterval#>)
}
*/
