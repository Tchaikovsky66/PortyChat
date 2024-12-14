import SwiftUI

struct PrefixedText: View {
    let prefix: String
    let text: String
    let isNewLine: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if isNewLine {
                Text(prefix)
                    .foregroundColor(.gray)
                    .textSelection(.disabled)
            }
            Text(text)
                .textSelection(.enabled)
        }
    }
}

struct FormattedTextView: View {
    let content: String
    let showPrefix: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !content.isEmpty {
                ForEach(content.split(separator: "\n", omittingEmptySubsequences: false), id: \.self) { line in
                    PrefixedText(
                        prefix: "→ ",
                        text: String(line),
                        isNewLine: showPrefix && !line.isEmpty
                    )
                }
            }
        }
    }
}