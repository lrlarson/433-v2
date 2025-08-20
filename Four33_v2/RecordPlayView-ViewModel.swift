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

    @Observable
    class RPV_ViewModel : NSObject, AVAudioPlayerDelegate {
        
        var isRecordingOrPlaying = false {
            didSet {
                if let appState = self.appState {
                    let shouldShowTabs = !isRecordingOrPlaying
                    appState.shouldShowAllTabs = shouldShowTabs
                }
            }
        }
        
        private var autoLockReenableTimer:Timer? = nil
        
        private var metadata = RecordingMetaData()
        private var locationManager = LocationManager()
        private var pieceTimer:PieceTimer?
        private var meterTimer:Timer? = nil
        private var secondsLeftInMovement = 0
        var audioPlayer:AVAudioPlayer?
        var audioRecorder:AVAudioRecorder?
        
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
        var currentlyPlayingMovement = false
        var recordingDone = false
        var recordingNeedsSaving = false
        var currentPlayMovement:Int = 0
                
        var displayMicPermissionAlert = false
        var displayLocationPermissionAlert = false
        var displayPartialRecordingAlert = false
        var displayValidNameAlert = false
        var displayDuplicateNameAlert = false
        var displaySaveRecordingAlert = false

        
        override init() {
            super.init()
            pieceTimer = PieceTimer(timerGr: appConstants.TIMER_GRAIN,
                                    mv1dur: appConstants.MVI_DURATION,
                                    mv2dur: appConstants.MVII_DURATION,
                                    mv3dur: appConstants.MVIII_DURATION,
                                    interMvDur: appConstants.INTER_MOVEMENT_DURATION,
                                    onTimerFire: pieceTimerUpdate )
            let _ = checkMicAuth()
            
            // Create current recording directory (in 'temp'), if necessary
            do {
                try Files.createRecordingDir(pieceName: Files.currentRecordingDirectory)
            } catch {
                print("Error: couldn't create temp recording directory.")
            }

            // Initialize location manager
            // (this triggers the privacy-location-permission dialog when called the first time)
            locationManager.checkLocationAuthorization()
            
            setupNotifications()    // subscribe to notifications for audio interruption
        }
        
        
        // MARK: - Set up appState
        private weak var appState: AppState?
        func setUpAppState(passedAppState: AppState) {
            self.appState = passedAppState
            // Initial setup
            appState?.shouldShowAllTabs = !isRecordingOrPlaying
        }
        

        // MARK: - AVAudioPlayerDelegate
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if (secondsLeftInMovement > 2) {
                pieceTimer?.killTimer()
                piece_playing = false
            }
        }

        // MARK: - Interruption notifications
        func setupNotifications() {
            // Get the default notification center instance.
            let nc = NotificationCenter.default
            nc.addObserver(self,
                           selector: #selector(handleInterruption),
                           name: AVAudioSession.interruptionNotification,
                           object: AVAudioSession.sharedInstance())
        }
        
        @objc func handleInterruption(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }
            
            // Switch over the interruption type.
            switch type {
            case .began:
                // An interruption began. Update the UI as necessary.
                print ("Interruption began.")
                
            case .ended:
                // An interruption ended. Resume playback, if appropriate.
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // An interruption ended. Resume playback.
                    print ("Interruption ended. Resuming playback.")
                } else {
                    // An interruption ended. Don't resume playback.
                    print ("Interruption ended. Not resuming playback.")
                }
                
            default: ()
            }
        }

        // MARK: -
        
        func pieceTimerUpdate(eventType: timerEvent, newVal: Double) {
            switch eventType {
            case .pieceElapsedTime:
                let etime = Int(round(newVal))
                elapsedTime = String(format:"%1d:%02d", etime / 60, etime % 60)
            case .movementSecondsRemaining:
                secondsLeftInMovement = Int(newVal);
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
                    currentlyPlayingMovement = false
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
                    currentlyPlayingMovement = false
                }
            case .movementThreeStart:
                intermissionTime = ""
                if (piece_recording) {
                    recordMovement(movement: "Three")
                } else if (piece_playing) {
                    playMovement(movement: "Three")
                }
            case .pieceCompleted:
                currentlyPlayingMovement = false
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
        
        func updateMetadata() {
            resetPieceToStart()
            let metadataURL = Files.getTmpDirURL().appending(path: Files.currentRecordingDirectory).appending(path:Files.metadataFilename)
            let metadata = Files.readMetaDataFromURL(url: metadataURL)
            if (metadata != nil) {
                appState?.performanceName = metadata!.title
            }
        }
        
        // Turn off idle timer (auto lock) (for use while recording)
        func disableAutolock() {
            // Kill any leftover reenable timer events
            if (autoLockReenableTimer != nil) {
                autoLockReenableTimer?.invalidate()
                autoLockReenableTimer = nil;
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        func reenableAutoLockAfterDelay(seconds:Int) {
            // Kill any leftover reenable timer events
            if (autoLockReenableTimer != nil) {
                autoLockReenableTimer?.invalidate()
                autoLockReenableTimer = nil;
            }
            autoLockReenableTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { _ in
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        
        func killPieceTimer() {
            if (pieceTimer != nil) {
                pieceTimer!.killTimer()
            }
        }
                
        func startRecording() {
            resetPieceToStart()
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
                    try audioSession.setPrefersNoInterruptionsFromSystemAlerts(true)
                } catch {
                    print("Failed to set audio session category: \(error)")
                    return
                }

                // Set date/time created
                metadata.created = timeStamp()
                
                // Prevent display sleep while recording
                disableAutolock()

                if (pieceTimer != nil) {
                    pieceTimer?.resetPieceInfo()
                }
                piece_recording = true
                recordingDone = false
                recordingNeedsSaving = true
                isRecordingOrPlaying = true     // this is connected to the tab bar, and hides all other tabs
                
                pieceTimer?.startOrRestartPieceTimer()
                
                appState?.performanceName = ""
                recordMovement(movement: "One")
                Files.deleteMovement(movement: "Two")
                Files.deleteMovement(movement: "Three")
            }
        }
        
        func finishSave(newPerfName: String) {
            if (appState == nil) {return}
            if (newPerfName == "") {
                displayValidNameAlert = true
                return
            }
            if Files.isSeedRecording(name: newPerfName) {
                displayDuplicateNameAlert = true
                return
            }
            do {
                if newPerfName != "" {
                    try Files.saveRecording(name: newPerfName, metadata: metadata)
                    recordingNeedsSaving = false
                }
            } catch {
                switch error {
                case .duplicateName:
                    displayDuplicateNameAlert = true
                    break
                default: print ("Save recording error: ", error)
                }
            }
            appState?.performanceName = newPerfName
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
            if (audioRecorder != nil && audioRecorder!.isRecording) {
                // Called by pressing the "stop" button while recording
                //  (as opposed to pressing it during 'intermission')
                stopRecording()
                recordingDone = true
                isRecordingOrPlaying = false // reenable all tabs
            }
            
            pieceTimer?.killTimer()
            piece_recording = false
            
            // Offer save for partial recording
            displayPartialRecordingAlert = true
            reenableAutoLockAfterDelay(seconds: 30)
        }
        
        func stopRecording() {
            stopAudioMetering()
            audioRecorder?.stop()
            audioRecorder = nil
       }
        
        func play() {
            if (piece_paused) {
                unPausePlaying()
            } else {
                if (pieceTimer != nil) {
                    pieceTimer?.resetPieceInfo()
                }
                resetPieceToStart()
                disableAutolock()
                pieceTimer!.startOrRestartPieceTimer()
                piece_playing = true
                isRecordingOrPlaying = true     // this is connected to the tab bar, and hides all other tabs
                playMovement(movement: "One")
            }
        }
        
        func stopPlaying() {
            stopAudioMetering()
            audioPlayer?.stop()
            audioPlayer = nil
         }
        
        func pausePlaying() {
            piece_paused = true
            stopAudioMetering()
            if (currentlyPlayingMovement) {
                audioPlayer!.pause()
                isRecordingOrPlaying = false     // this is connected to the tab bar, and shows all other tabs
            }
            pieceTimer?.killTimer(saveElapsed: true)
            reenableAutoLockAfterDelay(seconds: 30)
        }
        
        func unPausePlaying() {
            piece_playing = true
            piece_paused = false
            if (audioPlayer != nil)
            {
                audioPlayer!.play()
                startAudioMetering()
                disableAutolock()
                isRecordingOrPlaying = true     // this is connected to the tab bar, and hides all other tabs
            }
            pieceTimer?.startOrRestartPieceTimer()
        }
        
        func resetRecordPlayback()  {
            pieceTimer?.killTimer()
            if (piece_recording) {
                piece_recording = false;
                stopRecording()
            } else if (piece_playing) {
                piece_playing = false;
                stopPlaying()
            }
            isRecordingOrPlaying = false     // this is connected to the tab bar, and shows all other tabs
            resetPieceToStart()
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
            currentlyPlayingMovement = false
            piece_paused = false
            playbackWasPaused = false
            recordingNeedsSaving = false
            recordingDone = false
            secondsLeftInMovement = 999999
            reenableAutoLockAfterDelay(seconds: 30)
            intermissionTime = ""
        }
        
        func deletePerformance() {
            if (audioPlayer != nil && audioPlayer!.isPlaying) {
                resetRecordPlayback()
            }
            resetPieceToStart()
            do {
                try Files.clearTempDirectory()
            } catch {
                print("Error trying to clear temp directory: \(error)")
            }
            if (appState != nil) {
                appState!.performanceName = ""
            }
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
        }
        
        
        func playMovement(movement:String)
        {
            if (appState == nil) { return }
            let url = Files.storedPerformanceMovementURL(name: appState!.performanceName, movement: movement)
            //print("Playing file \(url)")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.isMeteringEnabled = true
                startAudioMetering()
                audioPlayer?.play()
                currentlyPlayingMovement = true
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
            pieceTimer?.killTimer()
            if (piece_recording) {
                stopRecording()
                piece_recording = false
                recordingDone = true
                displaySaveRecordingAlert = true
            } else if (piece_playing) {
                stopPlaying()
                piece_playing = false
                currentPlayMovement = 0
            }
            reenableAutoLockAfterDelay(seconds: 30)
            isRecordingOrPlaying = false    // reenable all tabs
            if (recordingIsComplete) {
            }
        }
    }
}
