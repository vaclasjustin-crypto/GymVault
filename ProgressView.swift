import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingAdd = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if store.progressEntries.compactMap({ $0.weightKg }).count >= 2 {
                    Chart(store.progressEntries.filter { $0.weightKg != nil }) { item in
                        LineMark(
                            x: .value("Datum", item.date),
                            y: .value("Gewicht", item.weightKg ?? 0)
                        )
                        PointMark(
                            x: .value("Datum", item.date),
                            y: .value("Gewicht", item.weightKg ?? 0)
                        )
                    }
                    .frame(height: 220)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                }

                ForEach(store.progressEntries.sorted(by: { $0.date > $1.date })) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                        HStack {
                            if let weight = entry.weightKg { Text(String(format: "%.1f kg", weight)) }
                            if let bf = entry.bodyFatPercent { Text(String(format: "%.1f %% KFA", bf)) }
                            if let waist = entry.waistCm { Text(String(format: "%.1f cm Taille", waist)) }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        if !entry.notes.isEmpty { Text(entry.notes) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding()
        }
        .navigationTitle("Fortschritt")
        .toolbar {
            Button { showingAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showingAdd) { AddProgressView() }
    }
}

struct AddProgressView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var waist = ""
    @State private var arm = ""
    @State private var chest = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                Section("Körper") {
                    NumericField(title: "Gewicht", text: $weight, suffix: "kg")
                    NumericField(title: "KFA", text: $bodyFat, suffix: "%")
                    NumericField(title: "Taille", text: $waist, suffix: "cm")
                    NumericField(title: "Arm", text: $arm, suffix: "cm")
                    NumericField(title: "Brust", text: $chest, suffix: "cm")
                }
                Section("Notizen") { TextField("Optional", text: $notes, axis: .vertical) }
            }
            .navigationTitle("Check-in")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.addProgress(ProgressEntry(
                            date: date,
                            weightKg: weight.normalizedDouble,
                            bodyFatPercent: bodyFat.normalizedDouble,
                            waistCm: waist.normalizedDouble,
                            armCm: arm.normalizedDouble,
                            chestCm: chest.normalizedDouble,
                            notes: notes
                        ))
                        dismiss()
                    }
                }
            }
        }
    }
}
