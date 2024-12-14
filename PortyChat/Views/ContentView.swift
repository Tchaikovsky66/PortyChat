import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("串口", systemImage: "cable.connector")
                }
            
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }
} 