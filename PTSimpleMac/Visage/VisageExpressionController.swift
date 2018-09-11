import Cocoa

extension SimpleViewController {
    func processVisageExpressionData(_ visageExpressions: [Float]) {
        
        // get current mouse location
        let mouseLoc = NSEvent.mouseLocation()
        
        // Pull out each individual float value
        let noseWrinkleValue = visageExpressions[0]
        visageJawOpenValue = visageExpressions[1]
        visageEyebrowsUpValue = visageExpressions[2]
        
        // Assign the value to its corresponding IO label
        
        self.jawOpenLabel.stringValue = String(format: "%.2f", visageJawOpenValue)
        self.eyebrowsUpLabel.stringValue = String(format: "%.2f", visageEyebrowsUpValue)
        
        /*
        // if the click mode is pucker, use eyebrow values to toggle click and movement capabilities
        if (modeClick == "pucker") {
            if ((eyebrowsUpValue > 0.8) && (eyebrowsUp == false) && (denoiseTimerIsActive == false) && (stillnessFactor < stillnessThreshold)) {
                
                // invert the click and mouse mode booleans
                modeClickEnabled = !modeClickEnabled
                modeMouseEnabled = !modeMouseEnabled
                
                NSSound(named: "Submarine")?.play()
                
                sendDataToUnity("eyebrowsup")
                
                // change the click and mouse mode checkboxes
                if (modeClickEnabled) {self.clickEnabledMode.state = NSControlStateValueOn}
                else if (!modeClickEnabled) {self.clickEnabledMode.state = NSControlStateValueOff}
                if (modeMouseEnabled) {self.mouseEnabledMode.state = NSControlStateValueOn}
                else if (!modeMouseEnabled) {self.mouseEnabledMode.state = NSControlStateValueOff}
                
                // start the denoise timer
                startDenoiseTimer()
                
                // set eyebrowsUp to be true
                eyebrowsUp = true;
            } else if (eyebrowsUpValue <= 0.95) {
                eyebrowsUp = false;
            }
        }
        */
        
        // if the click mode is eyebrows, use eyebrow values to click and drag
        if ((modeClick == "eyebrows") && (modeClickEnabled)) {
            if ((!dragEnabled) || ((dragEnabled) && (visageJawOpenValue > 1.5) && (mouseIsDown == false))) {
                if ((visageEyebrowsUpValue > 0.8) && (eyebrowsUp == false) && (mouseIsDown == false) && (denoiseTimerIsActive == false)) {
                    
                    // Set eyebrows up equal to true
                    eyebrowsUp = true;
                    
                    // Get the CG cursor position
                    let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
                    let mouseLocXCG = mouseLoc.x
                    
                    // Instantiate a CG mouse down event
                    let mouseDown = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDown, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse down event
                    mouseDown.post(tap:.cghidEventTap)
                    
                    print("mouse click down")
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("down")
                    
                    // Set the mouse down boolean equal to true so we can't fire the mouse down event again before the mouse is up
                    mouseIsDown = true
                    
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    //NSSound(named: "Pop")?.play()
                    
                    // Set the mouse down boolean equal to false and start the denoise timer
                    mouseIsDown = false
                    startDenoiseTimer()
                    startDragTimer()
                    
                } else if (visageEyebrowsUpValue < 0.95) {
                    eyebrowsUp = false
                }
                
            } else if (dragEnabled) {
                
                // Get the CG cursor position
                let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
                let mouseLocXCG = mouseLoc.x
                
                if ((visageEyebrowsUpValue > 0.8) && (eyebrowsUp == false) && (mouseIsDown == false) && (denoiseTimerIsActive == false)) {
                    
                    //** BEGIN CLICK AND DRAG **
                    
                    // Set eyebrows up equal to true
                    eyebrowsUp = true;
                    
                    // Instantiate a CG mouse down event
                    let mouseDown = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDown, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse down event
                    mouseDown.post(tap:.cghidEventTap)
                    
                    print("mouse click down")
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("down")
                    
                    // Set the mouse down boolean equal to true so we can't fire the mouse down event again before the mouse is up
                    mouseIsDown = true
                    startDenoiseTimer()
                    startDragTimer()
                    
                } else if ((visageEyebrowsUpValue > 0.8) && (eyebrowsUp == false) && (mouseIsDown == true) && (denoiseTimerIsActive == false)) {
                    
                    //** END CLICK AND DRAG **
                    
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    print("end mouse drag")
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("up")
                    
                    // Set the mouse down boolean equal to false and start the denoise timer
                    mouseIsDown = false
                    startDenoiseTimer()
                    startDragTimer()
                    
                } else if ((mouseIsDown == true) && (dragTimerIsActive == false)) {
                    
                    //** CONTINUE DRAG **
                    
                    // Instantiate a CG mouse drag event
                    let mouseDrag = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDragged, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse dragged event
                    mouseDrag.post(tap:.cghidEventTap)
                    
                    if (visageEyebrowsUpValue < 0.95) {
                        eyebrowsUp = false
                    }
                    
                    // Start the drag timer
                    startDragTimer()
                    
                } else if (visageEyebrowsUpValue < 0.95) {
                    eyebrowsUp = false
                }
            } // end: if (dragEnabled)
        }
        
    } // func processVisageExpressionData(_ visageExpressions: [Float])
    
