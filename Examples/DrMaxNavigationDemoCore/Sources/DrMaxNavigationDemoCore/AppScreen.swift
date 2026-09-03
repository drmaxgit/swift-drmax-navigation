import CasePaths
import DrMaxNavigation
import SwiftUI

/// The root of the demo's navigation tree.
///
/// `AppScreen` only knows about the entry point of each feature (`counter`, `settings`) plus
/// the feature's own screen cases (`counterScreen`, `settingsScreen`). This mirrors how a real
/// app would combine independently developed feature modules without those modules knowing
/// about each other or about `AppScreen` itself.
@CasePathable
public enum AppScreen: Hashable {
    case home
    case counter(CounterCoordinator)
    case counterScreen(CounterScreen)
    case settings(SettingsCoordinator)
    case settingsScreen(SettingsScreen)
}

/// Owns the root navigation controller and knows how to reach every feature.
///
/// A real app would typically split this responsibility across one coordinator per tab/section;
/// this demo keeps a single one for simplicity.
@Observable
public final class AppCoordinator {
    public let controller = RootNavigationController<AppScreen>(root: .home)

    private(set) var counterCoordinator: CounterCoordinator?
    private(set) var settingsCoordinator: SettingsCoordinator?

    public init() {}

    func showCounter(style: NavigationStyle) {
        let child = controller.pullback(on: \.counterScreen)
        let coordinator = CounterCoordinator(controller: child)
        counterCoordinator = coordinator
        controller.navigate(to: .counter(coordinator), style: style)
    }

    func showSettings(style: NavigationStyle) {
        let child = controller.pullback(on: \.settingsScreen)
        let coordinator = SettingsCoordinator(controller: child)
        settingsCoordinator = coordinator
        controller.navigate(to: .settings(coordinator), style: style)
    }
}

/// Resolves every `AppScreen` case to its view, delegating feature screens to the feature itself.
public struct AppScreenView: View {
    let coordinator: AppCoordinator
    let screen: AppScreen

    public init(coordinator: AppCoordinator, screen: AppScreen) {
        self.coordinator = coordinator
        self.screen = screen
    }

    public var body: some View {
        switch screen {
        case .home:
            HomeView(coordinator: coordinator)

        case let .counter(counterCoordinator):
            CounterScreenView(coordinator: counterCoordinator, screen: .root)

        case let .counterScreen(screen):
            if let counterCoordinator = coordinator.counterCoordinator {
                CounterScreenView(coordinator: counterCoordinator, screen: screen)
            }

        case let .settings(settingsCoordinator):
            SettingsScreenView(coordinator: settingsCoordinator, screen: .root)

        case let .settingsScreen(screen):
            if let settingsCoordinator = coordinator.settingsCoordinator {
                SettingsScreenView(coordinator: settingsCoordinator, screen: screen)
            }
        }
    }
}
