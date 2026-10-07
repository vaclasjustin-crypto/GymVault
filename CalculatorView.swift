import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject private var store: AppStore
    @State private var mode: CalculatorMode = .mass
    @State private var syringe: SyringeSize = .ml05

    @State private var vialAmount = ""
    @State private var vialUnit: MassUnit = .mg
    @State private var diluentML = ""
    @State private var desiredAmount = ""
    @State private var desiredUnit: MassUnit = .mg

    @State private var vialIU = ""
    @State private var desiredIU = ""

    @State private var concentrationMGML = ""
    @State private var desiredMG = ""

    @State private var result: CalculatorResult?
    @State private var errorMessage: String?
    @State private var entryName = ""
    @State private var savedConfirmation = false

    var body: some View {
        Form {
            Section {
                Picker("Rechner", selection: $mode) {
                    ForEach(CalculatorMode.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Eintrag") {
                TextField("Bezeichnung, z. B. Produktname", text: $entryName)
            }

            Section("Spritze") {
                Picker("Größe", selection: $syringe) {
                    ForEach(SyringeSize.allCases) { size in
                        Text(size.title).tag(size)
                    }
                }
                Text("U-100: ausgewählte Kapazität bis \(Int(syringe.maxU100Units)) Markierungen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            switch mode {
            case .mass:
                massInputs
            case .iu:
                iuInputs
            case .concentration:
                concentrationInputs
            }

            Section {
                Button("Berechnen") { calculate() }
                    .frame(maxWidth: .infinity)
            }

            if let result {
                resultSection(result)
            }

            if savedConfirmation {
                Section {
                    Label("Im Journal gespeichert", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }

            Section("Hinweis") {
                Text("Der Rechner gibt keine Dosierungs-, Zyklus- oder Anwendungsempfehlung. Er rechnet ausschließlich deine eingegebenen Mengen in Konzentration, Volumen und U-100-Markierungen um. Produktetikett und ärztliche Vorgaben haben Vorrang.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Rechner")
        .onChange(of: mode) { _, _ in clearResult() }
        .onChange(of: syringe) { _, _ in clearResult() }
    }

    private var massInputs: some View {
        Group {
            Section("Vial / Fläschchen") {
                HStack {
                    NumericField(title: "Gesamtmenge", text: $vialAmount)
                    Picker("", selection: $vialUnit) {
                        ForEach(MassUnit.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .labelsHidden()
                }
                NumericField(title: "Hinzugefügtes Volumen", text: $diluentML, suffix: "ml")
            }
            Section("Gewünschte Menge") {
                HStack {
                    NumericField(title: "Menge", text: $desiredAmount)
                    Picker("", selection: $desiredUnit) {
                        ForEach(MassUnit.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .labelsHidden()
                }
            }
        }
    }

    private var iuInputs: some View {
        Group {
            Section("Vial / Pen") {
                NumericField(title: "Gesamtinhalt", text: $vialIU, suffix: "IU")
                NumericField(title: "Gesamtvolumen / Verdünnung", text: $diluentML, suffix: "ml")
            }
            Section("Gewünschte Menge") {
                NumericField(title: "Menge", text: $desiredIU, suffix: "IU")
            }
        }
    }

    private var concentrationInputs: some View {
        Group {
            Section("Fertige Konzentration") {
                NumericField(title: "Konzentration", text: $concentrationMGML, suffix: "mg/ml")
            }
            Section("Gewünschte Menge") {
                NumericField(title: "Menge", text: $desiredMG, suffix: "mg")
            }
        }
    }

    @ViewBuilder
    private func resultSection(_ result: CalculatorResult) -> some View {
        Section("Ergebnis") {
            LabeledContent("Konzentration", value: result.concentrationText)
            LabeledContent("Volumen", value: CalculatorEngine.format(result.volumeML, suffix: " ml"))
            LabeledContent("U-100 Markierung", value: CalculatorEngine.format(result.u100Units))
            if let doses = result.dosesPerContainer {
                LabeledContent("Rechnerische Portionen", value: CalculatorEngine.format(doses))
            }
            if !result.fitsSelectedSyringe {
                Label("Das berechnete Volumen überschreitet die Kapazität der ausgewählten Spritze.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            Button("Im Journal speichern") { saveToJournal(result) }
                .disabled(entryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func calculate() {
        do {
            switch mode {
            case .mass:
                guard let vial = vialAmount.normalizedDouble,
                      let diluent = diluentML.normalizedDouble,
                      let desired = desiredAmount.normalizedDouble else { throw CalculatorError.invalidInput }
                result = try CalculatorEngine.mass(vialAmount: vial, vialUnit: vialUnit, diluentML: diluent, desiredAmount: desired, desiredUnit: desiredUnit, syringe: syringe)
            case .iu:
                guard let total = vialIU.normalizedDouble,
                      let diluent = diluentML.normalizedDouble,
                      let desired = desiredIU.normalizedDouble else { throw CalculatorError.invalidInput }
                result = try CalculatorEngine.iu(vialIU: total, diluentML: diluent, desiredIU: desired, syringe: syringe)
            case .concentration:
                guard let concentration = concentrationMGML.normalizedDouble,
                      let desired = desiredMG.normalizedDouble else { throw CalculatorError.invalidInput }
                result = try CalculatorEngine.concentration(concentrationMGML: concentration, desiredMG: desired, syringe: syringe)
            }
            errorMessage = nil
            savedConfirmation = false
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }

    private func clearResult() {
        result = nil
        errorMessage = nil
        savedConfirmation = false
    }

    private func saveToJournal(_ result: CalculatorResult) {
        let amount: Double?
        let unit: String
        switch mode {
        case .mass:
            amount = desiredAmount.normalizedDouble
            unit = desiredUnit.rawValue
        case .iu:
            amount = desiredIU.normalizedDouble
            unit = "IU"
        case .concentration:
            amount = desiredMG.normalizedDouble
            unit = "mg"
        }

        let note = "Rechner: \(CalculatorEngine.format(result.volumeML, suffix: " ml")); U-100: \(CalculatorEngine.format(result.u100Units)); Spritze: \(syringe.title)"
        store.addJournal(JournalEntry(
            substance: entryName.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            unit: unit,
            concentrationText: result.concentrationText,
            notes: note
        ))
        savedConfirmation = true
    }
}
