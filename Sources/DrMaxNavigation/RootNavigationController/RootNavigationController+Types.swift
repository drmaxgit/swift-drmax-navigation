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

@_spi(Internal)
public extension RootNavigationController {
    /// Supported presentation styles.
    enum PresentationStyle {
        case sheet

        #if !os(watchOS)
        case popover
        #endif

        #if !os(macOS)
        case cover
        #endif
    }

    /// The result of searching for an element's location in the navigation tree.
    enum ElementLocationResult {
        /// The element was found at a specific index in a navigation stack.
        case index(controller: RootNavigationController, index: Array<Screen>.Index)
        /// The element was found as the root of a presented navigation tree.
        case root(parentController: RootNavigationController)
        /// The element was found as the selection of a split navigation controller.
        case selection(controller: SplitNavigationController<Screen>)
    }
}
