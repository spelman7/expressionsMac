import Foundation

func getTimestampMillis() -> Int {
    let currentDate = Date()
    let since1970 = Int(currentDate.timeIntervalSince1970 * 1000)
    
    return since1970
}
