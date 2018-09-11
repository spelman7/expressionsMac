import Cocoa

extension SimpleViewController {
    func processVisageOrientationData(_ visageOrientation: [Float]) {
        
        stillnessFactor = calculateStillnessFactor(visageOrientation)
        
        if (iPhoneVersion == "Not Detected") {
            iPhoneVersion = "Front Standard"
            self.iPhoneLabel.stringValue = "iPhone Camera: " + iPhoneVersion
        }
        
        // get current mouse location
        let mouseLoc = NSEvent.mouseLocation()
        
        var rotX = visageOrientation[0]
        var rotY = visageOrientation[1]
        let rotZ = visageOrientation[2]
        
        // Trim Y value to be within a certain range
        rotY = rotY + 180
        
        // Invert X and Y values
        rotX = -rotX
        rotY = -rotY
        
        // Send X rotation value to the app interface
        self.rotationXlabel.stringValue = String(format: "%.2f", rotX)
        self.rotationYlabel.stringValue = String(format: "%.2f", rotY)
        self.rotationZlabel.stringValue = String(format: "%.2f", rotZ)
        
        if (modeMouseEnabled) {
            
            // Convert X & Y to be in the CG coordinate system
            let mouseLocXCG = mouseLoc.x
            let mouseLocYCG = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y
            
            // calculate the distance between the x/y rotational and 0
            var distXY = (rotX * rotX) + (rotY * rotY)
            distXY = distXY.squareRoot()
            
            // set the threshold for starting to move, depending on the current moving state
            if (stateMoving) {
                distXYthreshold = Float(2)
            } else {
                distXYthreshold = Float(4)
            }
            
            // set the 'moving' state equal to false to it defaults to false even though it helped set the distXYthreshold just before this
            stateMoving = false
            
            if (modeSmoothness == "linear") {
                
                // create linear scalar based on distXY
                let linearScalar = Float(0.85)
                
                if (distXY > distXYthreshold) {
                    // calculate how much the cursor should move up or down
                    let dy = CGFloat(rotX * linearScalar)
                    
                    // calculate how much the cursor should move left or right
                    let dx = CGFloat(rotY * linearScalar)
                    
                    // move the cursor
                    CGDisplayMoveCursorToPoint(0, CGPoint(x: mouseLocXCG + dx, y: mouseLocYCG - dy))
                    
                    // set the 'moving' state equal to true
                    stateMoving = true
                }
                
            } else if (modeSmoothness == "quadratic") {
                
                // create quadratic scalar based on distXY
                let quadraticScalar = ((0.03 * (distXY - distXYthreshold)) * (0.03 * (distXY - distXYthreshold))) + 0.05
                
                if (distXY > distXYthreshold) {
                    // calculate how much the cursor should move up or down
                    var dy = CGFloat(rotX * quadraticScalar)
                    
                    // calculate how much the cursor should move left or right
                    var dx = CGFloat(rotY * quadraticScalar)
                    
                    // round dx and dy to nearest integer accurately
                    dx.round()
                    dy.round()
                    
                    // move the cursor
                    CGDisplayMoveCursorToPoint(0, CGPoint(x: mouseLocXCG + dx, y: mouseLocYCG - dy))
                    
                    // set the 'moving' state equal to true
                    stateMoving = true
                }
                
            } else if (modeSmoothness == "cubic") {
                
                // create cubic scalar based on distXY
                let cubicScalar = (0.1 * (((0.1 * (distXY - distXYthreshold)) - 1) * ((0.1 * (distXY - distXYthreshold)) - 1) * ((0.1 * (distXY - distXYthreshold)) - 1))) + 0.1
                
                if (distXY > distXYthreshold) {
                    // calculate how much the cursor should move up or down
                    var dy = CGFloat(rotX * cubicScalar)
                    
                    // calculate how much the cursor should move left or right
                    var dx = CGFloat(rotY * cubicScalar)
                    
                    // round dx and dy to nearest integer accurately
                    dx.round()
                    dy.round()
                    
                    // move the cursor
                    CGDisplayMoveCursorToPoint(0, CGPoint(x: mouseLocXCG + dx, y: mouseLocYCG - dy))
                    
                    // set the 'moving' state equal to true
                    stateMoving = true
                }
                
            } else if (modeSmoothness == "sigmoid") {
                
                // create sigmoid scalar based on distXY
                let sigmoidScalar = ((0.85*exp((distXY - 20)/2)) / (exp((distXY - 20)/2) + 1)) + 0.05
                
                if (distXY > distXYthreshold) {
                    
                    // calculate how much the cursor should move up or down
                    var dy = -CGFloat(rotX * sigmoidScalar)
                    
                    // calculate how much the cursor should move left or right
                    var dx = CGFloat(rotY * sigmoidScalar)
                    
                    // round dx and dy to nearest integer accurately
                    dx.round()
                    dy.round()
                    
                    //print ("dx: " + String(Float(dx)) + " dxR: " + String(dxR) + "  dy: " + String(Float(dy)) + " dyR: " + String(dyR))
                    
                    // move the cursor
                    CGDisplayMoveCursorToPoint(0, CGPoint(x: mouseLocXCG + dx, y: mouseLocYCG + dy))
                    
                    // set the 'moving' state equal to true
                    stateMoving = true
                    
                } // if (distXY > distXYthreshold)
                
            } // else if (modeSmoothness == "sigmoid")
            
        } // if (modeMouseEnabled)
        
    } // func processVisageOrientationData(_ visageOrientation: [Float])
    
    func calculateStillnessFactor(_ visageOrientation: [Float]) -> Float {
        
        // attach most recent orientation to orientation array and pop the most distant
        recentOrientations.append(visageOrientation)
        if (recentOrientations.count > numStillnessMeasures) {
            recentOrientations.remove(at: 0)
        }
        
        // calculate the average distance for x,y,z orientation over the past numStillnessMeasures frames
        var avgDeltaOrientationX = Float(0.0)
        var avgDeltaOrientationY = Float(0.0)
        var avgDeltaOrientationZ = Float(0.0)
        var maxStillness = Float(0.0)
        
        if (recentOrientations.count == numStillnessMeasures) {
            for i in 0 ..< (numStillnessMeasures - 1) {
                let orientationN = recentOrientations[i]
                let orientationN1 = recentOrientations[i+1]
                avgDeltaOrientationX += abs(orientationN[0] - orientationN1[0])
                avgDeltaOrientationY += abs(orientationN[1] - orientationN1[1])
                avgDeltaOrientationZ += abs(orientationN[2] - orientationN1[2])
            }
            
            avgDeltaOrientationX /= Float(numStillnessMeasures - 1)
            avgDeltaOrientationY /= Float(numStillnessMeasures - 1)
            avgDeltaOrientationZ /= Float(numStillnessMeasures - 1)
            
            maxStillness = max(avgDeltaOrientationX, avgDeltaOrientationY)
            maxStillness = max(maxStillness, avgDeltaOrientationZ)
        }
        
        return maxStillness
    }
    
} // extension SimpleViewController
