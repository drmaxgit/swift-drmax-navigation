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

public extension RootNavigationController {
    /// Navigates to a new screen.
    /// - Parameters:
    ///   - screen: The destination screen.
    ///   - style: The navigation style (push, sheet, cover, popover). Defaults to `.push`.
    ///   - animated: Whether to animate the transition. Defaults to `true`.
    ///   - completion: A closure to execute after the transition finishes.
    func navigate(
        to screen: Screen,
        style: NavigationStyle = .push,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        switch style {
        case .push: push(screen: screen, animated: animated, completion: completion)

        case let .sheet(dismissable): present(
            screen: screen,
            style: .sheet,
            dismissable: dismissable,
            animated: animated,
            completion: completion
        )

        #if !os(watchOS)
        case let .popover(dismissable): present(
            screen: screen,
            style: .popover,
            dismissable: dismissable,
            animated: animated,
            completion: completion
        )
        #endif

        #if !os(macOS)
        case let .cover(dismissable): present(
            screen: screen,
            style: .cover,
            dismissable: dismissable,
            animated: animated,
            completion: completion
        )
        #endif
        }
    }

    /// Pops all screens and dismisses all presentations, returning to the root screen.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func popToRoot(
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            path.removeAll()
            presentation = nil
        } completion: {
            completion()
        }
    }

    /// Pops the topmost screen or dismisses the topmost presentation.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func pop(
        completion: @escaping () -> Void = {}
    ) {
        if let presentation {
            if presentation.controller.path.isEmpty && presentation.controller.presentation == nil {
                let animated = presentation.controller.root.wasNavigatedWithAnimation
                
                Transaction.conditionalyDisableAnimations(animated: animated) {
                    self.presentation = nil
                } completion: {
                    completion()
                }
            } else {
                presentation.controller.pop(completion: completion)
            }
        } else {
            guard let animated = path.last?.wasNavigatedWithAnimation else {
                completion()
                return
            }
            
            Transaction.conditionalyDisableAnimations(animated: animated) {
                path.removeLast()
            } completion: {
                completion()
            }
        }
    }

    /// Pops screens until the specified element is at the top, then removes it too.
    /// - Parameters:
    ///   - element: The element to pop before.
    ///   - completion: A closure to execute after the transition finishes.
    func popBefore(
        _ element: Screen,
        completion: @escaping () -> Void = {}
    ) {
        switch location(
            of: element,
            equals: { $0 == $1 }
        ) {
        case let .index(controller, index): removeFrom(
            index: index,
            from: controller,
            completion: completion
        )
        case let .root(parentController): dismiss(
            from: parentController,
            completion: completion
        )
        case nil: completion()
        }
    }

    /// Pops screens until the specified element is at the top.
    /// - Parameters:
    ///   - element: The destination element.
    ///   - completion: A closure to execute after the transition finishes.
    func popTo(
        _ element: Screen,
        completion: @escaping () -> Void = {}
    ) {
        switch location(
            of: element,
            equals: { $0 == $1 }
        ) {
        case let .index(controller, index): removeAfter(
            index: index,
            from: controller,
            completion: completion
        )
        case let .root(parentController): dismiss(
            to: parentController,
            completion: completion
        )
        case nil: completion()
        }
    }

    /// Pops all screens in the topmost presentation, but keeps the presentation itself.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func popToPresentationRoot(
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        Transaction.conditionalyDisableAnimations(animated: animated) {
            topMostController.path.removeAll()
        } completion: {
            completion()
        }
    }
}
