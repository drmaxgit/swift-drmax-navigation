import CasePaths
@_spi(Testing) @testable import DrMaxNavigation
import Testing

@Suite("Plain Destination tests")
struct PlainDestinationTests {
    @Test
    func completePathShouldReflectPresentedDestinations() {
        let controller = RootNavigationController<Destination>()

        controller.navigate(to: .two)
        controller.navigate(to: .three, style: .sheet)
        controller.navigate(to: .four)

        #expect(controller.completePath == [.two, .three, .four].asNavigationElements())
    }

    @Test
    func navigatingOnPresentingControllerPresentsOnTopMostController() {
        let controller = RootNavigationController<Destination>(
            path: [.one, .two]
        )

        controller.navigate(to: .one, style: .sheet)
        controller.navigate(to: .two, style: .sheet)

        controller.navigate(to: .four)
        controller.navigate(to: .three)

        #expect(controller.path == [.one, .two].asNavigationElements())
        #expect(controller.presentation != nil)
        #expect(controller.presentation!.controller.path.isEmpty)
        #expect(controller.presentation!.controller.presentation!.controller.path == [.four, .three].asNavigationElements())
    }

    @Test
    func popOnPresentingControllerPopsFromTopMostController() {
        let controller = RootNavigationController<Destination>(
            path: [.one, .two]
        )

        controller.navigate(to: .one, style: .sheet)
        controller.navigate(to: .two, style: .sheet)

        controller.navigate(to: .four)
        controller.navigate(to: .three)

        #expect(controller.path == [.one, .two].asNavigationElements())
        #expect(controller.presentation != nil)
        #expect(controller.presentation!.controller.path.isEmpty)
        #expect(controller.presentation!.controller.presentation!.controller.path == [.four, .three].asNavigationElements())

        controller.pop()

        #expect(controller.presentation!.controller.presentation!.controller.path == [.four].asNavigationElements())

        controller.pop()

        #expect(controller.presentation!.controller.presentation!.controller.path.isEmpty)
        #expect(controller.presentation!.controller.presentation != nil)

        controller.pop()

        #expect(controller.presentation!.controller.presentation == nil)
        #expect(controller.path == [.one, .two].asNavigationElements())
        #expect(controller.presentation != nil)
        #expect(controller.presentation!.controller.path.isEmpty)
    }

