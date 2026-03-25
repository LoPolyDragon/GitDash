//
//  RepositoryStats.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct ContributorStats: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let commitCount: Int
}

struct CommitFrequency: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct RepositoryStats {
    let totalCommits: Int
    let totalBranches: Int
    let contributors: [ContributorStats]
    let commitFrequency: [CommitFrequency]
}
