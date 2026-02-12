import SwiftUI

/// Reusable section header with title and optional trailing action.
struct SectionHeader: View {
    let title: String
    var trailingText: String?
    var trailingAction: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()

            Spacer()

            if let trailingText, let trailingAction {
                Button(action: trailingAction) {
                    Text(trailingText)
                        .font(.caption)
                        .foregroundStyle(Color.statusInfo)
                }
            }
        }
        .padding(.horizontal, Spacing.xxs)
    }
}