    @Test
    func presentingSheetPresentsSheet() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .two, style: .sheet)

        let stateCorrect = switch controller.presentation {
        case .sheet: true
        default: false
        }

        #expect(stateCorrect)
    }
    
    #if !os(macOS)
    @Test
    func presentingCoverPresentsCover() {
        let controller = RootNavigationController<Destination>(root: .one)
        controller.navigate(to: .two, style: .cover)

        let stateCorrect = switch controller.presentation {
        case .cover: true
        default: false
        }

        #expect(stateCorrect)
    }
    #endif
    
    #if !os(watchOS)
    @Test
    func presentingPopoverPresentsPopover() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .two, style: .popover)

        let stateCorrect = switch controller.presentation {
        case .popover: true
        default: false
        }

        #expect(stateCorrect)
    }
    #endif

    @Test
    func popRemovesLastElementFromFlatController() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.pop()

        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func popRemovesLastPresentedControllerWhenPresentedPathEmpty() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(
            to: .four,
            style: .sheet
        )

        #expect(controller.presentation != nil)

        controller.pop()
        
        #expect(controller.path == [.two, .three].asNavigationElements())
        #expect(controller.presentation == nil)
    }

    @Test
    func popToRootRemovesAll() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        controller.popToRoot()

        #expect(controller.path.isEmpty)
        #expect(controller.presentation == nil)
    }

    @Test
    func popBeforeRemovesIncludingElement() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popBefore(.three)

        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func popBeforeRemovesPresentationIfRoot() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        controller.popBefore(.four)

        #expect(controller.path == [.two, .three].asNavigationElements())
        #expect(controller.presentation == nil)
    }

    @Test
    func popBeforeFirstElementRemovescompletePath() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popBefore(.two)

        #expect(controller.path.isEmpty)
    }

    @Test
    func popToLastElementRemovesPresentationAndLastElement() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        #expect(controller.presentation != nil)

        controller.popBefore(.three)

        #expect(controller.path == [.two].asNavigationElements())
        #expect(controller.presentation == nil)
    }

    @Test
    func popToRemovesElementNotIncluding() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popTo(.three)

        #expect(controller.path == [.two, .three].asNavigationElements())
    }

    @Test
    func popToFirstElementRemovescompletePathAfter() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popTo(.two)

        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func popToLastElementRemovesPresentation() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        #expect(controller.presentation != nil)

        controller.popTo(.three)

        #expect(controller.path == [.two, .three].asNavigationElements())
        #expect(controller.presentation == nil)
    }

    @Test
    func popToPresentationRootShouldPopLastPresentationPath() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .one)
        controller.navigate(to: .two, style: .sheet)
        controller.navigate(to: .three)
        controller.navigate(to: .four)

        #expect(controller.path == [.one].asNavigationElements())
        #expect(
            controller.presentation?.controller.root == NavigationElement(
                wrapped: .two,
                wasNavigatedWithAnimation: true
            )
        )
        #expect(controller.presentation?.controller.path == [.three, .four].asNavigationElements())

        controller.popToPresentationRoot()

        #expect(controller.path == [.one].asNavigationElements())
        #expect(
            controller.presentation?.controller.root == NavigationElement(
                wrapped: .two,
                wasNavigatedWithAnimation: true
            )
        )
        #expect(controller.presentation!.controller.path.isEmpty)
    }
    
    @Test
    func pushingWithoutAnimationSetsElementFlag() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .one, animated: true)
        controller.navigate(to: .two, animated: false)
        controller.navigate(to: .three, animated: true)
        
        #expect(
            controller.path == [
                NavigationElement(wrapped: .one, wasNavigatedWithAnimation: true),
                NavigationElement(wrapped: .two, wasNavigatedWithAnimation: false),
                NavigationElement(wrapped: .three, wasNavigatedWithAnimation: true),
            ]
        )
    }
    
    @Test
    func presentingSheetWithoutAnimationSetsElementFlag() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .one, style: .sheet, animated: false)
        controller.navigate(to: .two, animated: false)
        controller.navigate(to: .three, animated: true)
        
        #expect(
            controller.presentation?.controller.root == NavigationElement(
                wrapped: .one,
                wasNavigatedWithAnimation: false
            )
        )
        
        #expect(
            controller.presentation?.controller.path == [
                NavigationElement(wrapped: .two, wasNavigatedWithAnimation: false),
                NavigationElement(wrapped: .three, wasNavigatedWithAnimation: true)
            ]
        )
    }
    
    #if !os(watchOS)
    @Test
    func presentingPopoverWithoutAnimationSetsElementFlag() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .one, style: .popover, animated: false)
        controller.navigate(to: .two, animated: false)
        controller.navigate(to: .three, animated: true)
        
        #expect(
            controller.presentation?.controller.root == NavigationElement(
                wrapped: .one,
                wasNavigatedWithAnimation: false
            )
        )
        
        #expect(
            controller.presentation?.controller.path == [
                NavigationElement(wrapped: .two, wasNavigatedWithAnimation: false),
                NavigationElement(wrapped: .three, wasNavigatedWithAnimation: true)
            ]
        )
    }
    #endif
    
    #if !os(macOS)
    @Test
    func presentingCoverWithoutAnimationSetsElementFlag() {
        let controller = RootNavigationController<Destination>()
        controller.navigate(to: .one, style: .cover, animated: false)
        controller.navigate(to: .two, animated: false)
        controller.navigate(to: .three, animated: true)
        
        #expect(
            controller.presentation?.controller.root == NavigationElement(
                wrapped: .one,
                wasNavigatedWithAnimation: false
            )
        )
        
        #expect(
            controller.presentation?.controller.path == [
                NavigationElement(wrapped: .two, wasNavigatedWithAnimation: false),
                NavigationElement(wrapped: .three, wasNavigatedWithAnimation: true)
            ]
        )
    }
    #endif
}

@Suite("CasePathable Destination conforming tests")
struct CasePathableDestinationTests {
    @Test
    func popBeforeRemovesIncludingElement() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popBefore(\.three)

        #expect(
            controller.path == [.two].asNavigationElements()
        )
    }

    @Test
    func popBeforeFirstElementRemovescompletePath() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popBefore(\.two)

        #expect(controller.path.isEmpty)
    }

    @Test
    func popToLastElementRemovesPresentationAndLastElement() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        #expect(controller.presentation != nil)

        controller.popBefore(\.three)

        #expect(controller.path == [.two].asNavigationElements())
        #expect(controller.presentation == nil)
    }

    @Test
    func popToRemovesElementNotIncluding() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popTo(\.three)

        #expect(controller.path == [.two, .three].asNavigationElements())
    }

    @Test
    func popToFirstElementRemovescompletePathAfter() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three, .four]
        )

        controller.popTo(\.two)

        #expect(controller.path == [.two].asNavigationElements())
    }

    @Test
    func popToLastElementRemovesPresentation() {
        let controller = RootNavigationController<Destination>(
            path: [.two, .three]
        )

        controller.navigate(to: .four, style: .sheet)

        #expect(controller.presentation != nil)

        controller.popTo(\.three)

        #expect(controller.path == [.two, .three].asNavigationElements())
        #expect(controller.presentation == nil)
    }
    
    @Test
    func navigateCorrectlyDisallowsNesting() {
        let controller = RootNavigationController<Destination>(
            path: [.one, .two, .three, .two]
        )
        
        controller.navigate(to: .two, allowsSameScreenNesting: false) {
            #expect(controller.path == [.one, .two].asNavigationElements())
            #expect(controller.presentation == nil)
        }
    }
}
