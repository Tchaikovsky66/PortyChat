import Foundation

protocol DataProcessor {
    func processReceived(_ data: Data) -> (displayText: String, rawHex: String)
    func processToSend(_ text: String, asHex: Bool) -> Data?
}

class SerialDataProcessor: DataProcessor {
    // 数据统计
    private(set) var receivedBytes: UInt64 = 0
    private(set) var sentBytes: UInt64 = 0
    
    // 数据过滤
    var filterNonPrintable: Bool = true
    var filterNull: Bool = true
    
    func processReceived(_ data: Data) -> (displayText: String, rawHex: String) {
        receivedBytes += UInt64(data.count)
        
        // 生成原始十六进制字符串
        let rawHex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        
        // 处理显示文本
        if filterNonPrintable {
            let filtered = data.filter { char in
                if filterNull && char == 0 { return false }
                return char >= 32 && char < 127 || char == 10 || char == 13
            }
            if let text = String(data: filtered, encoding: .utf8) {
                return (text, rawHex)
            }
        }
        
        // 如果无法转换或不过滤，返回原始十六进制
        return (rawHex, rawHex)
    }
    
    func processToSend(_ text: String, asHex: Bool) -> Data? {
        if asHex {
            // 处理十六进制输入
            let hexString = text.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "0x", with: "")
                .replacingOccurrences(of: ",", with: "")
            
            var data = Data()
            var index = hexString.startIndex
            
            while index < hexString.endIndex {
                let endIndex = hexString.index(index, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
                let byteString = String(hexString[index..<endIndex])
                if let byte = UInt8(byteString, radix: 16) {
                    data.append(byte)
                } else {
                    return nil // 无效的十六进制字符串
                }
                index = endIndex
            }
            
            sentBytes += UInt64(data.count)
            return data
        } else {
            // 处理文本输入
            if let data = text.data(using: .utf8) {
                sentBytes += UInt64(data.count)
                return data
            }
            return nil
        }
    }
    
    func resetStatistics() {
        receivedBytes = 0
        sentBytes = 0
    }
}