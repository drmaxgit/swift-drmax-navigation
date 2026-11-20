@_spi(Testing) @testable import DrMaxNavigation
import CasePaths
import Testing

@CasePathable
private enum OwningDestination: Hashable {
    case screen(OwningScreen)
}

private final class OwningScreen: Hashable {
    var controller: NavigationController<OwningDestination, OwningScreen>?

    static func == (lhs: OwningScreen, rhs: OwningScreen) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct NavigationControllerParentLifetimeTests {
    @Test
    func doesNotRetainParent() {
        var parent: RootNavigationController<Destination>? = RootNavigationController()
        let controller = parent?.pullback(on: \.child)

        parent = nil

        #expect(controller?.parent == nil)
    }

    @Test
    func releasesParentWhoseRootScreenOwnsPulledBackController() {
        weak var weakParent: RootNavigationController<OwningDestination>?
        weak var weakScreen: OwningScreen?

        do {
            let parent = RootNavigationController<OwningDestination>()
            let screen = OwningScreen()
            screen.controller = parent.pullback(on: \.screen)
            parent.set(root: .screen(screen))
            weakParent = parent
            weakScreen = screen
        }

        #expect(weakParent == nil)
        #expect(weakScreen == nil)
    }

    @Test
    func invokesNavigateCompletionWhenParentIsReleased() async {
        let controller = releasedParentController()

        await confirm { confirmation in
            controller.navigate(to: .childOne) {
                confirmation()
            }
        }
    }

    @Test
    func invokesPopCompletionWhenParentIsReleased() async {
        let controller = releasedParentController()

        await confirm { confirmation in
            controller.pop {
                confirmation()
            }
        }
    }

    @Test
    func invokesPopBeforeCompletionWhenParentIsReleased() async {
        let controller = releasedParentController()

        await confirm { confirmation in
            controller.popBefore(\.childOne) {
                confirmation()
            }
        }
    }

    private func releasedParentController() -> NavigationController<Destination, ChildDestination> {
        RootNavigationController<Destination>().pullback(on: \.child)
    }
}
