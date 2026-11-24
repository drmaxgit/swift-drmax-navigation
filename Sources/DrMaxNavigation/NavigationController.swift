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

/// A navigation controller scoped to a subset of a parent screen enum.
///
/// Use this when a feature/section owns only a slice of the parent `Screen` enum.
/// It embeds `Child` values into `Parent` via a `CaseKeyPath` before
/// forwarding every navigation call to the underlying ``RootNavigationController``.
///
/// ```swift
/// @CasePathable
/// enum AppScreen: Hashable {
///     case dashboard(DashboardScreen)
///     case catalog(CatalogScreen)
/// }
///
/// // Child controller scoped to DashboardScreen only
/// let child = NavigationController(
///     parent: appNavigationController,
///     casePath: \.dashboard
/// )
/// child.navigate(to: .detail(id: "42"))    // pushes AppScreen.dashboard(.detail(id: "42"))
/// ```
public struct NavigationController<Parent: Hashable, Child: Hashable> {
    public weak var parent: RootNavigationController<Parent>?

    private let casePath: CaseKeyPath<Parent, Child>

    init(
        parent: RootNavigationController<Parent>,
        casePath: CaseKeyPath<Parent, Child>
    ) {
        self.parent = parent
        self.casePath = casePath
    }
}

// MARK: - Public API
public extension NavigationController {
    /// Navigates to a new screen in the scoped child enum.
    /// - Parameters:
    ///   - screen: The destination screen in the child enum.
    ///   - style: The navigation style. Defaults to `.push`.
    ///   - animated: Whether to animate the transition. Defaults to `true`.
    ///   - completion: A closure to execute after the transition finishes.
    func navigate(
        to screen: Child,
        style: NavigationStyle = .push,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let parent else {
            completion()
            return
        }

        parent.navigate(to: casePath(screen), style: style, animated: animated, completion: completion)
    }

    /// Pops the topmost screen or dismisses the topmost presentation.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func pop(
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let parent else {
            completion()
            return
        }

        parent.pop(completion: completion)
    }

    /// Pops all screens and dismisses all presentations in the parent controller.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func popToRoot(
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let parent else {
            completion()
            return
        }

        parent.popToRoot(animated: animated, completion: completion)
    }

    /// Pops all screens in the topmost presentation.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    func popToPresentationRoot(
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let parent else {
            completion()
            return
        }

        parent.popToPresentationRoot(
            animated: animated,
            completion: completion
        )
    }
}

// MARK: - Public CasePathable API
public extension NavigationController where Child: CasePathable, Parent: CasePathable {
    /// Pops all screens until the screen that triggered this pullback is at the top, then removes it too.
    /// - Parameter animated: Whether to animate the transition. Defaults to `true`.
    func popToPullbackRoot(
        completion: @escaping () -> Void = {}
    ) {
        if let parent, let screen = parent.completePath.compactMap({ $0.wrapped[case: casePath] }).first {
            parent.popBefore(
                casePath(screen),
                completion: completion
            )
        } else {
            completion()
        }
    }

    /// Pops screens until the specified element in the child enum is at the top, then removes it too.
    /// - Parameters:
    ///   - element: The element to pop before.
    ///   - completion: A closure to execute after the transition finishes.
    func popBefore(
        _ element: PartialCaseKeyPath<Child>,
        completion: @escaping () -> Void = {}
    ) {
        if let parent, let screen = find(element) {
            parent.popBefore(
                casePath(screen),
                completion: completion
            )
        } else {
            completion()
        }
    }

    /// Pops screens until the specified element in the child enum is at the top.
    /// - Parameters:
    ///   - element: The destination element.
    ///   - completion: A closure to execute after the transition finishes.
    func popTo(
        _ element: PartialCaseKeyPath<Child>,
        completion: @escaping () -> Void = {}
    ) {
        if let parent, let screen = find(element) {
            parent.popTo(
                casePath(screen),
                completion: completion
            )
        } else {
            completion()
        }
    }
}

// MARK: - Private CasePathable Methods
private extension NavigationController where Child: CasePathable, Parent: CasePathable {
    func find(
        _ element: PartialCaseKeyPath<Child>
    ) -> Child? {
        parent?
            .completePath
            .compactMap { $0.wrapped[case: casePath] }
            .first { $0.is(element) }
    }
}

extension NavigationController where Parent: CaseEquatable {
    public func navigate(
        to screen: Child,
        style: NavigationStyle = .push,
        animated: Bool = true,
        allowsSameScreenNesting: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let parent else {
            completion()
            return
        }

        parent.navigate(
            to: casePath(screen),
            style: style,
            animated: animated,
            allowsSameScreenNesting: allowsSameScreenNesting,
            completion: completion
        )
    }
}
