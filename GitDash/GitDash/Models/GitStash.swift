//
//  GitStash.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct GitStash: Identifiable, Equatable {
    let id: String // stash@{n}
    let index: Int
    let message: String
    let branch: String
    let date: Date

    static func == (lhs: GitStash, rhs: GitStash) -> Bool {
        lhs.id == rhs.id
    }
}
