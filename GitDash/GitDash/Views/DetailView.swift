//
//  DetailView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct DetailView: View {
    let selectedTab: SidebarItem

    var body: some View {
        Group {
            switch selectedTab {
            case .commits:
                CommitsView()
            case .changes:
                ChangesView()
            case .branches:
                BranchesView()
            case .stashes:
                StashesView()
            case .blame:
                BlameView()
            case .stats:
                StatsView()
            }
        }
    }
}
