import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingAdd = false

    var body: some View {
        List {
            Section {
                ForEach(store.journalEntries) { entry in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(entry.substance).font(.headline)
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let amount = entry.amount {
                            Text("\(CalculatorEngine.format(amount)) \(entry.unit)")
                                .font(.subheadline)
                        }
                        if !entry.concentrationText.isEmpty {
                            Text(entry.concentrationText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !entry.notes.isEmpty { Text(entry.notes).font(.subheadline) }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    store.journalEntries.remove(atOffsets: offsets)
                }
            } footer: {
                Text("Privates Protokoll deiner eigenen Angaben. Die App schlägt keine Dosierung oder Frequenz vor.")
            }
        }
        .navigationTitle("Journal")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) { AddJournalEntryView() }
    }
}

struct AddJournalEntryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var substance = ""
    @State private var amount = ""
    @State private var unit = "mg"
    @State private var concentration = ""
    @State private var notes = ""

    private let units = ["mg", "mcg", "IU", "ml", "Einheiten"]

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Datum & Uhrzeit", selection: $date)
                TextField("Bezeichnung", text: $substance)
                HStack {
                    NumericField(title: "Menge", text: $amount)
                    Picker("Einheit", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                }
                TextField("Konzentration / Produktinfo", text: $concentration)
                TextField("Notizen", text: $notes, axis: .vertical)
            }
            .navigationTitle("Eintrag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.addJournal(JournalEntry(date: date, substance: substance, amount: amount.normalizedDouble, unit: unit, concentrationText: concentration, notes: notes))
                        dismiss()
                    }
                    .disabled(substance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
