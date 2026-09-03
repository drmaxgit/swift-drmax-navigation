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
    Screen: Hashable,
    ScreenView: View
>: View {
    @Bindable var controller: RootNavigationController<Screen>
    let screen: (Screen) -> ScreenView

    public init(
        controller: RootNavigationController<Screen>,
        @ViewBuilder screen: @escaping (Screen) -> ScreenView
    ) {
        self.controller = controller
        self.screen = screen
    }

    public var body: some View {
        NavigationStack(path: $controller.path) {
            root
                .navigationDestination(for: NavigationElement<Screen>.self) {
                    screen($0.wrapped)
                        .pushDestinationFrame()
                }
        }
        .sheet(item: $controller.sheet) { controller in
            RootNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #if !os(watchOS)
        .popover(item: $controller.popover) { controller in
            RootNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #endif
        #if !os(macOS)
        .fullScreenCover(item: $controller.cover) { controller in
            RootNavigationControllerView(
                controller: controller,
                screen: screen
            )
            .presentationModifiers(dismissable: controller.allowsInteractiveDismiss)
        }
        #endif
    }

    @ViewBuilder
    private var root: some View {
        if let root = controller.root?.wrapped {
            screen(root)
        }
    }
}

private extension View {
    func presentationModifiers(dismissable: Bool) -> some View {
        self
            .interactiveDismissDisabled(!dismissable)
            .conditionalPresentationBackground()
    }

    /// Forces pushed content to fill the navigation stack and paints an opaque background behind it.
    ///
    /// On macOS, `NavigationStack` sizes a `navigationDestination` to its ideal size and doesn't opaquely
    /// cover the view it replaced, so a destination that doesn't already fill and paint its own background
    /// (e.g. a plain `VStack`) renders small, centered, and see-through over the previous screen. iOS doesn't
    /// need this: `UINavigationController` already gives every pushed view the full, opaque content area.
    @ViewBuilder
    func pushDestinationFrame() -> some View {
        #if os(macOS)
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
        #else
        self
        #endif
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
