//
//  GitDashCommands.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct GitDashCommands: Commands {
    @FocusedValue(\.appState) var appState: AppState?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Repository...") {
                openRepository()
            }
            .keyboardShortcut("o", modifiers: [.command])

            if appState?.currentRepository != nil {
                Button("Close Repository") {
                    appState?.closeRepository()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
        }

        CommandMenu("Repository") {
            Button("Refresh") {
                appState?.repositoryViewModel?.loadRepositoryData()
            }
            .keyboardShortcut("r", modifiers: [.command])
            .disabled(appState?.currentRepository == nil)

            Divider()

            Button("Create Branch...") {
                // Handle via view state
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])
            .disabled(appState?.currentRepository == nil)

            Button("Stash Changes...") {
                // Handle via view state
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            .disabled(appState?.currentRepository == nil)
        }
    }

    private func openRepository() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a Git repository folder"

        if panel.runModal() == .OK, let url = panel.url {
            appState?.openRepository(at: url)
        }
    }
}

struct AppStateFocusedValueKey: FocusedValueKey {
    typealias Value = AppState
}

extension FocusedValues {
    var appState: AppStateFocusedValueKey.Value? {
        get { self[AppStateFocusedValueKey.self] }
        set { self[AppStateFocusedValueKey.self] = newValue }
    }
}
