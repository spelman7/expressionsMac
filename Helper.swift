import Foundation

let PORT_NUMBER = 4986

extension String {
    
    /** A representation of the string in DispatchData form */
    var dispatchData: DispatchData {
        let data = self.data(using: .utf8)!
        let dispatchData = data.withUnsafeBytes {
            DispatchData(bytes: UnsafeBufferPointer(start: $0, count: data.count))
        }
        
        return dispatchData
    }
    
}

extension DispatchData {
    
    /** Converts DispatchData back into a String format */
    func toString() -> String {
        return String(bytes: self, encoding: .utf8)!
    }

    /** Converts DispatchData back into a Dictionary format */
    func toDictionary() -> NSDictionary {
        return NSDictionary.init(contentsOfDispatchData: self as __DispatchData)
    }
    
}

/** The different types of data to be used with Peertalk */
enum PTType: UInt32 {
    case number = 100
    case image = 101
    case positionX = 102
    case positionY = 103
    case faceRotationArray = 104
    case buttonClick = 105
    case blendshapeArray = 106
    case unityMessage = 107
    case visageOrientationArray = 108
    case visageExpressionArray = 109
    case visagePuckerArray = 110
    case arkitOrientationArray = 111
    case arkitExpressionArray = 112
    case unityDimensions = 113
    case PTSimpleMessage = 114
    
}
