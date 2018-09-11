import Cocoa

class SimpleViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var rotationXlabel: NSTextField!
    @IBOutlet weak var rotationYlabel: NSTextField!
    @IBOutlet weak var rotationZlabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var iPhoneLabel: NSTextField!
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
    @IBOutlet weak var numPosSamplesLabel: NSTextField!
    @IBOutlet weak var numNegSamplesLabel: NSTextField!
    @IBOutlet weak var predictionLabel: NSTextField!
    @IBOutlet weak var certaintyValueLabel: NSTextField!
    @IBOutlet var activeView: NSView!
    @IBOutlet var tutorialView: NSView!
    @IBOutlet var mlView: NSView!
    
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
    
    // KNNDTW Properties
    let knn_dtw_pucker: KNNDTW = KNNDTW()
    var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
    var loaded_model: [knn_curve_label_pair] = [knn_curve_label_pair]()
    var recentPuckerMeasures: [Float] = []
    var numPuckerMeasures = 12
    var isPredictingPucker = false
    let puckerPredictionThreshold = Float(0.99)
    var numPosSamples = 0
    var numNegSamples = 0
    var markerAdded = false
    var stillnessFactor = Float(0.0)
    var recentOrientations = [[Float]]()
    var numStillnessMeasures = 12
    let stillnessThreshold = Float(0.5)
    
    // Visage Expression Properties
    var visageJawOpenValue = Float(0.0)
    var visageJawOpenThreshold = Float(1.25)
    var visageEyebrowsUpValue = Float(0.0)
    var visageEyebrowsUpThreshold = Float(0.8)
    
    // iPhone Camera Version Properties
    var iPhoneVersion = "Not Detected"
    
    // DEBUG PROPERTIES
    var keyPressed = false
    
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
        
        // Start with mouse movement and mouse click disabled
        modeMouseEnabled = false
        modeClickEnabled = false
        dragEnabled = false
        
        sendDataToUnity("connected")
        
        //switchToActiveView()
        switchView(mlView, activeView)
        
        loadModelData(modelName: "puckerModelData03")

    }
    
}

extension SimpleViewController: PTManagerDelegate {
    
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
            
        } else if type == PTType.visagePuckerArray.rawValue {
            
            // Visage Pucker / Mouse Click Control Function
            
            let visagePucker = data.convert() as! [Float]
            
            processVisagePuckerData(visagePucker)
            
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
                //startCenterCalibration()
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


