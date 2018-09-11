import Cocoa

extension SimpleViewController {
    
    func sendDataToUnity(_ message: String) {
        if ptManager.isConnected {
            ptManager.sendObject(object: message, type: PTType.unityMessage.rawValue)
        }
    }
    
    func sendScreenDimensionsToUnity() {
        
        // Get the screen dimensions
        let w = Int(NSWidth(NSScreen.screens()![0].frame))
        let h = Int(NSHeight(NSScreen.screens()![0].frame))
        let dimensions = [w, h]
        
        // Send screen dimensions to Unity
        if ptManager.isConnected {
            ptManager.sendObject(object: dimensions, type: PTType.unityDimensions.rawValue)
        }
    }
    
}
