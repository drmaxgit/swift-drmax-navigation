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

@_spi(Testing)
public extension RootNavigationController {
    /// The current navigation path. Available for testing purposes only.
    var testPath: [NavigationElement<Screen>] { path }
    /// The current active presentation. Available for testing purposes only.
    var testPresentation: Presentation<Screen>? { presentation }
}
