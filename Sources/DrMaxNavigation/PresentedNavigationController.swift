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

import Observation

/// A specialized ``RootNavigationController`` used for presented navigation trees (sheets, covers, popovers).
@Observable
public final class PresentedNavigationController<Screen: Hashable>: RootNavigationController<Screen> {
    /// Whether this presentation allows interactive dismissal (e.g., swiping down on a sheet).
    @_spi(Internal)
    public let allowsInteractiveDismiss: Bool

    /// The complete path to use when searching for children.
    override var completePath: [Screen] {
        [root].compactMap { $0 } + path + (presentation?.controller.completePath ?? [])
    }

    /// Creates a new presented navigation controller.
    /// - Parameters:
    ///   - root: The initial screen of the presentation.
    ///   - allowsInteractiveDismiss: Whether to allow interactive dismissal.
    init(
        root: Screen,
        allowsInteractiveDismiss: Bool
    ) {
        self.allowsInteractiveDismiss = allowsInteractiveDismiss

        super.init(
            root: root,
            path: []
        )
    }
}
