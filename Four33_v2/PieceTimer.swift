//
//  PieceTimer.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/31/24.
//

import Foundation

enum timerEvent {
    case pieceElapsedTime
    case movementSecondsRemaining
    case movementOneProgress
    case movementTwoProgress
    case movementThreeProgress
    case intermissionProgress
    case movementOneEnd
    case movementTwoStart
    case movementTwoEnd
    case movementThreeStart
    case pieceCompleted
}

class PieceTimer {
    
    private var callback: ((timerEvent, Double) -> Void)?
    
    private var startTime:CFTimeInterval
    private var elapsedTime:CFTimeInterval
    private var elapsedTimeAtPause:CFTimeInterval
    private var movementOneDuration:CFTimeInterval
    private var movementTwoDuration:CFTimeInterval
    private var movementThreeDuration:CFTimeInterval
    private var interMovementDuration:CFTimeInterval
    private var inFirstMovement:Bool
    private var inSecondMovement:Bool
    private var inThirdMovement:Bool
    private var firstIntermission:Bool
    private var secondIntermission:Bool
    
    private var timer:Timer?
    public var timerIsRunning:Bool = false
    
    // Convenience time values
    private var pauseOneStart:CFTimeInterval?
    private var movementTwoStart:CFTimeInterval?
    private var pauseTwoStart:CFTimeInterval?
    private var movementThreeStart:CFTimeInterval?
    private var pieceEnd:CFTimeInterval?
    
    private var timerGrain:CFTimeInterval?
    
    
    init(timerGr:CFTimeInterval, mv1dur:CFTimeInterval,
         mv2dur:CFTimeInterval, mv3dur:CFTimeInterval, interMvDur:CFTimeInterval,
         onTimerFire:@escaping(timerEvent, Double) -> Void)
    {
        self.callback = onTimerFire
        
        // Initialize piece timing
        movementOneDuration = mv1dur
        movementTwoDuration = mv2dur
        movementThreeDuration = mv3dur
        interMovementDuration = interMvDur
        timerGrain = timerGr
        
        pauseOneStart = movementOneDuration
        movementTwoStart = movementOneDuration + interMovementDuration
        pauseTwoStart = movementTwoStart! + movementTwoDuration
        movementThreeStart = pauseTwoStart! + interMovementDuration
        pieceEnd = movementThreeStart! + movementThreeDuration
        
        inFirstMovement =  false
        inSecondMovement =  false
        inThirdMovement =  false
        firstIntermission = false
        secondIntermission = false
        elapsedTime = 0
        elapsedTimeAtPause = 0
        startTime = 0
        timer = nil
        timerIsRunning = false
    }
    
    
    func resetPieceInfo ()
    {
        inFirstMovement =  true
        inSecondMovement =  false
        inThirdMovement =  false
        firstIntermission = false
        secondIntermission = false
        startTime = 0
        elapsedTime = 0
        elapsedTimeAtPause = 0
    }
    
    // pauseTime = 0 when called on movement boundaries;
    // only has non-zero value when called by pause action
    func killTimer(saveElapsed:Bool = false)
    {
        timerIsRunning = false
        if (saveElapsed) {
            // Record accurate stopping time in case of restart
            elapsedTimeAtPause = elapsedTime
        } else {
            elapsedTimeAtPause = 0
        }
        if (timer != nil) {
            timer!.invalidate()
            timer = nil
        }
    }
    
    // Start piece timer
    func startOrRestartPieceTimer()
    {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerGrain!, repeats: true) { newTimer in
            self.timerFired()
        }
        
        // (re)set piece start time relative to stored elapsed time, which is zero unless incalled from 'unpause'
        elapsedTime = elapsedTimeAtPause
        startTime = CFAbsoluteTimeGetCurrent() - elapsedTime
        elapsedTimeAtPause = 0
        timerIsRunning = true
    }
        
    func timerFired()
    {
        // If event comes from just-killed timer, ignore
        if (timer == nil) {
            return
        }
        if (callback != nil) {
            elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime)
            if (elapsedTime < pauseOneStart!) {
                callback!(.pieceElapsedTime, elapsedTime)
                callback!(.movementSecondsRemaining, pauseOneStart! - elapsedTime)
                
                if (!inFirstMovement) {
                    inFirstMovement = true
                }
                callback!(.movementOneProgress, elapsedTime / movementOneDuration)
            } else if (elapsedTime < movementTwoStart!) {
                // In first between-movement pause
                if (inFirstMovement) {
                    inFirstMovement = false
                    firstIntermission = true
                    callback!(.pieceElapsedTime, elapsedTime)
                    callback!(.movementOneEnd, 0)
                }
                callback!(.intermissionProgress, interMovementDuration - (elapsedTime - pauseOneStart!))
            } else if (elapsedTime < pauseTwoStart!) {
                // In second movement
                callback!(.pieceElapsedTime, elapsedTime - interMovementDuration)
                callback!(.movementSecondsRemaining, pauseTwoStart! - elapsedTime)
                
                if (!inSecondMovement) {
                    inSecondMovement = true
                    firstIntermission = false
                    callback!(.movementTwoStart, 0)
                }
                
                let progress = (elapsedTime - movementTwoStart!) / movementTwoDuration
                callback!(.movementTwoProgress, progress)
            } else if (elapsedTime < movementThreeStart!) {
                // In second between-movement pause
                if (!secondIntermission) {
                    secondIntermission = true
                    inSecondMovement = false
                    callback!(.movementTwoEnd, 0)
                    callback!(.pieceElapsedTime, elapsedTime - interMovementDuration)
                }
                
                let progress = interMovementDuration - (elapsedTime - pauseTwoStart!)
                callback!(.intermissionProgress, progress)
            }
            else if (elapsedTime < pieceEnd!) {
                // In third movmement
                callback!(.pieceElapsedTime, elapsedTime - interMovementDuration * 2)
                callback!(.movementSecondsRemaining, pieceEnd! - elapsedTime)
                
                if (!inThirdMovement) {
                    inThirdMovement = true
                    secondIntermission = false
                    callback!(.movementThreeStart, 0)
                }
                
                let progress = (elapsedTime - movementThreeStart!) / movementThreeDuration
                callback!(.movementThreeProgress, progress)
            } else {
                callback!(.pieceElapsedTime, elapsedTime - interMovementDuration * 2)
                inThirdMovement = false
                callback!(.pieceCompleted, 0)
            }
        }
    }
}
