//
//  BlameView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct BlameView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var filePath = ""
    @State private var blameLines: [GitBlameLine] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("File path", text: $filePath)
                    .textFieldStyle(.roundedBorder)

                Button(action: loadBlame) {
                    Label("Show Blame", systemImage: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .disabled(filePath.isEmpty)
            }
            .padding()

            Divider()

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if blameLines.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Enter a file path to view blame information")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(blameLines) { line in
                            BlameLineView(line: line)
                        }
                    }
                    .padding()
                }
                .background(Color(NSColor.textBackgroundColor))
            }
        }
        .navigationTitle("Blame")
    }

    private func loadBlame() {
        isLoading = true
        if let blame = viewModel.getBlame(for: filePath) {
            blameLines = blame
        } else {
            blameLines = []
        }
        isLoading = false
    }
}

struct BlameLineView: View {
    let line: GitBlameLine

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(line.lineNumber)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(minWidth: 40, alignment: .trailing)

            Text(line.commitHash.prefix(8))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(minWidth: 70, alignment: .leading)

            Text(line.author)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(minWidth: 150, alignment: .leading)
                .lineLimit(1)

            Text(line.date, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(minWidth: 100, alignment: .leading)

            Text(line.content)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 8)
    }
}
