import Foundation

extension NSData {

    static func dataWithValue<T>(value: T) -> NSData {
        var variableValue = value
        return NSData(bytes: &variableValue, length: MemoryLayout<T>.size)
    }
    

    func convertValueX() -> Int16 {
        var value_x: Int16 = 0
        getBytes(&value_x, range: NSRange(location: 0, length: MemoryLayout<UInt16>.size))
        return value_x
    }
    
    func convertValueY() -> Int16 {
        var value_y: Int16 = 0
        getBytes(&value_y, range: NSRange(location: 2, length: MemoryLayout<UInt16>.size))
        return value_y
    }
    
    func convertValueZ() -> Int16 {
        var value_z: Int16 = 0
        getBytes(&value_z, range: NSRange(location: 4, length: MemoryLayout<UInt16>.size))
        return value_z
    }
}
