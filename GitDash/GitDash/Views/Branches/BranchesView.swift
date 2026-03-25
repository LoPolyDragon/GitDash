//
//  BranchesView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI

struct BranchesView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var showingCreateBranch = false
    @State private var newBranchName = ""
    @State private var branchToDelete: GitBranch?
    @State private var showDeleteConfirmation = false

    var localBranches: [GitBranch] {
        viewModel.branches.filter { !$0.isRemote }
    }

    var remoteBranches: [GitBranch] {
        viewModel.branches.filter { $0.isRemote }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Current: \(viewModel.currentBranch)")
                    .font(.headline)

                Spacer()

                Button(action: { showingCreateBranch = true }) {
                    Label("New Branch", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            List {
                Section("Local Branches") {
                    ForEach(localBranches) { branch in
                        BranchRow(
                            branch: branch,
                            onCheckout: { viewModel.switchBranch(name: branch.name) },
                            onDelete: {
                                branchToDelete = branch
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }

                if !remoteBranches.isEmpty {
                    Section("Remote Branches") {
                        ForEach(remoteBranches) { branch in
                            BranchRow(branch: branch, onCheckout: nil, onDelete: nil)
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationTitle("Branches")
        .sheet(isPresented: $showingCreateBranch) {
            CreateBranchSheet(
                branchName: $newBranchName,
                onCreate: {
                    viewModel.createBranch(name: newBranchName)
                    newBranchName = ""
                    showingCreateBranch = false
                },
                onCancel: {
                    newBranchName = ""
                    showingCreateBranch = false
                }
            )
        }
        .alert("Delete Branch", isPresented: $showDeleteConfirmation, presenting: branchToDelete) { branch in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteBranch(name: branch.name)
            }
        } message: { branch in
            Text("Are you sure you want to delete '\(branch.name)'?")
        }
    }
}

struct BranchRow: View {
    let branch: GitBranch
    let onCheckout: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: branch.isCurrent ? "checkmark.circle.fill" : "circle")
                .foregroundColor(branch.isCurrent ? .green : .secondary)

            VStack(alignment: .leading) {
                Text(branch.name)
                    .font(.headline)

                if branch.isRemote {
                    Text("Remote")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if !branch.isCurrent && !branch.isRemote {
                HStack(spacing: 8) {
                    if let onCheckout = onCheckout {
                        Button(action: onCheckout) {
                            Image(systemName: "arrow.right.circle")
                        }
                        .buttonStyle(.plain)
                        .help("Checkout")
                    }

                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                        .help("Delete")
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CreateBranchSheet: View {
    @Binding var branchName: String
    let onCreate: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Branch")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Branch name", text: $branchName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)

                Button("Create", action: onCreate)
                    .keyboardShortcut(.defaultAction)
                    .disabled(branchName.isEmpty)
            }
        }
        .padding(30)
    }
}
