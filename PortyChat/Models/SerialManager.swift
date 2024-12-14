import Foundation
import ORSSerial
import AppKit

class SerialManager: NSObject, ObservableObject, ORSSerialPortDelegate {
    @Published var availablePorts: [ORSSerialPort] = [] {
        didSet {
            if let selectedPort = selectedPort, !availablePorts.contains(selectedPort) {
                self.selectedPort = nil
            }
        }
    }
    @Published var selectedPort: ORSSerialPort? {
        willSet {
            if isConnected {
                disconnect()
            }
        }
        didSet {
            if let oldPort = oldValue {
                oldPort.delegate = nil
                if oldPort.isOpen {
                    oldPort.close()
                }
            }
            
            if let newPort = selectedPort {
                newPort.delegate = self
                configurePort(newPort)
            }
            
            objectWillChange.send()
        }
    }
    @Published var isConnected = false
    @Published var receivedData = ""
    @Published var rawReceivedData = ""
    @Published var messageHistory: [HistoryMessage] = []
    @Published var errorMessage: String?
    @Published var currentBaudRate: Int = 9600 {
        didSet {
            if let port = selectedPort, isConnected {
                updateBaudRate(port)
            }
        }
    }
    
    @Published var isHexMode = false {
        didSet {
            if let port = selectedPort {
                configurePort(port)
            }
        }
    }
    
    @Published var autoNewLine = true
    
    private let portManager = ORSSerialPortManager.shared()
    
    override init() {
        super.init()
        updateAvailablePorts()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.ORSSerialPortsWereConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvailablePorts()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.ORSSerialPortsWereDisconnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvailablePorts()
        }
    }
    
    func updateAvailablePorts() {
        DispatchQueue.main.async { [weak self] in
            self?.availablePorts = self?.portManager.availablePorts ?? []
        }
    }
    
    func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connect()
        }
    }
    
    func sendData(_ string: String, asHex: Bool = false) {
        guard let port = selectedPort, isConnected else {
            print("无法发送：串口未连接")
            return
        }
        
        let dataToSend: Data
        if asHex {
            let hexString = string.replacingOccurrences(of: " ", with: "")
            var data = Data()
            var index = hexString.startIndex
            while index < hexString.endIndex {
                let nextIndex = hexString.index(index, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
                let byteString = String(hexString[index..<nextIndex])
                if let byte = UInt8(byteString, radix: 16) {
                    data.append(byte)
                }
                index = nextIndex
            }
            dataToSend = data
            print("发送十六进制数据: \(data.map { String(format: "%02X", $0) }.joined(separator: " "))")
        } else {
            dataToSend = string.data(using: .utf8) ?? Data()
            print("发送文本数据: \(string)")
        }
        
        print("发送 \(dataToSend.count) 字节")
        port.send(dataToSend)
        addToHistory(string)
    }
    
    private func connect() {
        guard let port = selectedPort else { return }
        
        if !checkPortPermission(port) {
            requestPortPermission(port)
            return
        }
        
        if port.isOpen {
            print("串口已经打开，先关闭")
            port.close()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        configurePort(port)
        
        print("尝试打开串口...")
        port.open()
        
        if port.isOpen {
            print("串口成功打开")
        } else {
            print("串口打开失败")
            errorMessage = "串口打开失败，请检查设备连接"
        }
    }
    
    private func checkPortPermission(_ port: ORSSerialPort) -> Bool {
        let path = port.path
        return FileManager.default.isWritableFile(atPath: path)
    }
    
    private func requestPortPermission(_ port: ORSSerialPort) {
        DispatchQueue.main.async {
            self.errorMessage = "需要获取串口权限。请在系统偏好设置中允许应用访问串口设备。"
            
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func disconnect() {
        guard let port = selectedPort, port.isOpen else { return }
        port.close()
    }
    
    // MARK: - ORSSerialPortDelegate
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        print("收到数据: \(data.count) 字节")
        print("原始数据: \(data.map { String(format: "%02X", $0) }.joined(separator: " "))")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            self.rawReceivedData += hexString + (self.autoNewLine ? "\n" : " ")
            
            if self.isHexMode {
                self.receivedData += hexString + (self.autoNewLine ? "\n" : " ")
            } else {
                if let string = String(data: data, encoding: .utf8) {
                    self.receivedData += string
                } else {
                    self.receivedData += "<" + hexString + ">" + (self.autoNewLine ? "\n" : "")
                }
            }
        }
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("串口已打开: \(serialPort.path)")
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        print("串口已关闭: \(serialPort.path)")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        DispatchQueue.main.async {
            if let posixError = error as? POSIXError {
                switch posixError.code {
                case .EBADF:
                    return
                case .EPERM:
                    self.errorMessage = "无法访问串口设备，请检查权限设置"
                    self.requestPortPermission(serialPort)
                default:
                    self.errorMessage = error.localizedDescription
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
            
            self.isConnected = false
            serialPort.close()
        }
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        DispatchQueue.main.async {
            self.updateAvailablePorts()
            if serialPort == self.selectedPort {
                self.selectedPort = nil
                self.isConnected = false
            }
        }
    }
    
    func addToHistory(_ message: String) {
        let historyMessage = HistoryMessage(message: message, timestamp: Date())
        messageHistory.append(historyMessage)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let port = selectedPort, port.isOpen {
            port.close()
        }
    }
    
    func cleanup() {
        receivedData = ""
        rawReceivedData = ""
        messageHistory.removeAll()
        
        if isConnected {
            disconnect()
        }
    }
    
    private func configurePort(_ port: ORSSerialPort) {
        print("配置串口: \(port.path)")
        print("波特率: \(currentBaudRate)")
        
        let wasOpen = port.isOpen
        
        if wasOpen && (port.baudRate.intValue != currentBaudRate) {
            port.close()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        port.baudRate = NSNumber(value: currentBaudRate)
        port.numberOfStopBits = 1
        port.parity = .none
        port.shouldEchoReceivedData = false
        
        port.dtr = false
        port.rts = false
        
        port.usesDTRDSRFlowControl = false
        port.usesRTSCTSFlowControl = false
        
        if wasOpen && !port.isOpen {
            port.open()
        }
        
        print("当前配置:")
        print("- 波特率: \(port.baudRate)")
        print("- 停止位: \(port.numberOfStopBits)")
        print("- 校验位: \(port.parity.rawValue)")
        print("- RTS: \(port.rts)")
        print("- DTR: \(port.dtr)")
    }
    
    private func updateBaudRate(_ port: ORSSerialPort) {
        port.baudRate = NSNumber(value: currentBaudRate)
        
        if port.baudRate.intValue != currentBaudRate {
            print("波特率更新失败，尝试重新连接")
            
            port.close()
            Thread.sleep(forTimeInterval: 0.1)
            
            configurePort(port)
            port.open()
            
            if !port.isOpen {
                self.errorMessage = "更改波特率后重新连接失败，请手动重新连接"
            }
        } else {
            print("波特率更新成功：\(currentBaudRate)")
        }
    }
}