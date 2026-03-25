//
//  WelcomeView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("GitDash")
                .font(.system(size: 48, weight: .bold))

            Text("Visual Git Client for macOS")
                .font(.title3)
                .foregroundColor(.secondary)

            Button(action: openRepository) {
                Label("Open Repository", systemImage: "folder.badge.plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func openRepository() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a Git repository folder"

        if panel.runModal() == .OK, let url = panel.url {
            appState.openRepository(at: url)
        }
    }
}
