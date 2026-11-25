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

extension RootNavigationController where Screen: CasePathable {
    /// Pops screens until a screen matching the specified case is at the top, then removes it too.
    /// - Parameters:
    ///   - element: A case key path to the destination screen case.
    ///   - completion: A closure to execute after the transition finishes.
    public func popBefore(
        _ element: PartialCaseKeyPath<Screen>,
        completion: @escaping () -> Void = {}
    ) {
        switch location(
            of: element,
            equals: { $0.is($1) }
        ) {
        case let .index(controller, index): removeFrom(
            index: index,
            from: controller,
            completion: completion
        )
        case let .root(controller): dismiss(
            from: controller,
            completion: completion
        )
        case let .selection(controller): controller.removeSelection(
            completion: completion
        )
        case nil: completion()
        }
    }

    /// Pops screens until a screen matching the specified case is at the top.
    /// - Parameters:
    ///   - completion: A closure to execute after the transition finishes.
    public func popTo(
        _ element: PartialCaseKeyPath<Screen>,
        completion: @escaping () -> Void = {}
    ) {
        switch location(
            of: element,
            equals: { $0.is($1) }
        ) {
        case let .index(controller, index): removeAfter(
            index: index,
            from: controller,
            completion: completion
        )
        case let .root(controller): dismiss(
            to: controller,
            completion: completion
        )
        case let .selection(controller): controller.removeAfterSelection(
            completion: completion
        )
        case nil: completion()
        }
    }
}
