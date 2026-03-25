//
//  GitDiff.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

enum DiffLineType {
    case context
    case addition
    case deletion
    case header
    case hunkHeader
}

struct DiffLine: Identifiable {
    let id = UUID()
    let content: String
    let type: DiffLineType
    let oldLineNumber: Int?
    let newLineNumber: Int?
}

struct DiffHunk: Identifiable {
    let id = UUID()
    let header: String
    let oldStart: Int
    let oldCount: Int
    let newStart: Int
    let newCount: Int
    let lines: [DiffLine]
}

struct GitDiff {
    let filePath: String
    let hunks: [DiffHunk]
    let isStaged: Bool
}
