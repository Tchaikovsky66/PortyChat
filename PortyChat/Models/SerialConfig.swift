import ORSSerial
import SwiftUI

struct SerialConfig {
    var baudRate: Int = 9600
    var dataBits: Int = 8
    var stopBits: Int = 1
    var parity: ORSSerialPortParity = .none
    var flowControl: FlowControlType = .none
    var dtr: Bool = false
    var rts: Bool = false
    
    static let defaultBaudRates = [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
    static let dataBitsOptions = [5, 6, 7, 8]
    static let stopBitsOptions = [1, 2]
    
    enum FlowControlType {
        case none
        case hardware
        case software
    }
}