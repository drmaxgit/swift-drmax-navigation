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

extension RootNavigationController {
    @_spi(Internal)
    public var sheet: PresentedNavigationController<Screen>? {
        get {
            if case let .sheet(controller) = presentation {
                return controller
            }

            return nil
        }
        set {
            guard newValue == nil else {
                preconditionFailure("newValue must be nil when setting from SwiftUI Binding")
            }

            presentation = nil
        }
    }

    #if !os(macOS)
    @_spi(Internal)
    public var cover: PresentedNavigationController<Screen>? {
        get {
            if case let .cover(controller) = presentation {
                return controller
            }

            return nil
        }
        set {
            guard newValue == nil else {
                preconditionFailure("newValue must be nil when setting from SwiftUI Binding")
            }

            presentation = nil
        }
    }
    #endif

    #if !os(watchOS)
    @_spi(Internal)
    public var popover: PresentedNavigationController<Screen>? {
        get {
            if case let .popover(controller) = presentation {
                return controller
            }

            return nil
        }
        set {
            guard newValue == nil else {
                preconditionFailure("newValue must be nil when setting from SwiftUI Binding")
            }

            presentation = nil
        }
    }
    #endif
}
