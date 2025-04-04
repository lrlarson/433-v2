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
    private var movementOneDuration:CFTimeInterval
    private var movementTwoDuration:CFTimeInterval
    private var movementThreeDuration:CFTimeInterval
    private var interMovementDuration:CFTimeInterval
    private var inFirstMovement:Bool
    private var inSecondMovement:Bool
    private var inThirdMovement:Bool
    private var betweenMovements:Bool
    
    private var timer:Timer?
    
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
        betweenMovements = false
        elapsedTime = 0
        startTime = 0
        timer = nil
    }
    
    
    func resetPieceInfo ()
    {
        inFirstMovement =  true
        inSecondMovement =  false
        inThirdMovement =  false
        betweenMovements = false
        startTime = 0
        elapsedTime = 0
    }
    
    func killTimer()
    {
        // Record accurate stopping time in case of restart
        elapsedTime = CFAbsoluteTimeGetCurrent() - Double(startTime)
        if (timer != nil) {
            timer!.invalidate()
        }
    }
    
    // Start piece timer:
    //  (re)set piece elapsed time to align with actual queue position
    func startTimerWithQueueTime(queueTime:Double)
    {
        killTimer()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: timerGrain!, repeats: true) { newTimer in
            self.timerFired()
        }
        
        // queueTime of -1 means we're either at the start or not in a movement (intermission)
        if (queueTime != -1.0) {
            if (inFirstMovement) {
                elapsedTime = queueTime
            } else if (inSecondMovement) {
                elapsedTime = movementOneDuration + interMovementDuration + queueTime
            } else if (inThirdMovement) {
                elapsedTime = movementOneDuration + movementTwoDuration + (interMovementDuration * 2) + queueTime
            } // Note that no adjustment is made if we are between movements
        }
        startTime = CFAbsoluteTimeGetCurrent() - elapsedTime
    }
        
    func timerFired()
    {
        if (callback != nil) {
            elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime)
            if (elapsedTime < pauseOneStart!) {
                callback!(.pieceElapsedTime, elapsedTime)
                callback!(.movementSecondsRemaining, pauseOneStart! - elapsedTime)
                
                if (!inFirstMovement) {
                    inFirstMovement = true
                    betweenMovements = false
                }
                callback!(.movementOneProgress, elapsedTime / movementOneDuration)
            } else if (elapsedTime < movementTwoStart!) {
                // In first between-movement pause
                if (inFirstMovement) {
                    inFirstMovement = false
                    callback!(.pieceElapsedTime, elapsedTime)
                    callback!(.movementOneEnd, 0)
                    betweenMovements = true
                }
                callback!(.intermissionProgress, interMovementDuration - (elapsedTime - pauseOneStart!))
            } else if (elapsedTime < pauseTwoStart!) {
                // In second movement
                callback!(.pieceElapsedTime, elapsedTime - interMovementDuration)
                callback!(.movementSecondsRemaining, pauseTwoStart! - elapsedTime)
                
                if (!inSecondMovement) {
                    inSecondMovement = true
                    betweenMovements = false
                    callback!(.movementTwoStart, 0)
                }
                
                let progress = (elapsedTime - movementTwoStart!) / movementTwoDuration
                callback!(.movementTwoProgress, progress)
            } else if (elapsedTime < movementThreeStart!) {
                // In second between-movement pause
                if (!betweenMovements) {
                    betweenMovements = true
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
                    betweenMovements = false
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
