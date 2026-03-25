//
//  CommitDetailView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct CommitDetailView: View {
    let commit: GitCommit
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var diffContent = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(commit.message)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                        Text(commit.author)
                    }
                    .font(.subheadline)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(commit.date, style: .date)
                    }
                    .font(.subheadline)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(commit.date, style: .time)
                    }
                    .font(.subheadline)
                }
                .foregroundColor(.secondary)

                Text("Commit: \(commit.id)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)

                if !commit.parentHashes.isEmpty {
                    Text("Parents: \(commit.parentHashes.joined(separator: ", "))")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }
            .padding()

            Divider()

            ScrollView {
                Text(diffContent)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            loadDiff()
        }
        .onChange(of: commit.id) { _ in
            loadDiff()
        }
    }

    private func loadDiff() {
        if let diff = viewModel.getCommitDiff(commit.id) {
            diffContent = diff
        }
    }
}
