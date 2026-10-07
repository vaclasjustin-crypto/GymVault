import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct NumericField: View {
    let title: String
    @Binding var text: String
    var suffix: String = ""

    var body: some View {
        HStack {
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
            if !suffix.isEmpty {
                Text(suffix).foregroundStyle(.secondary)
            }
        }
    }
}

extension String {
    var normalizedDouble: Double? {
        Double(replacingOccurrences(of: ",", with: "."))
    }
}