    func processVisagePuckerData(_ visagePucker: [Float]) {
        
        // calculate the horizontal distance between corner mouth vertices
        let leftCornerX = visagePucker[0]
        let rightCornerX = visagePucker[21]
        let cornerDist = rightCornerX - leftCornerX
        
        // update this pucker measure on the app's window
        self.mouthPuckerLabel.stringValue = String(format: "%.4f", cornerDist)
        
        // add this pucker measure to your running buffer of pucker measures
        recentPuckerMeasures.append(cornerDist)
        if (recentPuckerMeasures.count > numPuckerMeasures) {
            recentPuckerMeasures.remove(at: 0)
        }
        
        // get current mouse location
        let mouseLoc = NSEvent.mouseLocation()
        
        // if the click mode is pucker, click is enabled, and the app is currently classifying pucker measures, start analyzing for click
        if ((modeClick == "pucker") && (modeClickEnabled) && (isPredictingPucker == true)) {
            
            // pull the prediction from your DTW function and update the pucker prediction interface values
            let prediction: knn_certainty_label_pair = knn_dtw_pucker.predict(curve_to_test: recentPuckerMeasures)
            self.predictionLabel.stringValue = prediction.label
            self.certaintyValueLabel.stringValue = "\(prediction.probability*100)" + "%"
            
            // Get the CG cursor position
            let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
            let mouseLocXCG = mouseLoc.x
            
            if ((!dragEnabled) || ((dragEnabled) && (visageEyebrowsUpValue > visageEyebrowsUpThreshold) && (mouseIsDown == false))) {
            //if (!dragEnabled) {
            
                if ((prediction.label == "pucker") &&
                    (prediction.probability > puckerPredictionThreshold) &&
                    (stillnessFactor < stillnessThreshold) &&
                    (mouseIsDown == false) &&
                    (denoiseTimerIsActive == false))
                {
                    
                    print("visage single pucker click")
                    
                    // Instantiate a CG mouse down event
                    let mouseDown = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDown, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse down event
                    mouseDown.post(tap:.cghidEventTap)
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("down")
                    
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    // start the denoise timer
                    startDenoiseTimer()
                    
                }
                
            } else if (dragEnabled) {
                
                if ((prediction.label == "pucker") &&
                    (prediction.probability > puckerPredictionThreshold) &&
                    (stillnessFactor < stillnessThreshold) &&
                    (mouseIsDown == false) &&
                    (denoiseTimerIsActive == false))
                {
                    //** BEGIN CLICK AND DRAG **
                    print("visage pucker click and drag down")
                    
                    // Instantiate a CG mouse down event
                    let mouseDown = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDown, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse down event
                    mouseDown.post(tap:.cghidEventTap)
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("down")
                    
                    // Set the mouse down boolean equal to true so we can't fire the mouse down event again before the mouse is up
                    mouseIsDown = true
                    startDenoiseTimer()
                    startDragTimer()
                    
                } else if ((prediction.label == "pucker") &&
                    (prediction.probability > puckerPredictionThreshold) &&
                    (stillnessFactor < stillnessThreshold) &&
                    (mouseIsDown == true) &&
                    (denoiseTimerIsActive == false))
                {
                    //** END CLICK AND DRAG **
                    print("visage pucker end click and drag")
                    
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send alert to Unity that mouse is down
                    sendDataToUnity("up")
                    
                    // Set the mouse down boolean equal to true so we can't fire the mouse down event again before the mouse is up
                    mouseIsDown = false
                    startDenoiseTimer()
                    startDragTimer()
                    
                } else if ((mouseIsDown == true) && (dragTimerIsActive == false)) {
                    
                    //** CONTINUE CLICK AND DRAG **
                    print("visage drag event")
                    
                    // Instantiate a CG mouse drag event
                    let mouseDrag = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDragged, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse dragged event
                    mouseDrag.post(tap:.cghidEventTap)
                    
                    // Start the drag timer
                    startDragTimer()
                }
            } // end: if (dragEnabled)
        } // end: if (modeClick == pucker) && (modeClickEnabled) && (isPredictingPucker == true)
    } // end: processVisagePuckerData
    
} // extension SimpleViewController
