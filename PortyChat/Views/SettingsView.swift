import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("通用设置")) {
                Text("设置项待定")
            }
            
            Section(header: Text("关于")) {
                Text("PortyChat")
                Text("版本 1.0.0")
            }
        }
        .navigationTitle("设置")
    }
} 