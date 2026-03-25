//
//  GitRepository.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct GitRepository: Identifiable, Equatable {
    let id = UUID()
    let path: URL
    var name: String {
        path.lastPathComponent
    }

    static func == (lhs: GitRepository, rhs: GitRepository) -> Bool {
        lhs.path == rhs.path
    }
}
