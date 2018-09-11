
import Cocoa

extension SimpleViewController {
    
    @IBAction func clickStartCalibrationButton(_ sender: NSButton) {
        /*
        // start calibration
        if (calibrationMode == false) {
            print ("start calibration mode button pressed and calibrationMode false, starting calibration")
            sendDataToUnity("startCalibrationButton")
            calibrationMode = true
            switchView(activeView, tutorialView)
            
            //center window in middle of screen
            self.view.window?.center()
        } else if (calibrationMode == true) {
            print ("already in calibration mode")
        }
        */
    }
    
    @IBAction func clickStartTutorialButton(_ sender: NSButton) {
        keyPressed = !keyPressed
        print("key pressed: " + String(keyPressed))
    }
    
    @IBAction func clickAddSamplePosButton(_ sender: NSButton) {
        addSamplePositive()
    }
    
    @IBAction func clickRemoveSamplePosButton(_ sender: NSButton) {
        removeSamplePositive()
    }
    
    @IBAction func clickAddSampleNegButton(_ sender: NSButton) {
        addSampleNegative()
    }
    
    @IBAction func clickRemoveSampleNegButton(_ sender: NSButton) {
        removeSampleNegative()
    }
    
    @IBAction func clickTrainModelButton(_ sender: NSButton) {
        trainModel()
    }
    
    @IBAction func clickSaveModelDataButton(_ sender: NSButton) {
        saveModelData()
    }
    
    @IBAction func clickLoadModelButton(_ sender: NSButton) {
        loadModelData(modelName: "puckerModelData01")
    }
    
    @IBAction func clickStartPredictinglButton(_ sender: NSButton) {
        isPredictingPucker = true
    }
    
    @IBAction func clickAddMarkerButton(_ sender: NSButton) {
        markerAdded = true
    }
    
    @IBAction func clickSwitchToMLView(_ sender: NSButton) {
        switchView(activeView, mlView)
    }
    
    @IBAction func clickSwitchToActiveViewFromMLView(_ sender: NSButton) {
        switchView(mlView, activeView)
    }
    
    @IBAction func mouseEnabledButtonChanged(_ sender: NSButton) {
        if (sender.state == 1) {
            modeMouseEnabled = true
        } else if (sender.state == 0) {
            modeMouseEnabled = false
        }
    }
    
    @IBAction func clickEnabledButtonChanged(_ sender: NSButton) {
        if (sender.state == 1) {
            modeClickEnabled = true
        } else if (sender.state == 0) {
            modeClickEnabled = false
        }
    }
    
    @IBAction func dragEnabledButtonChanged(_ sender: NSButton) {
        if (sender.state == 1) {
            dragEnabled = true
        } else if (sender.state == 0) {
            dragEnabled = false
        }
    }
    
    @IBAction func smoothModeButtonChanged(_ sender: NSPopUpButton) {
        let selectedMode = (sender.titleOfSelectedItem)
        
        if (selectedMode! == "linear") {
            modeSmoothness = "linear"
        } else if (selectedMode! == "quadratic") {
            modeSmoothness = "quadratic"
        } else if (selectedMode! == "cubic") {
            modeSmoothness = "cubic"
        } else if (selectedMode! == "sigmoid") {
            modeSmoothness = "sigmoid"
        } else if (selectedMode! == "float") {
            modeSmoothness = "float"
        }
    }
    
    @IBAction func clickModeButtonChanged(_ sender: NSPopUpButton) {
        let selectedMode = (sender.titleOfSelectedItem)
        
        if (selectedMode! == "pucker") {
            modeClick = "pucker"
            clickThresholdDown = puckerClickDownThreshold
            clickThresholdUp = puckerClickUpThreshold
            
        } else if (selectedMode! == "eyebrows") {
            modeClick = "eyebrows"
            clickThresholdDown = eyebrowClickDownThreshold
            clickThresholdUp = eyebrowClickUpThreshold
        }
        
        // change slider labels and values to match new mode
        let newThresholdDownValueString = String(format:"%.3f", clickThresholdDown)
        let newThresholdUpValueString = String(format:"%.3f", clickThresholdUp)
        self.clickDownThresholdValue.stringValue = "Click Threshold Down: " + newThresholdDownValueString
        self.clickUpThresholdValue.stringValue = "Click Threshold Up: " + newThresholdUpValueString
        self.clickDownThresholdSlider.floatValue = clickThresholdDown
        self.clickUpThresholdSlider.floatValue = clickThresholdUp
        print(modeClick)
    }
    
    @IBAction func clickThresholdSliderChanged(_ sender: NSSliderCell) {
        let thresholdUpOrDown = (sender.tag) // Down = 1, Up = 2
        let newThresholdValue = (sender.floatValue)
        let newThresholdValueString = String(format:"%.3f", newThresholdValue)
        
        if (thresholdUpOrDown == 1) {
            clickThresholdDown = newThresholdValue
            self.clickDownThresholdValue.stringValue = "Click Threshold Down: " + newThresholdValueString
            if (modeClick == "pucker") {
                puckerClickDownThreshold = clickThresholdDown
            } else if (modeClick == "eyebrows") {
                eyebrowClickDownThreshold = clickThresholdDown
            }
        } else if (thresholdUpOrDown == 2) {
            clickThresholdUp = newThresholdValue
            self.clickUpThresholdValue.stringValue = "Click Threshold Up: " + newThresholdValueString
            if (modeClick == "pucker") {
                puckerClickUpThreshold = clickThresholdUp
            } else if (modeClick == "eyebrows") {
                eyebrowClickUpThreshold = clickThresholdUp
            }
        }
    }
    
    func switchView(_ currentView: NSView,_ targetView: NSView) {
        guard targetView.superview == nil else {
            return
        }
        currentView.removeFromSuperview()
        view.addSubview(targetView)
    }
    
}
