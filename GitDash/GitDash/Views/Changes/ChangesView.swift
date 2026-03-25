//
//  ChangesView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct ChangesView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var selectedFile: GitFileStatus?
    @State private var commitMessage = ""
    @State private var diffViewMode: DiffViewMode = .unified

    enum DiffViewMode {
        case unified
        case sideBySide
    }

    var stagedFiles: [GitFileStatus] {
        viewModel.fileStatuses.filter { $0.isStaged }
    }

    var unstagedFiles: [GitFileStatus] {
        viewModel.fileStatuses.filter { !$0.isStaged }
    }

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Branch: \(viewModel.currentBranch)")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack {
                        TextField("Commit message", text: $commitMessage, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)

                        Button(action: performCommit) {
                            Label("Commit", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(stagedFiles.isEmpty || commitMessage.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                Divider()

                List(selection: $selectedFile) {
                    if !stagedFiles.isEmpty {
                        Section("Staged Changes") {
                            ForEach(stagedFiles) { file in
                                FileStatusRow(file: file, onStage: {
                                    viewModel.unstageFile(file.path)
                                }, isStaged: true)
                                .tag(file)
                            }
                        }
                    }

                    if !unstagedFiles.isEmpty {
                        Section("Unstaged Changes") {
                            ForEach(unstagedFiles) { file in
                                FileStatusRow(file: file, onStage: {
                                    viewModel.stageFile(file.path)
                                }, isStaged: false)
                                .tag(file)
                            }
                        }
                    }

                    if stagedFiles.isEmpty && unstagedFiles.isEmpty {
                        Section {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No changes")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                }
                .listStyle(.inset)
            }
            .frame(minWidth: 350)

            if let file = selectedFile {
                VStack(spacing: 0) {
                    HStack {
                        Picker("View Mode", selection: $diffViewMode) {
                            Text("Unified").tag(DiffViewMode.unified)
                            Text("Side-by-Side").tag(DiffViewMode.sideBySide)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 250)

                        Spacer()

                        Text(file.path)
                            .font(.headline)
                    }
                    .padding()

                    Divider()

                    if diffViewMode == .unified {
                        UnifiedDiffView(file: file)
                    } else {
                        SideBySideDiffView(file: file)
                    }
                }
            } else {
                VStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a file to view diff")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Changes")
    }

    private func performCommit() {
        viewModel.commit(message: commitMessage)
        commitMessage = ""
    }
}

struct FileStatusRow: View {
    let file: GitFileStatus
    let onStage: () -> Void
    let isStaged: Bool

    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .frame(width: 20)

            Text(file.path)
                .font(.system(.body, design: .monospaced))

            Spacer()

            Button(action: onStage) {
                Image(systemName: isStaged ? "minus.circle" : "plus.circle")
            }
            .buttonStyle(.plain)
        }
    }

    private var statusIcon: String {
        switch file.statusType {
        case .modified: return "pencil.circle.fill"
        case .added: return "plus.circle.fill"
        case .deleted: return "trash.circle.fill"
        case .renamed: return "arrow.right.circle.fill"
        case .untracked: return "questionmark.circle.fill"
        default: return "circle.fill"
        }
    }

    private var statusColor: Color {
        switch file.statusType {
        case .modified: return .blue
        case .added: return .green
        case .deleted: return .red
        case .renamed: return .orange
        case .untracked: return .gray
        default: return .secondary
        }
    }
}
