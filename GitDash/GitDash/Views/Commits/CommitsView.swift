//
//  CommitsView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct CommitsView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var selectedCommit: GitCommit?
    @State private var searchText = ""

    var filteredCommits: [GitCommit] {
        if searchText.isEmpty {
            return viewModel.commits
        }
        return viewModel.commits.filter {
            $0.message.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText) ||
            $0.shortHash.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search commits...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(8)

                    Button(action: { viewModel.loadRepositoryData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(.trailing, 8)
                }

                Divider()

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredCommits, selection: $selectedCommit) { commit in
                        CommitRow(commit: commit)
                            .tag(commit)
                    }
                    .listStyle(.inset)
                }
            }
            .frame(minWidth: 400)

            if let commit = selectedCommit {
                CommitDetailView(commit: commit)
            } else {
                VStack {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a commit to view details")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Commits")
    }
}

struct CommitRow: View {
    let commit: GitCommit

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CommitGraphNode(commit: commit)

            VStack(alignment: .leading, spacing: 4) {
                Text(commit.message.components(separatedBy: "\n").first ?? "")
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(commit.shortHash)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)

                    Text(commit.author)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(commit.date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !commit.refs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(commit.refs, id: \.self) { ref in
                                RefBadge(ref: ref)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CommitGraphNode: View {
    let commit: GitCommit

    var body: some View {
        ZStack {
            Circle()
                .fill(nodeColor)
                .frame(width: 10, height: 10)

            Circle()
                .stroke(nodeColor.opacity(0.3), lineWidth: 2)
                .frame(width: 16, height: 16)
        }
        .frame(width: 20)
    }

    private var nodeColor: Color {
        if commit.refs.contains(where: { $0.contains("HEAD") }) {
            return .green
        } else if commit.refs.contains(where: { $0.contains("main") || $0.contains("master") }) {
            return .blue
        } else if !commit.refs.isEmpty {
            return .orange
        }
        return .gray
    }
}

struct RefBadge: View {
    let ref: String

    var body: some View {
        Text(ref)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(4)
    }

    private var badgeColor: Color {
        if ref.contains("HEAD") {
            return .green
        } else if ref.contains("main") || ref.contains("master") {
            return .blue
        } else if ref.contains("origin") {
            return .purple
        }
        return .orange
    }
}
