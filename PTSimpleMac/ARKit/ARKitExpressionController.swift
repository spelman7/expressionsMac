import Cocoa
import Carbon.HIToolbox

extension SimpleViewController {
    func processARKitExpressionData(_ arkitExpressions: [Float]) {
        
        // get current mouse location
        let mouseLoc = NSEvent.mouseLocation()
        
        // Pull out each individual float value
        let mouthPuckerValue = arkitExpressions[0]
        let jawOpenValue = arkitExpressions[1]
        let eyebrowsUpValue = arkitExpressions[2]
        
        // Assign the value to its corresponding IO label
        self.mouthPuckerLabel.stringValue = String(format: "%.3f", mouthPuckerValue)
        self.jawOpenLabel.stringValue =  String(format: "%.3f", jawOpenValue)
        self.eyebrowsUpLabel.stringValue =  String(format: "%.3f", eyebrowsUpValue)
        
        // Set the click value to be equal to the current click mode
        var clickValue = mouthPuckerValue
        if (modeClick == "pucker") {
            clickValue = mouthPuckerValue
        } else if (modeClick == "eyebrows") {
            clickValue = eyebrowsUpValue
        }
        
        // use eyebrow values to toggle click and movement capabilities
        if ((eyebrowsUpValue > 0.8) && (eyebrowsUp == false) && (denoiseTimerIsActive == false) && (modeClick == "pucker")) {
            
            // invert the click and mouse mode booleans
            modeClickEnabled = !modeClickEnabled
            modeMouseEnabled = !modeMouseEnabled
            
            NSSound(named: "Submarine")?.play()
            
            sendDataToUnity("eyebrowsup")
            
            //TEST KEY PRESS CODE
            let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)!
            let rawKey = kVK_ANSI_Z
            let keyPress = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(rawKey), keyDown: true)!
            keyPress.flags = CGEventFlags.maskShift
            let loc = CGEventTapLocation.cghidEventTap
            //keyPress.post(tap: loc)
            
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
        
        if (modeClickEnabled) {
            
            // Check to see if the mouth pucker value should create a mouse down action
            if ((clickValue > clickThresholdDown) && (mouseIsDown == false) && (denoiseTimerIsActive == false)) {
                
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
                
                if (!dragEnabled) {
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Set the mouse down boolean equal to false and start the denoise timer
                    mouseIsDown = false
                    startDenoiseTimer()
                    startDragTimer()
                }
            }
            
            if (dragEnabled) {
                
                // Post drag events as mouse is held down and moved
                if ((clickValue > clickThresholdUp) && (mouseIsDown == true) && (dragTimerIsActive == false)) {
                    // Get the CG cursor position
                    let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
                    let mouseLocXCG = mouseLoc.x
                    
                    // Instantiate a CG mouse drag event
                    let mouseDrag = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDragged, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    print("mouse drag")
                    
                    // Post the CG mouse dragged event
                    mouseDrag.post(tap:.cghidEventTap)
                    
                    
                    // Start the drag timer
                    startDragTimer()
                }
                
                // Post final drag event and mouse up event once
                if ((clickValue < clickThresholdUp) && (mouseIsDown == true)) {
                    
                    // Get the CG cursor position
                    let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
                    let mouseLocXCG = mouseLoc.x
                    
                    // Instantiate a CG mouse drag event
                    let mouseDrag = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseDragged, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Instantiate a CG mouse up event
                    let mouseUp   = CGEvent.init(mouseEventSource:nil, mouseType:.leftMouseUp, mouseCursorPosition:CGPoint(x: mouseLocXCG, y: mouseLocYCG), mouseButton:.left)!
                    
                    // Post the CG mouse dragged event
                    mouseDrag.post(tap:.cghidEventTap)
                    
                    // should there be a delay here?
                    
                    // Post the CG mouse up event
                    mouseUp.post(tap:.cghidEventTap)
                    
                    NSSound(named: "Pop")?.play()
                    
                    // Send Message to Unity that the mouse is up
                    sendDataToUnity("up")
                    
                    print("mouse click up")
                    
                    // Set the mouse down boolean equal to false and start the denoise timer
                    mouseIsDown = false
                    startDenoiseTimer()
                    
                } // if ((clickValue < clickThresholdUp) && (mouseIsDown == true))
                
            } // if (dragEnabled)
            
        } // if (modeClickEnabled)
        
    } // func processARKitExpressionData(_ arkitExpressions: [Float])
    
} // extension SimpleViewController
