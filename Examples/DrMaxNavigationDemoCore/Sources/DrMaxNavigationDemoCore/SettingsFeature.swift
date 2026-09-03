import CasePaths
import DrMaxNavigation
import SwiftUI

// A second, independent "feature package" — same pattern as CounterFeature, only knows about
// SettingsScreen. Presented as a sheet (or full screen cover on iOS) from HomeView.

@CasePathable
public enum SettingsScreen: Hashable {
    case root
    case about
}

@Observable
public final class SettingsCoordinator: Hashable {
    let controller: NavigationController<AppScreen, SettingsScreen>

    var notificationsEnabled = false

    init(controller: NavigationController<AppScreen, SettingsScreen>) {
        self.controller = controller
    }

    func showAbout() {
        controller.navigate(to: .about)
    }

    /// Pops back to the settings root by case, wherever it currently sits in the tree.
    func backToSettingsRoot() {
        controller.popBefore(\.root)
    }

    /// Dismisses the whole feature (and any presentation it was shown in), back to the app root.
    func close() {
        controller.popToRoot()
    }

    public static func == (lhs: SettingsCoordinator, rhs: SettingsCoordinator) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct SettingsScreenView: View {
    let coordinator: SettingsCoordinator
    let screen: SettingsScreen

    var body: some View {
        switch screen {
        case .root: SettingsRootView(coordinator: coordinator)
        case .about: SettingsAboutView(coordinator: coordinator)
        }
    }
}

private struct SettingsRootView: View {
    @Bindable var coordinator: SettingsCoordinator

    var body: some View {
        List {
            Toggle("Notifications", isOn: $coordinator.notificationsEnabled)

            Button("About") { coordinator.showAbout() }

            Button("Close", role: .destructive) { coordinator.close() }
        }
        .navigationTitle("Settings")
    }
}

private struct SettingsAboutView: View {
    let coordinator: SettingsCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("DrMaxNavigation Demo")
            Text("Demonstrates push/sheet/popover/cover styles, plus feature composition via NavigationController.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Back to settings (popBefore(\\.root))") {
                coordinator.backToSettingsRoot()
            }
        }
        .padding()
        .navigationTitle("About")
    }
}
