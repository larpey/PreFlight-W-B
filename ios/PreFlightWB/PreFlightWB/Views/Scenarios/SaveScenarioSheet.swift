import SwiftUI

/// Modal sheet for saving or naming a scenario.
struct SaveScenarioSheet: View {
    let defaultName: String
    let onSave: (_ name: String, _ notes: String?) -> Void

    @State private var scenarioName: String = ""
    @State private var notes: String = ""
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Maximum allowed characters for the scenario name.
    private let nameMaxLength = 50

    /// Whether the trimmed name is valid (non-empty and within limit).
    private var isNameValid: Bool {
        let trimmed = scenarioName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= nameMaxLength
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // MARK: - Name Field
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Name")
                        .sectionHeaderStyle()

                    HStack {
                        TextField("Scenario Name", text: $scenarioName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isNameFocused)
                            .onChange(of: scenarioName) { _, newValue in
                                if newValue.count > nameMaxLength {
                                    scenarioName = String(newValue.prefix(nameMaxLength))
                                }
                            }

                        Text("\(scenarioName.count)/\(nameMaxLength)")
                            .font(.caption)
                            .foregroundStyle(Color.pfTextSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.pfSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }

                // MARK: - Notes Field
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Notes")
                        .sectionHeaderStyle()

                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.pfSurface)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .background(.ultraThinMaterial)
            .navigationTitle("Save Scenario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Haptic.success()
                        onSave(
                            scenarioName.trimmingCharacters(in: .whitespacesAndNewlines),
                            notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                    .fontWeight(.semibold)
                    .tint(Color.statusInfo)
                    .disabled(!isNameValid)
                    .opacity(isNameValid ? 1.0 : 0.4)
                }
            }
            .onAppear {
                scenarioName = defaultName
                isNameFocused = true
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SaveScenarioSheet(defaultName: "Standard Pax") { name, notes in
        print("Saved: \(name), notes: \(notes ?? "none")")
    }
}
