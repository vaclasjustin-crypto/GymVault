import SwiftUI

struct TrainingView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        List {
            Section {
                ForEach($store.trainingDays) { $day in
                    NavigationLink {
                        TrainingDayView(day: $day)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.name).font(.headline)
                            Text(day.exercises.isEmpty ? "Übungen hinzufügen" : "\(day.exercises.count) Übungen")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } footer: {
                Text("Der Plan ist vollständig editierbar. Trage hier deinen aktuellen Coach-Plan exakt ein.")
            }
        }
        .navigationTitle("Training")
    }
}

struct TrainingDayView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var day: TrainingDay
    @State private var showingAddExercise = false
    @State private var loggingExercise: Exercise?

    var body: some View {
        List {
            Section("Übungen") {
                if day.exercises.isEmpty {
                    Text("Noch keine Übungen hinterlegt.")
                        .foregroundStyle(.secondary)
                }
                ForEach(day.exercises) { exercise in
                    Button {
                        loggingExercise = exercise
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name).foregroundStyle(.primary)
                                Text("\(exercise.targetSets) Sätze · \(exercise.repRange) Wdh.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "plus.circle")
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            store.deleteExercise(dayID: day.id, exerciseID: exercise.id)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }

            Button {
                showingAddExercise = true
            } label: {
                Label("Übung hinzufügen", systemImage: "plus")
            }
        }
        .navigationTitle(day.name)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(dayID: day.id)
        }
        .sheet(item: $loggingExercise) { exercise in
            LogExerciseView(trainingDay: day.name, exercise: exercise)
        }
    }
}

struct AddExerciseView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let dayID: UUID
    @State private var name = ""
    @State private var sets = 3
    @State private var reps = "8–12"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Übung", text: $name)
                Stepper("Sätze: \(sets)", value: $sets, in: 1...10)
                TextField("Wiederholungsbereich", text: $reps)
            }
            .navigationTitle("Neue Übung")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.addExercise(to: dayID, name: name.trimmingCharacters(in: .whitespacesAndNewlines), sets: sets, reps: reps)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct LogExerciseView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let trainingDay: String
    let exercise: Exercise

    @State private var weight = ""
    @State private var reps = ""
    @State private var sets: [LoggedSet] = []
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Satz hinzufügen") {
                    NumericField(title: "Gewicht", text: $weight, suffix: "kg")
                    TextField("Wiederholungen", text: $reps).keyboardType(.numberPad)
                    Button("Satz übernehmen") {
                        if let w = weight.normalizedDouble, let r = Int(reps), w >= 0, r > 0 {
                            sets.append(LoggedSet(weight: w, reps: r))
                            reps = ""
                        }
                    }
                }

                Section("Heute") {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        Text("Satz \(index + 1): \(String(format: "%.1f", set.weight)) kg × \(set.reps)")
                    }
                }

                Section("Notizen") {
                    TextField("Optional", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle(exercise.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.addWorkoutLog(WorkoutLog(trainingDay: trainingDay, exercise: exercise.name, sets: sets, notes: notes))
                        dismiss()
                    }
                    .disabled(sets.isEmpty)
                }
            }
        }
    }
}
