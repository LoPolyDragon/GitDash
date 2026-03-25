//
//  ContentView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SidebarItem = .commits

    var body: some View {
        Group {
            if let viewModel = appState.repositoryViewModel {
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                } detail: {
                    DetailView(selectedTab: selectedTab)
                        .environmentObject(viewModel)
                }
            } else {
                WelcomeView()
            }
        }
    }
}

enum SidebarItem: String, CaseIterable, Identifiable {
    case commits = "Commits"
    case changes = "Changes"
    case branches = "Branches"
    case stashes = "Stashes"
    case blame = "Blame"
    case stats = "Statistics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .commits: return "clock.arrow.circlepath"
        case .changes: return "doc.text.magnifyingglass"
        case .branches: return "arrow.triangle.branch"
        case .stashes: return "tray.full"
        case .blame: return "person.crop.circle.badge.questionmark"
        case .stats: return "chart.bar"
        }
    }
}
