import SwiftUI

struct HistoryView: View {
    @StateObject private var serialManager = SerialManager()
    @State private var isEditing = false
    @State private var selectedMessages = Set<UUID>()
    
    var body: some View {
        VStack {
            List(selection: $selectedMessages) {
                ForEach(serialManager.messageHistory) { message in
                    VStack(alignment: .leading) {
                        Text(message.message)
                            .font(.body)
                        Text(message.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !serialManager.messageHistory.isEmpty {
                HStack {
                    Button(isEditing ? "完成" : "编辑") {
                        isEditing.toggle()
                        if !isEditing {
                            selectedMessages.removeAll()
                        }
                    }
                    
                    if isEditing {
                        Button("删除选中") {
                            serialManager.messageHistory.removeAll { message in
                                selectedMessages.contains(message.id)
                            }
                            selectedMessages.removeAll()
                        }
                        .disabled(selectedMessages.isEmpty)
                        
                        Button("全选") {
                            selectedMessages = Set(serialManager.messageHistory.map { $0.id })
                        }
                        .disabled(serialManager.messageHistory.isEmpty)
                        
                        Spacer()
                        
                        Button("清空") {
                            serialManager.messageHistory.removeAll()
                            selectedMessages.removeAll()
                            isEditing = false
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("发送历史")
    }
} 