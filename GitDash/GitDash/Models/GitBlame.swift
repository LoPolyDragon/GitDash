//
//  GitBlame.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

struct GitBlameLine: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let content: String
    let commitHash: String
    let author: String
    let date: Date
}
