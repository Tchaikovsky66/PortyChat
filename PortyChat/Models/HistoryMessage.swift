import Foundation

struct HistoryMessage: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
}