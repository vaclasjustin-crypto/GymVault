import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Heute", systemImage: "house.fill") }

            NavigationStack { TrainingView() }
                .tabItem { Label("Training", systemImage: "dumbbell.fill") }

            NavigationStack { ProgressView() }
                .tabItem { Label("Fortschritt", systemImage: "chart.line.uptrend.xyaxis") }

            NavigationStack { CalculatorView() }
                .tabItem { Label("Rechner", systemImage: "function") }

            NavigationStack { JournalView() }
                .tabItem { Label("Journal", systemImage: "list.clipboard.fill") }
        }
        .tint(.white)
    }
}
