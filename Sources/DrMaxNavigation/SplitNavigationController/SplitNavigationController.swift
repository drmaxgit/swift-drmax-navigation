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

/// A ``RootNavigationController`` for two-column layouts built on `NavigationSplitView`.
///
/// The sidebar column is a selectable list of screens whose selection is owned by this controller.
/// The detail column is a navigation stack rooted at the selected screen, driven by the inherited
/// ``RootNavigationController/path`` and ``RootNavigationController/presentation``.
///
/// Changing the selection always starts a fresh detail stack: the path is cleared and any
/// presentation is dismissed. In compact width the split view collapses into a single stack,
/// with the sidebar at its root and the selected screen pushed on top of it.
///
/// ```swift
/// let controller = SplitNavigationController<MailScreen>()
///
/// controller.select(.mailbox(id: inbox.id)) {
///     controller.navigate(to: .message(id: "42"))
/// }
/// ```
@Observable
public final class SplitNavigationController<Screen: Hashable>: RootNavigationController<Screen> {
    /// The screen selected in the sidebar, which is the root of the detail column.
    public internal(set) var selection: Screen?

    /// The visibility of the sidebar column in regular width.
    public var columnVisibility: NavigationSplitViewVisibility

    /// The column shown when the split view is collapsed into a single stack.
    var preferredCompactColumn: NavigationSplitViewColumn

    /// The complete path to use when searching for children, starting with the selection.
    override var completePath: [NavigationElement<Screen>] {
        let selection = selection.map { NavigationElement(wrapped: $0, wasNavigatedWithAnimation: false) }
        return [selection].compactMap { $0 } + super.completePath
    }

    override func rootLocation<Element>(
        of element: Element,
        equals: (Screen, Element) -> Bool
    ) -> ElementLocationResult? {
        if let selection, equals(selection, element) {
            return .selection(controller: self)
        }

        return nil
    }

    /// Creates a new split navigation controller.
    /// - Parameters:
    ///   - selection: The initially selected sidebar screen.
    ///   - path: The initial detail stack, pushed on top of the selected screen.
    ///   - columnVisibility: The initial visibility of the sidebar column.
    public init(
        selection: Screen? = nil,
        path: [Screen] = [],
        columnVisibility: NavigationSplitViewVisibility = .automatic
    ) {
        self.selection = selection
        self.columnVisibility = columnVisibility
        self.preferredCompactColumn = selection == nil ? .sidebar : .detail
        super.init(path: path)
    }
}

// MARK: - Public API
public extension SplitNavigationController {
    /// Selects a screen in the sidebar, replacing the detail column with a fresh stack rooted at it.
    ///
    /// Selecting a different screen clears the detail path and dismisses any presentation.
    /// Selecting the current screen leaves the detail column untouched.
    /// Selection changes are never animated.
    /// - Parameters:
    ///   - selection: The screen to select, or `nil` to clear the selection.
    ///   - completion: A closure to execute after the transition finishes.
    func select(
        _ selection: Screen?,
        completion: @escaping () -> Void = {}
    ) {
        guard selection != self.selection else {
            completion()
            return
        }

        Transaction.withoutAnimation {
            replaceSelection(with: selection)
            preferredCompactColumn = selection == nil ? .sidebar : .detail
        } completion: {
            completion()
        }
    }

    /// Clears the sidebar selection, returning to the sidebar in compact width.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func deselect(
        completion: @escaping () -> Void = {}
    ) {
        select(nil, completion: completion)
    }
}

// MARK: - Internal Methods
@_spi(Internal)
public extension SplitNavigationController {
    /// Clears the selection together with the detail column stacked on top of it.
    func removeSelection(
        completion: @escaping () -> Void
    ) {
        select(nil, completion: completion)
    }

    /// Moves the selection to `screen`, which shares its case with the current selection,
    /// instead of nesting `screen` in the detail column.
    ///
    /// Reselecting the current selection clears the detail column stacked on top of it.
    func reselect(
        _ screen: Screen,
        completion: @escaping () -> Void
    ) {
        if screen == selection {
            removeAfterSelection(completion: completion)
        } else {
            select(screen, completion: completion)
        }
    }

    /// Clears the detail column stacked on top of the selection, keeping the selection.
    func removeAfterSelection(
        completion: @escaping () -> Void
    ) {
        let animated = path.first?.wasNavigatedWithAnimation
            ?? presentation?.controller.root.wasNavigatedWithAnimation
            ?? true

        Transaction.conditionalyDisableAnimations(animated: animated) {
            presentation = nil
            path.removeAll()
        } completion: {
            completion()
        }
    }
}

// MARK: - Private Methods
private extension SplitNavigationController {
    func replaceSelection(with selection: Screen?) {
        self.selection = selection
        presentation = nil
        path.removeAll()
    }
}
