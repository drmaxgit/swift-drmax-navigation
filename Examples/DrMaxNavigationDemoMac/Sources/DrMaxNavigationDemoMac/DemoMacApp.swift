import DrMaxNavigation
import DrMaxNavigationDemoCore
import SwiftUI

@main
struct DemoMacApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootNavigationControllerView(controller: coordinator.controller) { screen in
                AppScreenView(coordinator: coordinator, screen: screen)
            }
            .frame(minWidth: 420, minHeight: 500)
        }
    }
}
