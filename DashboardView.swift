import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    private var latestWeight: Double? {
        store.progressEntries.last(where: { $0.weightKg != nil })?.weightKg
    }

    private var latestProgressDate: Date? {
        store.progressEntries.last?.date
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GYM VAULT")
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(.secondary)
                    Text("Dein Training. Deine Daten.")
                        .font(.largeTitle.bold())
                }

                HStack(spacing: 12) {
                    StatCard(
                        title: "Aktuelles Gewicht",
                        value: latestWeight.map { String(format: "%.1f kg", $0) } ?? "—",
                        systemImage: "scalemass.fill"
                    )
                    StatCard(
                        title: "Schrittziel",
                        value: "\(store.dailyStepTarget)",
                        systemImage: "figure.walk"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Training Split").font(.headline)
                    ForEach(store.trainingDays) { day in
                        HStack {
                            Text(day.name).fontWeight(.semibold)
                            Spacer()
                            Text("\(day.exercises.count) Übungen")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Letztes Update").font(.headline)
                    Text(latestProgressDate?.formatted(date: .abbreviated, time: .omitted) ?? "Noch kein Fortschrittseintrag")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            }
            .padding()
        }
        .navigationTitle("Heute")
    }
}
