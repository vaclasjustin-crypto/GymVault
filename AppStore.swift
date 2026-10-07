import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var trainingDays: [TrainingDay] { didSet { save(trainingDays, key: Keys.trainingDays) } }
    @Published var workoutLogs: [WorkoutLog] { didSet { save(workoutLogs, key: Keys.workoutLogs) } }
    @Published var progressEntries: [ProgressEntry] { didSet { save(progressEntries, key: Keys.progressEntries) } }
    @Published var journalEntries: [JournalEntry] { didSet { save(journalEntries, key: Keys.journalEntries) } }
    @Published var dailyStepTarget: Int { didSet { UserDefaults.standard.set(dailyStepTarget, forKey: Keys.stepTarget) } }

    private enum Keys {
        static let trainingDays = "gymvault.trainingDays"
        static let workoutLogs = "gymvault.workoutLogs"
        static let progressEntries = "gymvault.progressEntries"
        static let journalEntries = "gymvault.journalEntries"
        static let stepTarget = "gymvault.stepTarget"
    }

    init() {
        trainingDays = Self.load([TrainingDay].self, key: Keys.trainingDays) ?? Self.defaultPlan
        workoutLogs = Self.load([WorkoutLog].self, key: Keys.workoutLogs) ?? []
        progressEntries = Self.load([ProgressEntry].self, key: Keys.progressEntries) ?? []
        journalEntries = Self.load([JournalEntry].self, key: Keys.journalEntries) ?? []
        let savedTarget = UserDefaults.standard.integer(forKey: Keys.stepTarget)
        dailyStepTarget = savedTarget > 0 ? savedTarget : 10_000
    }

    func addExercise(to dayID: UUID, name: String, sets: Int, reps: String) {
        guard let index = trainingDays.firstIndex(where: { $0.id == dayID }) else { return }
        trainingDays[index].exercises.append(Exercise(name: name, targetSets: sets, repRange: reps))
    }

    func deleteExercise(dayID: UUID, exerciseID: UUID) {
        guard let index = trainingDays.firstIndex(where: { $0.id == dayID }) else { return }
        trainingDays[index].exercises.removeAll { $0.id == exerciseID }
    }

    func addWorkoutLog(_ log: WorkoutLog) {
        workoutLogs.insert(log, at: 0)
    }

    func addProgress(_ entry: ProgressEntry) {
        progressEntries.append(entry)
        progressEntries.sort { $0.date < $1.date }
    }

    func addJournal(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    static let defaultPlan: [TrainingDay] = [
        TrainingDay(name: "Pull", exercises: []),
        TrainingDay(name: "Legs", exercises: []),
        TrainingDay(name: "Push", exercises: []),
        TrainingDay(name: "Arms & Shoulders", exercises: [])
    ]
}
