import CasePaths
import DrMaxNavigation
import SwiftUI

// Everything in this file pretends to live in its own feature package: it only knows about
// `CounterScreen`, never about `AppScreen`. `AppCoordinator` is the one connecting it to the
// rest of the app via `pullback(on:)`.

@CasePathable
public enum CounterScreen: Hashable {
    case root
    case detail(count: Int)
}

/// A coordinator is a plain reference type here so it can be held as `NavigationController`'s
/// scoped handle and compared by identity when embedded in `AppScreen`.
///
/// The type (and its `Hashable` witnesses) is `public` only because `AppScreen` embeds it as a
/// case payload — its other members stay internal since only this file's views call them.
@Observable
public final class CounterCoordinator: Hashable {
    let controller: NavigationController<AppScreen, CounterScreen>

    private(set) var count = 0

    init(controller: NavigationController<AppScreen, CounterScreen>) {
        self.controller = controller
    }

    func increment() {
        count += 1
    }

    func pushDetail() {
        controller.navigate(to: .detail(count: count))
    }

    /// Pops every screen this feature pushed, leaving the feature's own root on screen.
    func backToFeatureRoot() {
        controller.popToPullbackRoot()
    }

    public static func == (lhs: CounterCoordinator, rhs: CounterCoordinator) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct CounterScreenView: View {
    let coordinator: CounterCoordinator
    let screen: CounterScreen

    var body: some View {
        switch screen {
        case .root: CounterRootView(coordinator: coordinator)
        case let .detail(count): CounterDetailView(coordinator: coordinator, snapshot: count)
        }
    }
}

private struct CounterRootView: View {
    let coordinator: CounterCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("\(coordinator.count)")
                .font(.system(size: 56, weight: .bold, design: .rounded))

            Button("Increment") { coordinator.increment() }
                .buttonStyle(.borderedProminent)

            Button("Push detail (snapshot: \(coordinator.count))") { coordinator.pushDetail() }
        }
        .navigationTitle("Counter")
    }
}

private struct CounterDetailView: View {
    let coordinator: CounterCoordinator
    let snapshot: Int

    var body: some View {
        VStack(spacing: 16) {
            Text("Snapshot taken at \(snapshot)")

            Text("Live count: \(coordinator.count)")
                .foregroundStyle(.secondary)

            Button("Push another detail") { coordinator.pushDetail() }

            Button("Pop") { coordinator.controller.pop() }

            Button("Back to feature root (popToPullbackRoot)") {
                coordinator.backToFeatureRoot()
            }
        }
        .navigationTitle("Detail")
    }
}
