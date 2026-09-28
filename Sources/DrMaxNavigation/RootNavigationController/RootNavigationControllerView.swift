// ===----------------------------------------------------------------------===//
//
// This source file is part of the DrMaxNavigation open source project
//
// Copyright (c) 2026 Dr. Max BDC, s.r.o. and the DrMaxNavigation project authors
// Licensed under The MIT License (MIT)
//
// See LICENSE.md for license information
// See CONTRIBUTORS.md for the list of DrMaxNavigation project authors
//
// ===----------------------------------------------------------------------===//

import SwiftUI

/// A SwiftUI view that renders a ``RootNavigationController``.
///
/// This view handles the rendering of the root screen, the navigation stack, and any active presentations.
/// It recursively renders itself for any presented navigation controllers.
///
/// ```swift
/// RootNavigationControllerView(controller: myCoordinator.controller) { screen in
///     switch screen {
///     case .home: HomeView()
///     case .detail: DetailView()
///     }
/// }
/// ```
public struct RootNavigationControllerView<
    RootView: View,
    Screen: Hashable,
    ScreenView: View
>: View {
    @Bindable var controller: RootNavigationController<Screen>
    let root: () -> RootView
    let screen: (Screen) -> ScreenView

    public init(
        controller: RootNavigationController<Screen>,
        @ViewBuilder root: @escaping () -> RootView,
        @ViewBuilder screen: @escaping (Screen) -> ScreenView
    ) {
        self.controller = controller
        self.root = root
        self.screen = screen
    }

    public var body: some View {
        NavigationStack(path: $controller.path) {
            root()
                .navigationDestination(for: NavigationElement<Screen>.self) {
                    screen($0.wrapped)
                }
        }
        .sheet(item: $controller.sheet) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #if !os(watchOS)
        .popover(item: $controller.popover) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #endif
        #if !os(macOS)
        .fullScreenCover(item: $controller.cover) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #endif
    }
}

public struct PresentedNavigationControllerView<
    Screen: Hashable,
    ScreenView: View
>: View {
    @Bindable var controller: PresentedNavigationController<Screen>
    let screen: (Screen) -> ScreenView
    
    public init(
        controller: PresentedNavigationController<Screen>,
        @ViewBuilder screen: @escaping (Screen) -> ScreenView
    ) {
        self.controller = controller
        self.screen = screen
    }
    
    public var body: some View {
        NavigationStack(path: $controller.path) {
            screen(controller.root.wrapped)
                .navigationDestination(for: NavigationElement<Screen>.self) {
                    screen($0.wrapped)
                }
        }
        .sheet(item: $controller.sheet) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
#if !os(watchOS)
        .popover(item: $controller.popover) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
#endif
#if !os(macOS)
        .fullScreenCover(item: $controller.cover) { controller in
            PresentedNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
#endif
    }
}

private extension View {
    func presentationModifiers(dismissable: Bool) -> some View {
        self
            .interactiveDismissDisabled(!dismissable)
            .conditionalPresentationBackground()
    }
    
    @ViewBuilder
    func conditionalPresentationBackground() -> some View {
        if #available(iOS 18.0, *) {
            self.presentationBackground(.background)
        } else {
            self
        }
    }
}
