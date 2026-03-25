//
//  GitBranch.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct GitBranch: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let isCurrent: Bool
    let isRemote: Bool

    static func == (lhs: GitBranch, rhs: GitBranch) -> Bool {
        lhs.name == rhs.name && lhs.isRemote == rhs.isRemote
    }
}
