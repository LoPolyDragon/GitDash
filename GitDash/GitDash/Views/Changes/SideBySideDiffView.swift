//
//  SideBySideDiffView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct SideBySideDiffView: View {
    let file: GitFileStatus
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var diff: GitDiff?

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if let diff = diff {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Original")
                            .font(.headline)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.separatorColor))

                        ForEach(diff.hunks) { hunk in
                            ForEach(hunk.lines.filter { $0.type != .addition }) { line in
                                SideBySideDiffLineView(line: line, isOld: true)
                            }
                        }
                    }
                    .frame(minWidth: 400)

                    Divider()

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Modified")
                            .font(.headline)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.separatorColor))

                        ForEach(diff.hunks) { hunk in
                            ForEach(hunk.lines.filter { $0.type != .deletion }) { line in
                                SideBySideDiffLineView(line: line, isOld: false)
                            }
                        }
                    }
                    .frame(minWidth: 400)
                }
                .padding()
            } else {
                Text("No diff available")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .background(Color(NSColor.textBackgroundColor))
        .onAppear {
            loadDiff()
        }
        .onChange(of: file.path) { _ in
            loadDiff()
        }
    }

    private func loadDiff() {
        diff = viewModel.getDiff(for: file.path, staged: file.isStaged)
    }
}

struct SideBySideDiffLineView: View {
    let line: DiffLine
    let isOld: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(lineNumber)
                .frame(minWidth: 40, alignment: .trailing)
                .foregroundColor(.secondary)
                .font(.system(.caption, design: .monospaced))

            Text(line.content)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 8)
        .background(backgroundColor)
    }

    private var lineNumber: String {
        if isOld {
            return line.oldLineNumber.map { "\($0)" } ?? " "
        } else {
            return line.newLineNumber.map { "\($0)" } ?? " "
        }
    }

    private var backgroundColor: Color {
        switch line.type {
        case .addition:
            return isOld ? Color.clear : Color.green.opacity(0.15)
        case .deletion:
            return isOld ? Color.red.opacity(0.15) : Color.clear
        case .hunkHeader:
            return Color.blue.opacity(0.1)
        default:
            return Color.clear
        }
    }

    private var textColor: Color {
        switch line.type {
        case .addition:
            return isOld ? .primary : .green
        case .deletion:
            return isOld ? .red : .primary
        case .hunkHeader:
            return .blue
        default:
            return .primary
        }
    }
}
