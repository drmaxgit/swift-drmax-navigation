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

/// A SwiftUI view that renders a ``SplitNavigationController`` as a two-column `NavigationSplitView`.
///
/// The sidebar lists `data` and is fully owned by the library: every row is identified by the screen it
/// selects, and selecting a row always goes through ``SplitNavigationController/select(_:animated:completion:)``.
/// Rows only describe their label, so there is no way to make a row select the wrong screen, or nothing at all.
///
/// The selected screen is the root of the detail column and, like every pushed or presented screen,
/// is rendered by `screen`.
///
/// ```swift
/// SplitNavigationControllerView(
///     controller: coordinator.controller,
///     data: mailboxes,
///     id: \.screen
/// ) { mailbox in
///     Label(mailbox.name, systemImage: mailbox.icon)
/// } placeholder: {
///     ContentUnavailableView("Select a Mailbox", systemImage: "tray")
/// } screen: { screen in
///     switch screen {
///     case let .mailbox(id): MailboxView(id: id)
///     case let .message(id): MessageView(id: id)
///     }
/// }
/// ```
public struct SplitNavigationControllerView<
    Screen: Hashable,
    ListContent: View,
    PlaceholderView: View,
    ScreenView: View
>: View {
    let controller: SplitNavigationController<Screen>
    let listContent: () -> ListContent
    let placeholder: () -> PlaceholderView
    let screen: (Screen) -> ScreenView

    /// Creates a split navigation view.
    /// - Parameters:
    ///   - controller: The controller owning the selection and the detail navigation tree.
    ///   - data: The items listed in the sidebar.
    ///   - id: The key path to the screen an item selects.
    ///   - row: The sidebar row for an item.
    ///   - placeholder: The detail column content shown while nothing is selected.
    ///   - screen: The view for the selected screen and for screens pushed or presented from it.
    public init(
        controller: SplitNavigationController<Screen>,
        @ViewBuilder listContent: @escaping () -> ListContent,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView,
        @ViewBuilder screen: @escaping (Screen) -> ScreenView
    ) {
        self.controller = controller
        self.listContent = listContent
        self.placeholder = placeholder
        self.screen = screen
    }

    public var body: some View {
        @Bindable var controller = controller

        NavigationSplitView(
            columnVisibility: $controller.columnVisibility,
            preferredCompactColumn: $controller.preferredCompactColumn
        ) {
            List(selection: selection) {
                listContent()
            }
        } detail: {
            NavigationStack(path: $controller.path) {
                Group {
                    if let selection = controller.selection {
                        screen(selection)
                    } else {
                        placeholder()
                    }
                }
                .navigationDestination(for: NavigationElement<Screen>.self) {
                    screen($0.wrapped)
                }
            }
        }
        .presentations(of: controller, screen: screen)
    }

    /// Routes every selection change made by the sidebar through the controller.
    private var selection: Binding<Screen?> {
        Binding(
            get: { controller.selection },
            set: { controller.select($0) }
        )
    }
}
