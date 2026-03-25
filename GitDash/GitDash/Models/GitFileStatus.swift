//
//  GitFileStatus.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

enum GitFileStatusType: String {
    case modified = "M"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case untracked = "?"
    case unmerged = "U"
    case unknown = "X"

    init(from string: String) {
        switch string {
        case "M": self = .modified
        case "A": self = .added
        case "D": self = .deleted
        case "R": self = .renamed
        case "C": self = .copied
        case "?", "??": self = .untracked
        case "U", "UU", "AA", "DD": self = .unmerged
        default: self = .unknown
        }
    }
}

struct GitFileStatus: Identifiable, Equatable {
    let id = UUID()
    let path: String
    let statusType: GitFileStatusType
    let isStaged: Bool

    static func == (lhs: GitFileStatus, rhs: GitFileStatus) -> Bool {
        lhs.path == rhs.path && lhs.statusType == rhs.statusType && lhs.isStaged == rhs.isStaged
    }
}
