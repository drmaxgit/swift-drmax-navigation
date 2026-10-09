import DrMaxNavigation
import DrMaxNavigationDemoCore
import SwiftUI

@main
struct DemoApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootNavigationControllerView(controller: coordinator.controller) { screen in
                AppScreenView(coordinator: coordinator, screen: screen)
            }
        }
    }
}
