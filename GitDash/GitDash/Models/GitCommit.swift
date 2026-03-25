//
//  GitCommit.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct GitCommit: Identifiable, Equatable {
    let id: String // SHA hash
    let shortHash: String
    let author: String
    let email: String
    let date: Date
    let message: String
    let parentHashes: [String]
    let refs: [String]

    static func == (lhs: GitCommit, rhs: GitCommit) -> Bool {
        lhs.id == rhs.id
    }
}
