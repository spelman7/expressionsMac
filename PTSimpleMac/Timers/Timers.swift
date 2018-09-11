import Cocoa

extension SimpleViewController {
    
    func startDenoiseTimer() {
        clickDenoiseTimer = Timer.scheduledTimer(timeInterval: denoiseTimerPeriod, target: self, selector: (#selector(SimpleViewController.denoiseTimerExpired)), userInfo: nil, repeats: false)
        denoiseTimerIsActive = true
    }
    
    func denoiseTimerExpired() {
        denoiseTimerIsActive = false
    }
    
    func startDragTimer() {
        dragTimer = Timer.scheduledTimer(timeInterval: dragTimerPeriod, target: self, selector: (#selector(SimpleViewController.dragTimerExpired)), userInfo: nil, repeats: false)
        dragTimerIsActive = true
    }
    
    func dragTimerExpired() {
        dragTimerIsActive = false
    }
    
    /*
    func startHeadGestureTimer() {
        headGestureTimer = Timer.scheduledTimer(timeInterval: headGestureTimerPeriod, target: self, selector: (#selector(SimpleViewController.headGestureTimerExpired)), userInfo: nil, repeats: false)
        headGestureTimerIsActive = true
    }
    
    func headGestureTimerExpired() {
        headGestureTimerIsActive = false
    }
    
    func startHeadPositionRunningAverageTimer() {
        headPositionRunningAverageTimer = Timer.scheduledTimer(timeInterval: headPositionRunningAverageTimerPeriod, target: self, selector: (#selector(SimpleViewController.headPositionRunningAverageTimerExpired)), userInfo: nil, repeats: false)
        headPositionRunningAverageTimerIsActive = true
    }
    
    func headPositionRunningAverageTimerExpired() {
        headPositionRunningAverageTimerIsActive = false
    }
    
    func startHeadPositionCalibrationTimer() {
        headPositionCalibrationTimer = Timer.scheduledTimer(timeInterval: headPositionCalibrationTimerPeriod, target: self, selector: (#selector(SimpleViewController.headPositionCalibrationTimerExpired)), userInfo: nil, repeats: false)
        headPositionCalibrationTimerIsActive = true
        print ("START head position calibration timer, mouse disabled")
    }
    
    func headPositionCalibrationTimerExpired() {
        headPositionCalibrationTimerIsActive = false
        isCalibratingCenter = false
        calibrationMode = false
        
        estimateHeadRotationCenter(headPositionCenterSamples)
        print ("END head position calibration timer, mouse enabled")
        sendDataToUnity("hasEndedCalibration")
        //switchToActiveView()
    }
    */
}
