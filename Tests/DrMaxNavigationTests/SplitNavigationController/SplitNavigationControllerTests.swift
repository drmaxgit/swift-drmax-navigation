import CasePaths
@_spi(Testing) @testable import DrMaxNavigation
import SwiftUI
import Testing

@Suite("Split navigation controller tests")
struct SplitNavigationControllerTests {
    @Test
    func initialSelectionPrefersDetailColumn() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        #expect(controller.selection == .one)
        #expect(controller.preferredCompactColumn == .detail)
    }

    @Test
    func missingInitialSelectionPrefersSidebarColumn() {
        let controller = SplitNavigationController<Destination>()

        #expect(controller.selection == nil)
        #expect(controller.preferredCompactColumn == .sidebar)
    }

    @Test
    func selectingDifferentItemResetsDetailColumn() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .one)
        controller.navigate(to: .two, style: .sheet)

        controller.select(.two)

        #expect(controller.selection == .two)
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
        #expect(controller.preferredCompactColumn == .detail)
    }

    @Test
    func selectingCurrentItemKeepsDetailColumn() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .one)
        controller.navigate(to: .two, style: .sheet)

        controller.select(.one)

        #expect(controller.path == [.one].asNavigationElements())
        #expect(controller.presentation != nil)
    }

    @Test
    func deselectingResetsDetailColumnAndPrefersSidebar() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .one)

        controller.deselect()

        #expect(controller.selection == nil)
        #expect(controller.path.isEmpty)
        #expect(controller.preferredCompactColumn == .sidebar)
    }

    @Test
    func navigationTargetsDetailColumn() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .one)
        controller.navigate(to: .two, style: .sheet)
        controller.navigate(to: .three)

        #expect(controller.path == [.one].asNavigationElements())
        #expect(controller.presentation!.controller.completePath == [.two, .three].asNavigationElements())

        controller.popToRoot()

        #expect(controller.selection == .one)
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
    }

    @Test
    func completePathStartsWithSelection() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)

        #expect(
            controller.completePath == [NavigationElement(wrapped: .one, wasNavigatedWithAnimation: false)]
                + [.two, .three].asNavigationElements()
        )
    }

    @Test
    func poppingToSelectionClearsDetailColumnAndKeepsSelection() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)

        controller.popTo(Destination.one)

        #expect(controller.selection == .one)
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
    }

    @Test
    func poppingBeforeSelectionDeselects() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)

        controller.popBefore(Destination.one)

        #expect(controller.selection == nil)
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
        #expect(controller.preferredCompactColumn == .sidebar)
    }

    @Test
    func poppingToSelectionCaseClearsDetailColumnAndKeepsSelection() {
        let controller = SplitNavigationController<Destination>(selection: .child(.childOne))

        controller.navigate(to: .two)

        controller.popTo(\.child)

        #expect(controller.selection == .child(.childOne))
        #expect(controller.path.isEmpty)
    }

    @Test
    func poppingBeforeSelectionCaseDeselects() {
        let controller = SplitNavigationController<Destination>(selection: .child(.childOne))

        controller.navigate(to: .two)

        controller.popBefore(\.child)

        #expect(controller.selection == nil)
        #expect(controller.path.isEmpty)
    }

    @Test
    func poppingToPullbackRootDeselectsWhenSelectionIsPullbackRoot() {
        let controller = SplitNavigationController<Destination>(selection: .child(.childOne))
        let child = controller.pullback(on: \.child)

        child.navigate(to: .childTwo)

        child.popToPullbackRoot()

        #expect(controller.selection == nil)
        #expect(controller.path.isEmpty)
    }

    @Test
    func matchesInDetailColumnAreFoundAfterSelection() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three)

        controller.popTo(Destination.two)

        #expect(controller.selection == .one)
        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func navigatingToSelectionCaseWithoutNestingMovesSelection() {
        let controller = SplitNavigationController<Destination>(selection: .child(.childOne))

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)

        controller.navigate(to: .child(.childTwo), allowsSameScreenNesting: false)

        #expect(controller.selection == .child(.childTwo))
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
    }

    @Test
    func navigatingToSelectionWithoutNestingClearsDetailColumn() {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)

        controller.navigate(to: .one, allowsSameScreenNesting: false)

        #expect(controller.selection == .one)
        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
    }

    @Test
    func navigatingToDetailCaseWithoutNestingPopsInDetailColumn() async {
        let controller = SplitNavigationController<Destination>(selection: .one)

        controller.navigate(to: .two)
        controller.navigate(to: .three)

        await confirm { confirmation in
            controller.navigate(to: .two, allowsSameScreenNesting: false) {
                confirmation()
            }
        }

        #expect(controller.selection == .one)
        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func navigatingToSelectionCaseWithoutNestingInvokesCompletion() async {
        let controller = SplitNavigationController<Destination>(selection: .child(.childOne))

        await confirm { confirmation in
            controller.navigate(to: .child(.childTwo), allowsSameScreenNesting: false) {
                confirmation()
            }
        }
    }

    @Test
    func poppingToSelectionInvokesCompletion() async {
        let controller = SplitNavigationController<Destination>(selection: .one)
        controller.navigate(to: .two)

        await confirm { confirmation in
            controller.popTo(Destination.one) {
                confirmation()
            }
        }
    }

    @Test
    func poppingBeforeSelectionInvokesCompletion() async {
        let controller = SplitNavigationController<Destination>(selection: .one)

        await confirm { confirmation in
            controller.popBefore(Destination.one) {
                confirmation()
            }
        }
    }

    @Test
    func selectInvokesCompletion() async {
        let controller = SplitNavigationController<Destination>()

        await confirm { confirmation in
            controller.select(.one) {
                confirmation()
            }
        }
    }

    @Test
    func selectingCurrentItemInvokesCompletion() async {
        let controller = SplitNavigationController<Destination>(selection: .one)

        await confirm { confirmation in
            controller.select(.one) {
                confirmation()
            }
        }
    }
}
