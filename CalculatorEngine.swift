import Foundation

enum CalculatorError: LocalizedError, Equatable {
    case invalidInput
    case doseExceedsContainer

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Bitte nur Werte größer als 0 eingeben."
        case .doseExceedsContainer:
            return "Die gewünschte Menge ist größer als der Gesamtinhalt."
        }
    }
}

enum CalculatorEngine {
    static func mass(
        vialAmount: Double,
        vialUnit: MassUnit,
        diluentML: Double,
        desiredAmount: Double,
        desiredUnit: MassUnit,
        syringe: SyringeSize
    ) throws -> CalculatorResult {
        guard vialAmount > 0, diluentML > 0, desiredAmount > 0 else { throw CalculatorError.invalidInput }

        let vialMG = vialUnit == .mg ? vialAmount : vialAmount / 1000.0
        let desiredMG = desiredUnit == .mg ? desiredAmount : desiredAmount / 1000.0
        guard desiredMG <= vialMG else { throw CalculatorError.doseExceedsContainer }

        let concentrationMGML = vialMG / diluentML
        let volumeML = desiredMG / concentrationMGML
        let units = volumeML * 100.0
        let doses = vialMG / desiredMG

        return CalculatorResult(
            concentrationText: format(concentrationMGML, suffix: " mg/ml"),
            volumeML: volumeML,
            u100Units: units,
            dosesPerContainer: doses,
            fitsSelectedSyringe: volumeML <= syringe.rawValue
        )
    }

    static func iu(
        vialIU: Double,
        diluentML: Double,
        desiredIU: Double,
        syringe: SyringeSize
    ) throws -> CalculatorResult {
        guard vialIU > 0, diluentML > 0, desiredIU > 0 else { throw CalculatorError.invalidInput }
        guard desiredIU <= vialIU else { throw CalculatorError.doseExceedsContainer }

        let concentrationIUML = vialIU / diluentML
        let volumeML = desiredIU / concentrationIUML
        let units = volumeML * 100.0
        let doses = vialIU / desiredIU

        return CalculatorResult(
            concentrationText: format(concentrationIUML, suffix: " IU/ml"),
            volumeML: volumeML,
            u100Units: units,
            dosesPerContainer: doses,
            fitsSelectedSyringe: volumeML <= syringe.rawValue
        )
    }

    static func concentration(
        concentrationMGML: Double,
        desiredMG: Double,
        syringe: SyringeSize
    ) throws -> CalculatorResult {
        guard concentrationMGML > 0, desiredMG > 0 else { throw CalculatorError.invalidInput }
        let volumeML = desiredMG / concentrationMGML
        let units = volumeML * 100.0

        return CalculatorResult(
            concentrationText: format(concentrationMGML, suffix: " mg/ml"),
            volumeML: volumeML,
            u100Units: units,
            dosesPerContainer: nil,
            fitsSelectedSyringe: volumeML <= syringe.rawValue
        )
    }

    static func format(_ value: Double, suffix: String = "") -> String {
        let absValue = abs(value)
        let decimals: Int
        if absValue >= 100 { decimals = 1 }
        else if absValue >= 10 { decimals = 2 }
        else { decimals = 3 }
        return String(format: "%.*f%@", decimals, value, suffix)
    }
}
