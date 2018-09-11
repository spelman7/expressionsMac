import Cocoa

extension SimpleViewController {
    func processARKitOrientationData(_ arkitOrientation: [Float]) {
        
        if (iPhoneVersion == "Not Detected") {
            iPhoneVersion = "X True Depth"
            self.iPhoneLabel.stringValue = "iPhone Camera: " + iPhoneVersion
        }
        
        // get current mouse location
        let mouseLoc = NSEvent.mouseLocation()
        
        // check to see if mouseLoc is greatly different than mouseFloat
        let mouseFloatXDist = Float(mouseLoc.x) - mouseXFloat
        let mouseFloatYDist = Float(NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y) - mouseYFloat
        let mouseFloatDist = (mouseFloatXDist * mouseFloatXDist + mouseFloatYDist * mouseFloatYDist).squareRoot()
        if (mouseFloatDist > 25.0) {
            mouseFloatReset = true
        }
        
        // if mouseFloatReset is true, set the mouseFloat values equal to mouseLoc
        if (mouseFloatReset == true) {
            mouseXFloat = Float(mouseLoc.x)
            mouseYFloat = Float(NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y)
            mouseFloatReset = false
        }
        
        var rotX = arkitOrientation[0]
        var rotY = arkitOrientation[1]
        let rotZ = arkitOrientation[2]
        
        // Trim X value to be within a certain range
        if (rotX < -300) {
            rotX = rotX + 360
        } else if (rotX > 300) {
            rotX = rotX - 360
        }
        
        // Trim Y value to be within a certain range
        if (rotY < -300) {
            rotY = rotY + 360
        } else if (rotY > 300) {
            rotY = rotY - 360
        }
        
        //invert X rotation value
        rotX = -rotX
        
        //calculate distance from estimatedCenterRotationX
        //rotX = rotX - estimatedCenterRotationV
        //calculate distance from estimatedCenterRotationY
        //rotY = rotY - estimatedCenterRotationH
        
        // Send X rotation value to the app interface
        self.rotationXlabel.stringValue = String(format: "%.2f", rotX)
        self.rotationYlabel.stringValue = String(format: "%.2f", rotY)
        self.rotationZlabel.stringValue = String(format: "%.2f", rotZ)

        
        if (modeMouseEnabled) {
            
            // calculate the distance between the x/y rotational and 0
            var distXY = (rotX * rotX) + (rotY * rotY)
            distXY = distXY.squareRoot()
            
            // instantiate dx and dy variables
            var dx = Float(0.0)
            var dy = Float(0.0)
            var smoothnessModeScalar = Float(0.0)
            
            // set the threshold for starting to move, depending on the current moving state
            if (stateMoving) {
                distXYthreshold = Float(2)
            } else {
                distXYthreshold = Float(5)
            }
            
            // set the 'moving' state equal to false to it defaults to false even though it helped set the distXYthreshold just before this
            stateMoving = false
            
            if (distXY > distXYthreshold) {
                
                if (modeSmoothness == "linear") {
                    
                    // create linear scalar based on distXY
                    let linearScalar = Float(0.85)
                    smoothnessModeScalar = linearScalar
                    
                } else if (modeSmoothness == "quadratic") {
                    
                    // create quadratic scalar based on distXY
                    let quadraticScalar = ((0.03 * (distXY - distXYthreshold)) * (0.03 * (distXY - distXYthreshold))) + 0.05
                    smoothnessModeScalar = quadraticScalar
                    
                } else if (modeSmoothness == "cubic") {
                    
                    // create cubic scalar based on distXY
                    let cubicScalar = (0.1 * (((0.1 * (distXY - distXYthreshold)) - 1) * ((0.1 * (distXY - distXYthreshold)) - 1) * ((0.1 * (distXY - distXYthreshold)) - 1))) + 0.1
                    smoothnessModeScalar = cubicScalar
                    
                } else if (modeSmoothness == "sigmoid") {
                    
                    // create sigmoid scalar based on distXY
                    let sigmoidScalar = ((0.85*exp((distXY - 20)/2)) / (exp((distXY - 20)/2) + 1)) + 0.05
                    smoothnessModeScalar = sigmoidScalar
                    
                }
                
                // calculate how much the cursor should move up or down
                dy = -Float(rotX * smoothnessModeScalar)
                
                // calculate how much the cursor should move left or right
                dx = Float(rotY * smoothnessModeScalar)
                
                // update mouseFloat values based on dx and dy
                mouseXFloat += dx
                mouseYFloat += dy
                
                // clamp mouseFloat values
                mouseXFloat = (0.0...Float(NSWidth(NSScreen.screens()![0].frame))).clamp(mouseXFloat)
                mouseYFloat = (0.0...Float(NSHeight(NSScreen.screens()![0].frame))).clamp(mouseYFloat)
                
                // move the cursor
                CGDisplayMoveCursorToPoint(0, CGPoint(x: CGFloat(mouseXFloat), y: CGFloat(mouseYFloat)))
                
                stateMoving = true
                
            } // if (distXY > distXYthreshold)
            
        } // if (modeMouseEnabled)
        
    } // func processARKitOrientationData(_ arkitOrientation: [Float])
    
} // extension SimpleViewController
