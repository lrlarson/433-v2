//
//  RecordPlayView-ViewModel.swift
//  Four33_v2
//
//  Created by PKSTONE on 12/8/24.
//

import Foundation

extension RecordPlayView {
    @Observable
    class ViewModel: PieceTimerDelegate {
        private var pieceTimer:PieceTimer?
        private var secondsLeftInMovemnt = 0
        
        var levelOne: Double = 0.9
        var move1prog:CGFloat = 0.0
        var move2prog:CGFloat = 0.0
        var move3prog:CGFloat = 0.0
        var elapsedTime = ""
        var intermissionTime = ""
        var isRecording = false
        var isPlaying = false
        
        init() {
            pieceTimer = PieceTimer(timerGr: appConstants.TIMER_GRAIN,
                                    mv1dur: appConstants.MVI_DURATION,
                                    mv2dur: appConstants.MVII_DURATION,
                                    mv3dur: appConstants.MVIII_DURATION,
                                    interMvDur: appConstants.INTER_MOVEMENT_DURATION,
                                    deleg:self)
        }
        
        func pieceTimerUpdate(eventType: timerEvent, newVal: Double) {
            switch eventType {
            case .pieceElapsedTime:
                let etime = Int(round(newVal))
                elapsedTime = String(format:"%1d:%02d", etime / 60, etime % 60)
            case .movementSecondsRemaining:
                secondsLeftInMovemnt = Int(newVal);
            case .movementOneProgress:
                move1prog = newVal
            case .movementTwoProgress:
                move2prog = newVal
            case .movementThreeProgress:
                move3prog = newVal
            case .intermissionProgress:
                let itime = Int(round(newVal))
                intermissionTime = "Break: " + String(format:"%1d:%02d", itime / 60, itime % 60)
            case .movementOneEnd:
                print ("movement one end")
            case .movementTwoStart:
                intermissionTime = ""
            case .movementTwoEnd:
                print ("movement two end")
            case .movementThreeStart:
                intermissionTime = ""
            case .movementThreeEnd:
                print ("movement three end")
            case .pieceCompleted:
                if (pieceTimer != nil)
                {
                    // This *may* get replaced by recording/playback ending.
                    pieceTimer!.killTimer()
                }
                intermissionTime = "Complete."
            }
        }
        
        func killPieceTimer() {
            if (pieceTimer != nil) {
                pieceTimer!.killTimer()
            }
        }
        
        func startPieceTimer() {
            initAllDisplay()
            pieceTimer!.startTimerWithQueueTime(queueTime: -1)
        }
        
        func startRecording() {
            isRecording = true
            startPieceTimer()
        }
        
        func stopRecording() {
            isRecording = false
            killPieceTimer()
        }
        
        func startPlaying() {
            isPlaying = true
            //startPieceTimer()
        }
        
        func stopPlaying() {
            isPlaying = false
        }
        
        func resetRecordPlayback() {
            killPieceTimer()
            isRecording = false;
            isPlaying = false;
        }
        
        func initAllDisplay() {
            elapsedTime = ""
            intermissionTime = ""
            levelOne = 0.0
            move1prog = 0.0
            move2prog = 0.0
            move3prog = 0.0
        }
    }
}
