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

/// Represents an active presentation in the navigation tree.
public enum Presentation<Screen: Hashable> {
    case sheet(PresentedNavigationController<Screen>)

    #if !os(watchOS)
    case popover(PresentedNavigationController<Screen>)
    #endif

    #if !os(macOS)
    case cover(PresentedNavigationController<Screen>)
    #endif

    /// The ``PresentedNavigationController`` associated with this presentation.
    public var controller: PresentedNavigationController<Screen> {
        switch self {
        case let .sheet(controller): controller

        #if !os(watchOS)
        case let .popover(controller): controller
        #endif

        #if !os(macOS)
        case let .cover(controller): controller
        #endif
        }
    }
}
