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

    @Observable class ViewModel {     // AVAudioPlayerDelegate
        
        private var metadata = Files.RecordingMetaData()
        private var locationManager = LocationManager()
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
        
        
        var displayMicPermissionAlert = false
        var displayLocationPermissionAlert = false
        
        init() {
            
            pieceTimer = PieceTimer(timerGr: appConstants.TIMER_GRAIN,
                                    mv1dur: appConstants.MVI_DURATION,
                                    mv2dur: appConstants.MVII_DURATION,
                                    mv3dur: appConstants.MVIII_DURATION,
                                    interMvDur: appConstants.INTER_MOVEMENT_DURATION,
                                    onTimerFire: pieceTimerUpdate )
            let _ = checkMicAuth()
            
            // Create current recording directory, if necessary
            do {
                try Files.createRecordingDir(pieceName: Files.currentRecordingDirectory)
            } catch {
                print("Error: couldn't create temp recording directory.")
            }
            
            // Create default metadata file
            do {
                try Files.writeMetadataToURL(url: Files.getCurrentRecordingURL().appendingPathComponent(Files.metadataFilename),
                                             metadata: metadata)
            } catch {
                print("Couldn't create initial metadata file.", error)
            }
            
            // Initialize location manager
            // (this triggers the privacy-location-permission dialog when called the first time)
            locationManager.checkLocationAuthorization()
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
                if (piece_recording) {
                    stopRecording()
                } else if (piece_playing) {
                    stopPlaying()
                }
            case .movementTwoStart:
                intermissionTime = ""
                if (piece_recording) {
                    recordMovement(movement: "Two")
                } else if (piece_playing) {
                    playMovement(movement: "Two")
                }
            case .movementTwoEnd:
                if (piece_recording) {
                    stopRecording()
                } else if (piece_playing) {
                    stopPlaying()
                }
            case .movementThreeStart:
                intermissionTime = ""
                if (piece_recording) {
                    recordMovement(movement: "Three")
                } else if (piece_playing) {
                    playMovement(movement: "Three")
                }
            case .pieceCompleted:
                endPerformance(recordingIsComplete:true)
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
                        self.displayMicPermissionAlert = true
                    }
                }
                return false
            }
            else if (micPermission == .denied)
            {
                self.displayMicPermissionAlert = true
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
            
            metadata.geohash = appConstants.LOCATION_NOT_RECORDED
            locationManager.checkLocationAuthorization()
            if (locationManager.lastAuthorized) {
                let location = locationManager.lastKnownLocation
                if (location != nil) {
                    metadata.geohash = GeoHash.hash(forLatitude:location!.latitude,
                                           longitude:location!.longitude,
                                           length:(UInt32)(appConstants.GEOHASH_DIGITS_HI_ACCURACY))
                }
            } else {
                // If location permission is not given, warn user
                displayLocationPermissionAlert = true
            }
            
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
                
                // Create  metadata
                metadata.created = timeStamp()
                
                /*
                 try Files.writeMetadataToURL(url: Files.getCurrentRecordingURL().appendingPathComponent(Files.metadataFilename),
                 metadata: {Files.RecordingMetaData(created:timestamp),
                 geohash:appConstants.LOCATION_NOT_RECORDED, title:"")}())
                 } catch {
                 print("Couldn't create initial metadata.", error)
                 }
                 */
                
                
                resetPieceToStart()
                startPieceTimer()
                piece_recording = true
                recordMovement(movement: "One")
                Files.deleteMovement(movement: "Two")
                Files.deleteMovement(movement: "Three")
            }
        }
        
        
        // Return a twenty-digit timestamp of the form yyyyMMddHHmmssSSSSSS
        func timeStamp() -> String {
            let date = Date()
            var integralSeconds : Double = 0.0
            let fractionalSeconds = modf(date.timeIntervalSince1970, &integralSeconds)
            let fracSecString = String(format: "%.6f", fractionalSeconds)
            let formatted = date.formatted(
                .verbatim("\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased))\(minute: .twoDigits)\(second: .twoDigits)"
                          as Date.FormatString,
                          locale: .autoupdatingCurrent,
                          timeZone: .current,
                          calendar: .current))
            return formatted + String(fracSecString.dropFirst(2))
        }
        
        func interruptRecording() {
            // Called by pressing the "stop" button while recording
            stopRecording()
            killPieceTimer()
            piece_recording = false
            
            // TODO: offer save for partial recording
        }
        
        func stopRecording() {
            stopAudioMetering()
            audioRecorder?.stop()
            audioRecorder = nil
        }
        
        func startPlaying() {
            resetPieceToStart()
            startPieceTimer()
            piece_playing = true
            playMovement(movement: "One")
        }
        
        func stopPlaying() {
            stopAudioMetering()
            audioPlayer?.stop()
            audioPlayer = nil
        }
        
        func resetRecordPlayback() {
            killPieceTimer()
            resetPieceToStart()
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
            playbackWasPaused = false
            //recordingNeedsSaving = false
            //secondsLeftInMovement = 999999
        }


        func recordMovement(movement:String)
        {
            let url = Files.currentRecordingMovementURL(movement:movement)
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
            
            //[self setFileDescriptionForFormat:recorder->DataFormat() withName:path];
            
        // USED TO THINK THIS WAS NECESSARY, BUT IT'S NOT:
        //    // Wait a half second, then start the timer with accurate queue time
        //    [self performSelector:@selector(startRecordTimer) withObject:nil afterDelay:0.001];
            //[self startRecordTimer];
        }
        
        
        func playMovement(movement:String)
        {
            //[self disableAutoLock];
            // create a new queue for the given movement
            let url = Files.currentRecordingMovementURL(movement:movement)

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.isMeteringEnabled = true
                startAudioMetering()
                audioPlayer?.play()
            } catch {
                print("Error creating audio Recorder. \(error)")
            }
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
            var decibels:Float = -160.0
            
            if (piece_recording && audioRecorder != nil) {
                audioRecorder?.updateMeters()
                decibels = (audioRecorder?.averagePower(forChannel:0))!
            } else if (piece_playing && audioPlayer != nil) {
                audioPlayer?.updateMeters()
                decibels = (audioPlayer?.averagePower(forChannel:0))!
            }
            if (decibels <= -160.0) {
                meterLevel = 0.0
            } else {
                meterLevel = pow(10, Double(decibels / 20.0))
            }
        }
        
        func endPerformance(recordingIsComplete:Bool) {
            killPieceTimer()
            if (piece_recording) {
                stopRecording()
                piece_recording = false
            } else if (piece_playing) {
                stopPlaying()
                piece_playing = false
                currentPlayMovement = 0
                inMovement = false
            }
            // Set a 30 second timer, to delay the inevitable autolock until user has time to see screen
            //[self reenableAutoLockInSecs:[NSNumber numberWithDouble:30.0]];
            if (recordingIsComplete) {
                do {
                    try Files.saveRecording(name:"testx")
                } catch {
                    switch error {
                    default: print ("Save recording error: ", error)
                    }
                }
            }
        }
    }
}
