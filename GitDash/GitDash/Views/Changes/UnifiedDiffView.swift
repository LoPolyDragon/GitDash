//
//  UnifiedDiffView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct UnifiedDiffView: View {
    let file: GitFileStatus
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var diff: GitDiff?

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if let diff = diff {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(diff.hunks) { hunk in
                        ForEach(hunk.lines) { line in
                            DiffLineView(line: line)
                        }
                    }
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

struct DiffLineView: View {
    let line: DiffLine

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 4) {
                Text(line.oldLineNumber.map { "\($0)" } ?? " ")
                    .frame(minWidth: 40, alignment: .trailing)
                    .foregroundColor(.secondary)

                Text(line.newLineNumber.map { "\($0)" } ?? " ")
                    .frame(minWidth: 40, alignment: .trailing)
                    .foregroundColor(.secondary)
            }
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

    private var backgroundColor: Color {
        switch line.type {
        case .addition:
            return Color.green.opacity(0.15)
        case .deletion:
            return Color.red.opacity(0.15)
        case .hunkHeader:
            return Color.blue.opacity(0.1)
        default:
            return Color.clear
        }
    }

    private var textColor: Color {
        switch line.type {
        case .addition:
            return .green
        case .deletion:
            return .red
        case .hunkHeader:
            return .blue
        default:
            return .primary
        }
    }
}
