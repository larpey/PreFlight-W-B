import SwiftUI

/// Modal sheet for saving or naming a scenario.
/// Styled as a cockpit instrument panel with dark surfaces and glowing readouts.
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
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.cockpitLabel)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    HStack {
                        TextField("Scenario Name", text: $scenarioName)
                            .foregroundStyle(Color.readoutWhite)
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
                            .foregroundStyle(Color.cockpitLabel)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.cockpitSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .strokeBorder(Color.cockpitBezel, lineWidth: 1)
                    )
                }

                // MARK: - Notes Field
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Notes")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.cockpitLabel)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .foregroundStyle(Color.readoutWhite)
                        .lineLimit(3...6)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.cockpitSurface)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .strokeBorder(Color.cockpitBezel, lineWidth: 1)
                        )
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .background(Color.cockpitBackground)
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
                    .tint(Color.readoutBlue)
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
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SaveScenarioSheet(defaultName: "Standard Pax") { name, notes in
        print("Saved: \(name), notes: \(notes ?? "none")")
    }
}
