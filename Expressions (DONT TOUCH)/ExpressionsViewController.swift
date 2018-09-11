//
//  ExpressionsViewController.swift
//  Expressions
//
//  Created by Elliott Spelman on 5/3/18.
//

import Cocoa

class ExpressionsViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var rotationXlabel: NSTextField!
    @IBOutlet weak var rotationYlabel: NSTextField!
    @IBOutlet weak var rotationZlabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var mouthPuckerLabel: NSTextField!
    @IBOutlet weak var jawOpenLabel: NSTextField!
    @IBOutlet weak var eyebrowsUpLabel: NSTextField!
    @IBOutlet weak var mouseEnabledMode: NSButton!
    @IBOutlet weak var clickEnabledMode: NSButton!
    @IBOutlet weak var floatPositionMode: NSButton!
    @IBOutlet weak var clickDownThresholdValue: NSTextField!
    @IBOutlet weak var clickUpThresholdValue: NSTextField!
    @IBOutlet weak var clickDownThresholdSlider: NSSliderCell!
    @IBOutlet weak var clickUpThresholdSlider: NSSliderCell!
    @IBOutlet weak var startCalibrationButton: NSButton!
    @IBOutlet weak var startTutorialButton: NSButton!
    @IBOutlet var activeView: NSView!
    @IBOutlet var tutorialView: NSView!
    
    // PTSimple Properties
    let ptManager = PTManager.instance
    var panel = NSOpenPanel()
    
    // ARStick Properties
    var mouseIsDown = false
    var eyebrowsUp = false
    
    // ARStick Timer Properties
    var denoiseTimerPeriod = Double(1.0)
    var clickDenoiseTimer = Timer()
    var denoiseTimerIsActive = false
    var dragTimerPeriod = Double(0.01)
    var dragTimer = Timer()
    var dragTimerIsActive = false
    var headGestureTimer = Timer()
    var headGestureTimerIsActive = false
    var headGestureTimerPeriod = Double(1.5)
    var headPositionRunningAverageTimer = Timer()
    var headPositionRunningAverageTimerIsActive = false
    var headPositionRunningAverageTimerPeriod = Double(0.05)
    var headPositionCalibrationTimer = Timer()
    var headPositionCalibrationTimerIsActive = false
    var headPositionCalibrationTimerPeriod = Double(5)
    
    // FPS Properties
    var lastUpdateTime: CFTimeInterval = 0
    var frameCounter = 0;
    var startTime: CFTimeInterval = 0
    
    // ARStick Threshold Values
    var clickThresholdDown = Float(0.70)
    var clickThresholdUp = Float(0.50)
    var puckerClickDownThreshold = Float(0.70)
    var puckerClickUpThreshold = Float(0.50)
    var eyebrowClickDownThreshold = Float(0.80)
    var eyebrowClickUpThreshold = Float(0.60)
    var stateMoving = false // this state is used to set the distXYthreshold - it should be smaller if you're already moving
    var distXYthreshold = Float(5)
    
    // ARStick Modes
    var dragEnabled = true // boolean of whether click and drag is turned on or not
    var modeMouseEnabled = true // boolean of whether face orientation can control the mouse position
    var modeClickEnabled = true // boolean of whether facial expression can control the mouse click
    var modeSmoothness = "sigmoid" // what algorithm converts the face orientation into mouse position
    var modeClick = "pucker" // what expression the user uses as the main click
    
    // Floating Point Mouse Position Properties
    var mouseFloatReset = true
    var mouseXFloat = Float(0.0)
    var mouseYFloat = Float(0.0)
    
    // Head Shake And Nod Gesture Properties
    var headLR: [Int] = []
    var headUD: [Int] = []
    var headShake: [Bool] = []
    var headNod: [Bool] = []
    var headGestureBufferLength = 240 // average fps = 240
    var headGestureMiddleZone = Float(1.5)
    
    // Head Position Running Average & Estimated Center Properties
    var estimatedCenterRotationH = Float(0)
    var estimatedCenterRotationV = Float(0)
    var headPositionCenterSamples = [[Float]]()
    var headPositionCenterSamplesBufferLength = 255
    var headCenterEstimationMode = "mean"
    var isCalibratingCenter = false
    var calibrationMode = false
    
    //**  INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        // Setup file chooser
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = NSImage.imageTypes()
        
        // Initialize mouseIsDown as false
        mouseIsDown = false
        denoiseTimerIsActive = false
        
        // Set the click thresholds to be correct based on the current click mode
        if (modeClick == "pucker") {
            clickThresholdDown = puckerClickDownThreshold
            clickThresholdUp = puckerClickUpThreshold
        } else if (modeClick == "eyebrows") {
            clickThresholdDown = eyebrowClickDownThreshold
            clickThresholdUp = eyebrowClickUpThreshold
        }
        
        sendDataToUnity("connected")
        
        switchToActiveView()
        
        
    }
    
}

extension ExpressionsViewController: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
        
        if type == PTType.visageOrientationArray.rawValue {
            
            // Visage Orientation / Mouse Position Control Function
            
            let visageOrientation = data.convert() as! [Float]
            
            processVisageOrientationData(visageOrientation)
            
        } else if type == PTType.visageExpressionArray.rawValue {
            
            // Visage Expression / Mouse Click Control Function
            
            let visageExpressions = data.convert() as! [Float]
            
            processVisageExpressionData(visageExpressions)
            
        } else if type == PTType.arkitOrientationArray.rawValue {
            
            // ARKit Orientation / Mouse Position Control Function
            
            let arkitOrientation = data.convert() as! [Float]
            
            processARKitOrientationData(arkitOrientation)
            
        } else if type == PTType.arkitExpressionArray.rawValue {
            
            // ARKit Expression / Mouse Click Control Function
            
            let arkitExpressions = data.convert() as! [Float]
            
            processARKitExpressionData(arkitExpressions)
        } else if type == PTType.PTSimpleMessage.rawValue {
            
            let ptSimpleMessage = data.convert() as! String
            
            if (ptSimpleMessage == "centerCalibration") {
                print("DID RECEIVE CALIBRATION CONTROLLER MESSAGE")
                startCenterCalibration()
            }
            
            if (ptSimpleMessage == "calibrationError") {
                print("CALIBRATION ERROR: face not detected or phone not connected")
            }
        }
        
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        self.statusLabel.stringValue = connected ? "Connected" : "Disconnected"
        
        if (connected) {
            sendDataToUnity("connected")
        }
    }
    
} //extension SimpleViewController



