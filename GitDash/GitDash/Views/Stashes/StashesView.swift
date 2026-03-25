//
//  StashesView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct StashesView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var showingCreateStash = false
    @State private var stashMessage = ""
    @State private var stashToDelete: GitStash?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stashed Changes")
                    .font(.headline)

                Spacer()

                Button(action: { showingCreateStash = true }) {
                    Label("Stash Changes", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.fileStatuses.isEmpty)
            }
            .padding()

            Divider()

            if viewModel.stashes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No stashed changes")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.stashes) { stash in
                        StashRow(
                            stash: stash,
                            onApply: { viewModel.applyStash(stash.id) },
                            onPop: { viewModel.popStash(stash.id) },
                            onDrop: {
                                stashToDelete = stash
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Stashes")
        .sheet(isPresented: $showingCreateStash) {
            CreateStashSheet(
                message: $stashMessage,
                onCreate: {
                    viewModel.createStash(message: stashMessage.isEmpty ? nil : stashMessage)
                    stashMessage = ""
                    showingCreateStash = false
                },
                onCancel: {
                    stashMessage = ""
                    showingCreateStash = false
                }
            )
        }
        .alert("Drop Stash", isPresented: $showDeleteConfirmation, presenting: stashToDelete) { stash in
            Button("Cancel", role: .cancel) { }
            Button("Drop", role: .destructive) {
                viewModel.dropStash(stash.id)
            }
        } message: { stash in
            Text("Are you sure you want to permanently delete this stash?")
        }
    }
}

struct StashRow: View {
    let stash: GitStash
    let onApply: () -> Void
    let onPop: () -> Void
    let onDrop: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stash.message)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("stash@{\(stash.index)}")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)

                    Text(stash.branch)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(stash.date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onApply) {
                    Image(systemName: "tray.and.arrow.up")
                }
                .buttonStyle(.plain)
                .help("Apply")

                Button(action: onPop) {
                    Image(systemName: "tray.and.arrow.up.fill")
                }
                .buttonStyle(.plain)
                .help("Pop")

                Button(action: onDrop) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .help("Drop")
            }
        }
        .padding(.vertical, 4)
    }
}

struct CreateStashSheet: View {
    @Binding var message: String
    let onCreate: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Stash Changes")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Message (optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Stash message", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
            }

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)

                Button("Stash", action: onCreate)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
    }
}
