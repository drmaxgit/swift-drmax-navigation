////
////  PlainNavigationControllerDestinationTest.swift
////  swift-drmax-navigation
////
////  Created by Dominik Grodl on 26.09.2026.
////
//
//
//@_spi(Testing) @testable import DrMaxNavigation
//import Testing
//
//struct PlainNavigationControllerDestinationTest {
//    @Test
//    func pushPropagatesToParent() async throws {
//        let parent = RootNavigationController<Destination>(
//            root: .one,
//            path: [.two, .three]
//        )
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne)
//
//        #expect(parent.path == [.two, .three, .child(.childOne)].asNavigationElements())
//    }
//
//    @Test
//    func presentationPropagatesToParent() async throws {
//        let parent = RootNavigationController<Destination>()
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//
//        #expect(
//            parent.presentation!.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: true
//            )
//        )
//    }
//
//    @Test
//    func pushPropagatesToNestedParent() async throws {
//        let parent = RootNavigationController<Destination>()
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//
//        #expect(
//            parent.presentation!.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: true
//                )
//        )
//
//        controller.navigate(to: .childTwo)
//
//        #expect(parent.presentation!.controller.path == [.child(.childTwo)].asNavigationElements())
//    }
//
//    @Test
//    func presentationPropagatesToNestedParent() async throws {
//        let parent = RootNavigationController<Destination>()
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//
//        #expect(
//            parent.presentation!.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: true
//            )
//        )
//
//        controller.navigate(to: .childTwo, style: .sheet)
//
//        #expect(
//            parent.presentation!.controller.presentation!.controller.root == NavigationElement(
//                wrapped: .child(.childTwo),
//                wasNavigatedWithAnimation: true
//            )
//        )
//    }
//
//    @Test
//    func popPropagatesToParentPath() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne)
//        controller.navigate(to: .childTwo)
//        controller.pop()
//
//        #expect(parent.path == [.child(.childOne)].asNavigationElements())
//    }
//
//    @Test
//    func popPropagatesToParentPresentationWhenPresentedPathEmpty() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//
//        #expect(parent.presentation != nil)
//
//        controller.pop()
//
//        #expect(parent.presentation == nil)
//    }
//
//    @Test
//    func popPropagatesToParentPresentationWhenPresentedPathNotEmpty() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//        controller.navigate(to: .childTwo)
//        controller.navigate(to: .childThree)
//
//        #expect(parent.presentation!.controller.path == [.child(.childTwo), .child(.childThree)].asNavigationElements())
//
//        controller.pop()
//
//        #expect(parent.presentation!.controller.path == [.child(.childTwo)].asNavigationElements())
//    }
//
//    @Test
//    func popPropagatesToParentPresentationWhenPresentedPathSingleElement() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet)
//        controller.navigate(to: .childTwo)
//
//        #expect(parent.presentation!.controller.path == [.child(.childTwo)].asNavigationElements())
//
//        controller.pop()
//
//        #expect(parent.presentation!.controller.path.isEmpty)
//    }
//
//    @Test
//    func popToRootPropagatesToParent() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .four)
//        parent.navigate(to: .three)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne, style: .sheet)
//        controller.navigate(to: .childTwo)
//
//        #expect(parent.path == [.four, .three].asNavigationElements())
//        #expect(parent.presentation!.controller.path == [.child(.childTwo)].asNavigationElements())
//
//        controller.popToRoot()
//
//        #expect(parent.presentation == nil)
//        #expect(parent.path.isEmpty)
//    }
//
//    @Test
//    func popBeforePropagatesToParent() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .one)
//        parent.navigate(to: .two)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne)
//        parent.navigate(to: .three)
//
//        #expect(parent.path == [.one, .two, .child(.childOne), .three].asNavigationElements())
//
//        controller.popBefore(\.childOne)
//
//        #expect(parent.path == [.one, .two].asNavigationElements())
//    }
//
//    @Test
//    func popToPropagatesToParent() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .one)
//        parent.navigate(to: .two)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne)
//        parent.navigate(to: .three)
//
//        #expect(parent.path == [.one, .two, .child(.childOne), .three].asNavigationElements())
//
//        controller.popTo(\.childOne)
//
//        #expect(parent.path == [.one, .two, .child(.childOne)].asNavigationElements())
//    }
//
//    @Test
//    func popToPropagatesToNestedParent() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .one)
//        parent.navigate(to: .two, style: .sheet)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne)
//        parent.navigate(to: .three)
//
//        #expect(parent.presentation?.controller.path == [.child(.childOne), .three].asNavigationElements())
//
//        controller.popTo(\.childOne)
//
//        #expect(parent.presentation?.controller.path == [.child(.childOne)].asNavigationElements())
//    }
//
//    @Test
//    func popBeforePropagatesToNestedParent() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .one)
//        parent.navigate(to: .two, style: .sheet)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne)
//        parent.navigate(to: .three)
//
//        #expect(parent.presentation?.controller.path == [.child(.childOne), .three].asNavigationElements())
//
//        controller.popBefore(\.childOne)
//
//        #expect(parent.presentation!.controller.path.isEmpty)
//    }
//
//    @Test
//    func popBeforeDismissesPresentedRoot() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne, style: .sheet)
//
//        #expect(
//            parent.presentation!.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: true
//            )
//        )
//        controller.popBefore(\.childOne)
//        #expect(parent.presentation == nil)
//    }
//
//    @Test
//    func popToPullbackRootRemovesFirstChildDestinationAndEverythingAfter() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        parent.navigate(to: .two)
//
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne)
//        parent.navigate(to: .three)
//        controller.navigate(to: .childTwo)
//
//        #expect(parent.path == [.two, .child(.childOne), .three, .child(.childTwo)].asNavigationElements())
//
//        controller.popToPullbackRoot()
//
//        #expect(parent.path == [.two].asNavigationElements())
//    }
//
//    @Test
//    func popToPullbackRootDismissesPresentedChildRoot() async throws {
//        let parent = RootNavigationController<Destination>(root: .one)
//        let controller = parent.pullback(on: \.child)
//
//        controller.navigate(to: .childOne, style: .sheet)
//        controller.navigate(to: .childTwo)
//
//        #expect(
//            parent.presentation?.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: true
//            )
//        )
//        #expect(parent.presentation?.controller.path == [.child(.childTwo)].asNavigationElements())
//
//        controller.popToPullbackRoot()
//
//        #expect(parent.presentation == nil)
//    }
//
//    @Test
//    func popToPullbackRootDoesNothingWhenChildDestinationIsMissing() async throws {
//        let parent = RootNavigationController<Destination>(
//            root: .one,
//            path: [.two, .three]
//        )
//        let controller = parent.pullback(on: \.child)
//
//        controller.popToPullbackRoot()
//
//        #expect(parent.path == [.two, .three].asNavigationElements())
//    }
//    
//    @Test
//    func navigateCorrectlyDisallowsNesting() {
//        let parent = RootNavigationController<Destination>(
//            root: .one,
//            path: [.one, .child(.childOne), .two, .three, .child(.childTwo)]
//        )
//        
//        let controller = parent.pullback(on: \.child)
//        
//        controller.navigate(to: .childOne, allowsSameScreenNesting: false) {
//            #expect(parent.path == [.one, .child(.childOne)].asNavigationElements())
//            #expect(parent.presentation == nil)
//        }
//    }
//    
//    @Test
//    func pushingWithoutAnimationSetsElementFlag() {
//        let parent = RootNavigationController<Destination>()
//        
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, animated: true)
//        controller.navigate(to: .childTwo, animated: false)
//        controller.navigate(to: .childThree, animated: true)
//        
//        #expect(
//            parent.path == [
//                NavigationElement(wrapped: .child(.childOne), wasNavigatedWithAnimation: true),
//                NavigationElement(wrapped: .child(.childTwo), wasNavigatedWithAnimation: false),
//                NavigationElement(wrapped: .child(.childThree), wasNavigatedWithAnimation: true),
//            ]
//        )
//    }
//    
//    @Test
//    func presentingSheetWithoutAnimationSetsElementFlag() {
//        let parent = RootNavigationController<Destination>()
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .sheet, animated: false)
//        controller.navigate(to: .childTwo, animated: false)
//        controller.navigate(to: .childThree, animated: true)
//        
//        #expect(
//            parent.presentation?.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: false
//            )
//        )
//        
//        #expect(
//            parent.presentation?.controller.path == [
//                NavigationElement(wrapped: .child(.childTwo), wasNavigatedWithAnimation: false),
//                NavigationElement(wrapped: .child(.childThree), wasNavigatedWithAnimation: true)
//            ]
//        )
//    }
//    
//    #if !os(watchOS)
//    @Test
//    func presentingPopoverWithoutAnimationSetsElementFlag() {
//        let parent = RootNavigationController<Destination>()
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .popover, animated: false)
//        controller.navigate(to: .childTwo, animated: false)
//        controller.navigate(to: .childThree, animated: true)
//        
//        #expect(
//            parent.presentation?.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: false
//            )
//        )
//        
//        #expect(
//            parent.presentation?.controller.path == [
//                NavigationElement(wrapped: .child(.childTwo), wasNavigatedWithAnimation: false),
//                NavigationElement(wrapped: .child(.childThree), wasNavigatedWithAnimation: true)
//            ]
//        )
//    }
//    #endif
//    
//    #if !os(macOS)
//    @Test
//    func presentingCoverWithoutAnimationSetsElementFlag() {
//        let parent = RootNavigationController<Destination>()
//        let controller = parent.pullback(on: \.child)
//        controller.navigate(to: .childOne, style: .cover, animated: false)
//        controller.navigate(to: .childTwo, animated: false)
//        controller.navigate(to: .childThree, animated: true)
//        
//        #expect(
//            parent.presentation?.controller.root == NavigationElement(
//                wrapped: .child(.childOne),
//                wasNavigatedWithAnimation: false
//            )
//        )
//        
//        #expect(
//            parent.presentation?.controller.path == [
//                NavigationElement(wrapped: .child(.childTwo), wasNavigatedWithAnimation: false),
//                NavigationElement(wrapped: .child(.childThree), wasNavigatedWithAnimation: true)
//            ]
//        )
//    }
//    #endif
//}
