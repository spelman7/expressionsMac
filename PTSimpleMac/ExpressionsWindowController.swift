import AppKit

class ExpressionsWindowController : NSWindowController {
    
    private var mouseOver: Bool = false
    
    private var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    override func windowDidLoad() {
        
        panel.isFloatingPanel = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ExpressionsWindowController.didBecomeActive), name: NSNotification.Name.NSApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExpressionsWindowController.willResignActive), name: NSNotification.Name.NSApplicationWillResignActive, object: nil)
        
        setFloatOverFullScreenApps()
    }
    
    private func setFloatOverFullScreenApps() {
        /*
        if NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) {
            panel.collectionBehavior = [.MoveToActiveSpace, .FullScreenAuxiliary]
            
        } else {
            panel.collectionBehavior = [.CanJoinAllSpaces, .FullScreenAuxiliary]
        }
        */
        
        //panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    @objc private func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    @objc private func willResignActive() {
        //panel.ignoresMouseEvents = true
    }
    
}
