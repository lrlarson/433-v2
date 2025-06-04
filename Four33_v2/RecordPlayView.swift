//
//  RecordPlayView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI
import Combine


struct RecordPlayView: View {
    
    @State var viewModel = RPV_ViewModel()      // RecordPlayView-ViewModel
    
    var numCells:Int = 30
    var colors: [Color] = [.red, .yellow, .green]
    let saveRecordingPrompt = "If you would like to save this performance, enter a name for it. This is your only chance to save it!"
    let recInterruptedNamePrompt = "Recording was interrupted. If you would like to save the partial recording, enter a name for it (max. \(appConstants.MAX_RECORDNAME_LENGTH) characters) and hit 'OK'."
    let duplicateNamePrompt = "A recording by that name already exists. Please try another."
    
    var body: some View {
        VStack {
            Text(viewModel.perfName)
                .padding(.bottom, 20.0)
                .font(.system(size: 20))
            HStack() {
                VStack {
                    Image("4'33\" Label")
                        .frame(width: 140)
                    Spacer()
                }
                ZStack {
                    AudioView(level: viewModel.meterLevel, numCells: numCells, colors: colors)
                        .frame(minWidth: 30, idealWidth: 60, maxWidth: 60, minHeight: 1, idealHeight: CGFloat(18 * numCells), maxHeight: CGFloat(18 * numCells), alignment: .center)
                    Text(viewModel.piece_paused ? "-- PAUSED --" : "")
                        .frame(width: 140, height: 80)
                        .font(.system(size: 20))
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
                if (viewModel.piece_recording) {
                    recordButtonView(name: "Stop", image:"stop_wht-512", action:viewModel.interruptRecording, disabled:viewModel.piece_playing)
                } else {
                    recordButtonView(name: "Record", image:"record_wht_red-512", action:viewModel.startRecording, disabled:viewModel.piece_playing)
                }
                
                recordButtonView(name: "Reset", image:"skip_to_start_wht-512", action:viewModel.resetRecordPlayback, disabled:false)
                
                if (viewModel.piece_playing && !viewModel.piece_paused) {
                    recordButtonView(name: "Pause", image:"pause_wht-512", action:viewModel.pausePlaying, disabled:viewModel.piece_recording)
                } else {
                    recordButtonView(name: "Play", image:"play_wht-512", action:viewModel.play, disabled:viewModel.piece_recording)
                }
            }
            
            .alert("Microphone permission needed", isPresented: $viewModel.displayMicPermissionAlert) {
            } message: {
                Text("If you wish to record your own performances of 4'33\", you will need to go to Settings/Privacy & Security/Microphone\nand enable this app.")
            }
            
            .alert("Location permission needed", isPresented: $viewModel.displayLocationPermissionAlert) {
            } message: {
                Text("You won't be able to share this performance, because Location Services are not enabled. If you wish to share subsequent performances with the World of 4'33\", you will need to go to Settings/Privacy & Security/Location Services\nand enable this app.")
            }
            
            .alert("Save partial recording?", isPresented: $viewModel.displayPartialRecordingAlert) {
                TextField("Recording Name", text: $viewModel.perfName)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.perfName) { viewModel.perfName = Files.trimPerfName(name: viewModel.perfName ) }
                Button("OK", action: viewModel.finishSave)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(recInterruptedNamePrompt)
            }
            
            .alert("Please enter a valid name", isPresented: $viewModel.displayValidNameAlert) {
                TextField("Recording Name", text: $viewModel.perfName)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.perfName) { viewModel.perfName = Files.trimPerfName(name: viewModel.perfName) }
                Button("OK", action: viewModel.finishSave)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(recInterruptedNamePrompt)
            }
            
            .alert("Duplicate name", isPresented: $viewModel.displayDuplicateNameAlert) {
                TextField("Recording Name", text: $viewModel.perfName)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.perfName) { viewModel.perfName = Files.trimPerfName(name: viewModel.perfName)  }
                Button("OK", action: viewModel.finishSave)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(duplicateNamePrompt)
            }
            
            .alert("Save recording", isPresented: $viewModel.displaySaveRecordingAlert) {
                TextField("Recording Name", text: $viewModel.perfName)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.perfName) { viewModel.perfName = Files.trimPerfName(name: viewModel.perfName) }
                Button("OK", action: viewModel.finishSave)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(saveRecordingPrompt)
            }
        }.onDisappear {
            viewModel.reenableAutoLockAfterDelay(seconds: 30)
        }.onAppear {
            // TODO: fix this (have to get 'isRecording' and 'isPlaying' working correctly)
            //if (viewModel.audioRecorder?.isRecording || viewModel.audioRecorder?.isPlaying)
            //viewModel.disableAutolock()
        }
    }
}

struct recordButtonView: View {
    let name:String
    let image:String
    let action:() -> Void
    let disabled:Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.system(size: 12))
                .padding(.top)
                .frame(height: 0.1)
                .foregroundStyle(disabled ? Color.gray : Color.white)
            Button( action: {
                action()
            }) {
                Image(image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
            .disabled(disabled)
        }.buttonStyle(.plain)
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
            }.padding(.bottom, 6.0)
        }
    }
}


/*
 #Preview {
 RecordPlayView(eventType: <#timerEvent#>, percentProgress: <#Double#>, pieceElapsed: <#CFTimeInterval#>, movementSecondsRemaining: <#CFTimeInterval#>)
 }
 */
