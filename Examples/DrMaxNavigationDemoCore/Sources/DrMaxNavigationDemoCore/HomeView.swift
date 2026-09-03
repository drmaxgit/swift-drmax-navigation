import DrMaxNavigation
import SwiftUI

/// Entry point of the demo. Every button below drives the same `navigate(to:style:)` API
/// with a different `NavigationStyle`, so you can compare push/sheet/popover/cover side by side.
struct HomeView: View {
    let coordinator: AppCoordinator

    var body: some View {
        List {
            Section("Counter feature") {
                Button("Push") { coordinator.showCounter(style: .push) }
                Button("Present as sheet") { coordinator.showCounter(style: .sheet) }
                Button("Present as popover") { coordinator.showCounter(style: .popover) }
            }

            Section("Settings feature") {
                // `.cover` (full screen cover) doesn't exist on macOS, same as the library's own
                // NavigationStyle enum excludes it there.
                #if os(macOS)
                Button("Present as sheet") { coordinator.showSettings(style: .sheet) }
                #else
                Button("Present as full screen cover") { coordinator.showSettings(style: .cover) }
                #endif
            }
        }
        .navigationTitle("DrMaxNavigation")
    }
}
