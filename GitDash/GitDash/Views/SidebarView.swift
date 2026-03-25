//
//  SidebarView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: SidebarItem
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(selection: $selectedTab) {
            ForEach(SidebarItem.allCases) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(appState.currentRepository?.name ?? "GitDash")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {}) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
}
