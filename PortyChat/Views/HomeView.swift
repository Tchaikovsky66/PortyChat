import SwiftUI
import ORSSerial

struct HomeView: View {
    @StateObject private var serialManager = SerialManager()
    @State private var inputText = ""
    @State private var isHexMode = false
    @State private var showingErrorAlert = false
    @State private var selectedPortIndex: Int = -1
    @State private var autoScroll = true
    @State private var showSettings = true
    
    let baudRates = [9600, 19200, 38400, 57600, 115200]
    
    var settingsBar: some View {
        HStack {
            Button(action: {
                serialManager.updateAvailablePorts()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            
            Picker("串口", selection: $selectedPortIndex) {
                Text("请选择串口").tag(-1)
                ForEach(Array(serialManager.availablePorts.enumerated()), id: \.element) { index, port in
                    Text(port.name).tag(index)
                }
            }
            .frame(width: 200)
            .labelsHidden()
            .onChange(of: selectedPortIndex) { oldValue, newValue in
                if newValue == -1 {
                    serialManager.selectedPort = nil
                } else if newValue < serialManager.availablePorts.count {
                    serialManager.selectedPort = serialManager.availablePorts[newValue]
                }
            }
            
            Picker("波特率", selection: $serialManager.currentBaudRate) {
                ForEach(baudRates, id: \.self) { rate in
                    Text("\(rate)").tag(rate)
                }
            }
            .frame(width: 120)
            .labelsHidden()
            
            Toggle("HEX", isOn: $isHexMode)
                .toggleStyle(.switch)
            
            Button(serialManager.isConnected ? "断开" : "连接") {
                serialManager.toggleConnection()
            }
            .disabled(serialManager.selectedPort == nil)
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(height: 50)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    var receiveArea: some View {
        VStack(spacing: 0) {
            // 控制按钮区域 - 固定高度
            HStack {
                Text("接收区域")
                Spacer(minLength: 0)
                Toggle("自动滚动", isOn: $autoScroll)
                    .toggleStyle(.switch)
                
                Toggle("自动换行", isOn: $serialManager.autoNewLine)
                    .toggleStyle(.switch)
                    .opacity(isHexMode ? 1 : 0)
                    .frame(width: isHexMode ? nil : 0)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                
                Button("清除") {
                    serialManager.receivedData = ""
                    serialManager.rawReceivedData = ""
                }
            }
            .animation(.easeInOut, value: isHexMode)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 36)
            .background(Color(NSColor.windowBackgroundColor))
            
            // 文本区域
            HStack(spacing: 10) {
                GroupBox(label: Text("解析数据")) {
                    ScrollView {
                        ScrollViewReader { proxy in
                            FormattedTextView(
                                content: serialManager.receivedData,
                                showPrefix: isHexMode && serialManager.autoNewLine && serialManager.isHexMode
                            )
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("bottom1")
                            .onChange(of: serialManager.receivedData) { oldValue, newValue in
                                if autoScroll {
                                    withAnimation {
                                        proxy.scrollTo("bottom1", anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .border(Color.gray.opacity(0.2))
                }
                .frame(maxWidth: isHexMode ? .infinity : nil)
                
                if isHexMode {
                    GroupBox(label: Text("原始数据 (HEX)")) {
                        ScrollView {
                            ScrollViewReader { proxy in
                                FormattedTextView(
                                    content: serialManager.rawReceivedData,
                                    showPrefix: serialManager.autoNewLine && !serialManager.rawReceivedData.isEmpty
                                )
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("bottom2")
                                .onChange(of: serialManager.rawReceivedData) { oldValue, newValue in
                                    if autoScroll {
                                        withAnimation {
                                            proxy.scrollTo("bottom2", anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .border(Color.gray.opacity(0.2))
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: isHexMode)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    var sendArea: some View {
        VStack(spacing: 0) {
            // 控制按钮区域 - 固定高度
            HStack {
                Text("发送区域")
                Spacer(minLength: 0)
                Button("发送") {
                    serialManager.sendData(inputText, asHex: isHexMode)
                }
                .disabled(serialManager.selectedPort == nil || !serialManager.isConnected)
                .buttonStyle(SendButtonStyle(isEnabled: serialManager.selectedPort != nil && serialManager.isConnected))
                
                Button("清除") {
                    inputText = ""
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 36)
            .background(Color(NSColor.windowBackgroundColor))
            
            // 文本区域 - 固定高度
            GroupBox {
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .background(Color(NSColor.textBackgroundColor))
                    .frame(height: 50)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(height: 110)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            settingsBar
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    receiveArea
                        .frame(height: geometry.size.height - 110)
                    sendArea
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .alert("错误", isPresented: .constant(serialManager.errorMessage != nil)) {
            Button("确定") {
                serialManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = serialManager.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct SendButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(6)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif