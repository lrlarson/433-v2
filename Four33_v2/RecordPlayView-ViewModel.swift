//
//  RecordPlayView-ViewModel.swift
//  Four33_v2
//
//  Created by PKSTONE on 12/8/24.
//

import Foundation
import AVFoundation
import UIKit

extension RecordPlayView {
    @Observable class ViewModel: PieceTimerDelegate {
        private var pieceTimer:PieceTimer?
        private var meterTimer:Timer? = nil
        private var audioPlayer:AVAudioPlayer?
        private var audioRecorder:AVAudioRecorder?
        private var secondsLeftInMovemnt = 0
        
        var meterLevel: Double = 0.0      // Audio meter
        var move1prog:CGFloat = 0.0
        var move2prog:CGFloat = 0.0
        var move3prog:CGFloat = 0.0
        var elapsedTime = ""
        var intermissionTime = ""
        
        var audioSessionDenied = false
        var playbackWasInterrupted = false
        var recordingWasInterrupted = false
        var resignedActiveDuringRecording = false
        var playbackWasPaused = false
        var piece_recording = false
        var piece_playing = false
        var piece_paused = false
        var inMovement = false
        var currentPlayMovement:Int = 0

        
        var displayPermissionAlert = false
        
        init() {
            pieceTimer = PieceTimer(timerGr: appConstants.TIMER_GRAIN,
                                    mv1dur: appConstants.MVI_DURATION,
                                    mv2dur: appConstants.MVII_DURATION,
                                    mv3dur: appConstants.MVIII_DURATION,
                                    interMvDur: appConstants.INTER_MOVEMENT_DURATION,
                                    deleg:self)
            let _ = checkMicAuth()
            
            // Create temp recording directory, if necessary
            if (!FileUtils.createRecordingDir()) {
                print("Error: couldn't create temp recording directory.")
            }
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
        
        // Check privacy authorizaton for this app to use the microphone.
        // Warn user if microphone permission is denied.
        // Return: true if 'allowed'
        func checkMicAuth() -> Bool {
            let micPermission = AVAudioApplication.shared.recordPermission
            if (micPermission == .undetermined) {
                AVAudioApplication.requestRecordPermission() { granted in
                    if (!granted) {
                        // Warn user that recording won't work without permission to use microphone
                        self.displayPermissionAlert = true
                    }
                }
                return false
            }
            else if (micPermission == .denied)
            {
                self.displayPermissionAlert = true
                return false
            }
            return true
        }
        
        func killPieceTimer() {
            if (pieceTimer != nil) {
                pieceTimer!.killTimer()
            }
        }
        
        func startPieceTimer() {
            pieceTimer!.startTimerWithQueueTime(queueTime: -1)
        }
        
        func startRecording() {
            // If microphone permission is not given, warn user
            if (checkMicAuth())
            {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.playAndRecord, mode: .default)
                    try audioSession.setActive(true)
                } catch {
                    print("Failed to set audio session category: \(error)")
                }

                resetPieceToStart()
                startPieceTimer()
                piece_recording = true
                recordMovement(movement: "One")
            }
        }
        
        func stopRecording() {
            piece_recording = false
            killPieceTimer()
            audioRecorder?.stop()
            stopAudioMetering()
        }
        
        func startPlaying() {
            piece_playing = true
            //startPieceTimer()
        }
        
        func stopPlaying() {
            piece_playing = false
        }
        
        func resetRecordPlayback() {
            killPieceTimer()
            piece_recording = false;
            piece_playing = false;
        }
        
        func initAllDisplay() {
            elapsedTime = ""
            intermissionTime = ""
            meterLevel = 0.0
            move1prog = 0.0
            move2prog = 0.0
            move3prog = 0.0
        }
        
        func resetPieceToStart() {
            initAllDisplay()
            currentPlayMovement = 0
            inMovement = false
            piece_paused = false
            //[prog_intermission setText: @""]
            //[piece_time setText: @""]
            //[paused_status setText: @""]
            //[pieceTimer resetTimer]
            playbackWasPaused = false
            //recordingNeedsSaving = false
            //secondsLeftInMovement = 999999
        }


        func recordMovement(movement:String)
        {
            let url = FileUtils.buildFullTempURL(movement:movement)
            // Start the recorder, audio file type: WAV (kAudioFileWAVEType)
            let recordSettings: [String : Any] = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                                AVSampleRateKey: 44100.0,
                                          AVNumberOfChannelsKey: 1,
                                       AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
                audioRecorder?.prepareToRecord()
                audioRecorder?.isMeteringEnabled = true
                startAudioMetering()
                audioRecorder?.record()
            } catch {
                print("Error creating audio Recorder. \(error)")
            }
            
            // Hook the level meter up to the Audio Queue for the recorder
            //[lvlMeter_in setAq: recorder->Queue()];
                
            //[self setFileDescriptionForFormat:recorder->DataFormat() withName:path];
            
        // USED TO THINK THIS WAS NECESSARY, BUT IT'S NOT:
        //    // Wait a half second, then start the timer with accurate queue time
        //    [self performSelector:@selector(startRecordTimer) withObject:nil afterDelay:0.001];
            //[self startRecordTimer];
        }

        func startAudioMetering() {
            // Refresh audio meter at 10 hz.
            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { newTimer in
                self.updateAudioMeter()
            }
        }

        func stopAudioMetering() {
            if meterTimer != nil {
                meterTimer!.invalidate()
            }
            meterLevel = 0.0
        }

        func updateAudioMeter() {   //called by timer
            // audioRecorder being your instance of AVAudioRecorder
            audioRecorder?.updateMeters()
            let decibels = audioRecorder?.averagePower(forChannel:0)
            meterLevel = pow(10, Double(decibels! / 20.0))
        }
    }
}
