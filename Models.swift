import Foundation

struct TrainingDay: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var exercises: [Exercise]
}

struct Exercise: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var targetSets: Int
    var repRange: String
}

struct WorkoutLog: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date = .now
    var trainingDay: String
    var exercise: String
    var sets: [LoggedSet]
    var notes: String = ""
}

struct LoggedSet: Identifiable, Codable, Hashable {
    var id = UUID()
    var weight: Double
    var reps: Int
}

struct ProgressEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date = .now
    var weightKg: Double?
    var bodyFatPercent: Double?
    var waistCm: Double?
    var armCm: Double?
    var chestCm: Double?
    var notes: String = ""
}

struct JournalEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date = .now
    var substance: String
    var amount: Double?
    var unit: String
    var concentrationText: String = ""
    var notes: String = ""
}

enum CalculatorMode: String, CaseIterable, Identifiable {
    case mass = "mg / mcg"
    case iu = "IU"
    case concentration = "mg/ml"

    var id: String { rawValue }
}

enum MassUnit: String, CaseIterable, Identifiable {
    case mg = "mg"
    case mcg = "mcg"

    var id: String { rawValue }
}

enum SyringeSize: Double, CaseIterable, Identifiable {
    case ml03 = 0.3
    case ml05 = 0.5
    case ml10 = 1.0

    var id: Double { rawValue }
    var title: String { String(format: "%.1f ml", rawValue) }
    var maxU100Units: Double { rawValue * 100 }
}

struct CalculatorResult: Equatable {
    let concentrationText: String
    let volumeML: Double
    let u100Units: Double
    let dosesPerContainer: Double?
    let fitsSelectedSyringe: Bool
}
