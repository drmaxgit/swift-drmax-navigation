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

import CasePaths
import SwiftUI

/// The main controller for managing a navigation tree.
///
/// ``RootNavigationController`` is the source of truth for your navigation state. It manages:
/// - The root screen of the navigation tree.
/// - The current stack (path) of pushed screens.
/// - Any active presentation (sheet, cover, popover), which can in turn have its own navigation tree.
///
/// You typically create one ``RootNavigationController`` per major section of your app (e.g., per tab).
///
/// ```swift
/// let dashboardController = RootNavigationController<DashboardScreen>(root: .home)
/// ```
@Observable
public class RootNavigationController<Screen: Hashable>: Identifiable {
    public private(set) var root: Screen?
    public var path: [Screen]
    public internal(set) var presentation: Presentation<Screen>?

    /// Creates a new navigation controller.
    /// - Parameters:
    ///   - root: The initial screen to display.
    ///   - path: The initial stack of pushed screens.
    public init(
        root: Screen? = nil,
        path: [Screen] = []
    ) {
        self.root = root
        self.path = path
    }

    var completePath: [Screen] {
        path + (presentation?.controller.completePath ?? [])
    }

    var topMostController: RootNavigationController<Screen> {
        if let presentation {
            return presentation.controller.topMostController
        }

        return self
    }

    /// Sets the root screen of the controller.
    /// - Parameter screen: The screen to set as root.
    /// - Note: This can only be called once, typically if the controller was initialized without a root.
    public func set(root screen: Screen) {
        precondition(self.root == nil)
        self.root = screen
    }
}

// MARK: - Private Methods
@_spi(Internal)
public extension RootNavigationController {
    func remove(
        index: Array<Screen>.Index,
        from controller: RootNavigationController,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            controller.presentation = nil
            controller.path.removeSubrange(index...)
        } completion: {
            completion()
        }
    }

    func removeAfter(
        index: Array<Screen>.Index,
        from controller: RootNavigationController,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            controller.presentation = nil
            controller.path.removeSubrange(controller.path.index(after: index)...)
        } completion: {
            completion()
        }
    }

    func dismiss(
        from controller: RootNavigationController,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            controller.presentation = nil
        } completion: {
            completion()
        }
    }

    func dismiss(
        to controller: RootNavigationController,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            controller.presentation = nil
            controller.path.removeAll()
        } completion: {
            completion()
        }
    }

    func push(
        screen: Screen,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            topMostController.path.append(screen)
        } completion: {
            completion()
        }
    }

    func present(
        screen: Screen,
        style: PresentationStyle,
        dismissable: Bool,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        if let presentation {
            presentation.controller.present(
                screen: screen,
                style: style,
                dismissable: dismissable,
                animated: animated,
                completion: completion
            )
        } else {
            let controller = PresentedNavigationController(
                root: screen,
                allowsInteractiveDismiss: dismissable
            )

            Transaction.conditionalyDisableAnimations(animated: animated) {
                switch style {
                case .sheet: self.presentation = .sheet(controller)

                #if !os(watchOS)
                case .popover: self.presentation = .popover(controller)
                #endif

                #if !os(macOS)
                case .cover: self.presentation = .cover(controller)
                #endif
                }
            } completion: {
                completion()
            }
        }
    }

    @_spi(Internal)
    func location<Element>(
        of element: Element,
        equals: (Screen, Element) -> Bool
    ) -> ElementLocationResult? {
        if let index = path.firstIndex(where: { equals($0, element) }) {
            return .index(controller: self, index: index)
        }

        if let presentation, let root = presentation.controller.root, equals(root, element) {
            return .root(parentController: self)
        }

        return presentation?.controller.location(of: element, equals: equals)
    }
}
