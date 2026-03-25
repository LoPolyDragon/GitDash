//
//  GitDashApp.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

@main
struct GitDashApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .commands {
            GitDashCommands()
        }
    }
}
