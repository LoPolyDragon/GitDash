//
//  RepositoryViewModel.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation
import SwiftUI

class RepositoryViewModel: ObservableObject {
    @Published var commits: [GitCommit] = []
    @Published var branches: [GitBranch] = []
    @Published var currentBranch: String = ""
    @Published var fileStatuses: [GitFileStatus] = []
    @Published var stashes: [GitStash] = []
    @Published var selectedCommit: GitCommit?
    @Published var selectedFile: GitFileStatus?
    @Published var stats: RepositoryStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let gitService: GitService

    init(repository: URL) {
        self.gitService = GitService(repositoryPath: repository)
        loadRepositoryData()
    }

    func loadRepositoryData() {
        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                async let commitsTask = loadCommits()
                async let branchesTask = loadBranches()
                async let statusTask = loadStatus()
                async let stashesTask = loadStashes()
                async let currentBranchTask = loadCurrentBranch()

                _ = try await (commitsTask, branchesTask, statusTask, stashesTask, currentBranchTask)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    @MainActor
    private func loadCommits() async throws {
        commits = try gitService.getCommitHistory(limit: 500)
    }

    @MainActor
    private func loadBranches() async throws {
        branches = try gitService.getBranches()
    }

    @MainActor
    private func loadStatus() async throws {
        fileStatuses = try gitService.getStatus()
    }

    @MainActor
    private func loadStashes() async throws {
        stashes = try gitService.getStashes()
    }

    @MainActor
    private func loadCurrentBranch() async throws {
        currentBranch = try gitService.getCurrentBranch()
    }

    // MARK: - Branch Operations

    func createBranch(name: String) {
        Task { @MainActor in
            do {
                try gitService.createBranch(name)
                try await loadBranches()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func switchBranch(name: String) {
        Task { @MainActor in
            do {
                try gitService.switchBranch(name)
                try await loadCurrentBranch()
                try await loadCommits()
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deleteBranch(name: String, force: Bool = false) {
        Task { @MainActor in
            do {
                try gitService.deleteBranch(name, force: force)
                try await loadBranches()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Staging Operations

    func stageFile(_ path: String) {
        Task { @MainActor in
            do {
                try gitService.stageFile(path)
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func unstageFile(_ path: String) {
        Task { @MainActor in
            do {
                try gitService.unstageFile(path)
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Commit Operations

    func commit(message: String) {
        Task { @MainActor in
            do {
                try gitService.commit(message: message)
                try await loadCommits()
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Stash Operations

    func createStash(message: String? = nil) {
        Task { @MainActor in
            do {
                try gitService.createStash(message: message)
                try await loadStashes()
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func applyStash(_ stashId: String) {
        Task { @MainActor in
            do {
                try gitService.applyStash(stashId)
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func popStash(_ stashId: String) {
        Task { @MainActor in
            do {
                try gitService.popStash(stashId)
                try await loadStashes()
                try await loadStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func dropStash(_ stashId: String) {
        Task { @MainActor in
            do {
                try gitService.dropStash(stashId)
                try await loadStashes()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Diff Operations

    func getDiff(for path: String, staged: Bool) -> GitDiff? {
        do {
            return try gitService.getDiff(for: path, staged: staged)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func getCommitDiff(_ commitHash: String) -> String? {
        do {
            return try gitService.getCommitDiff(commitHash)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Blame Operations

    func getBlame(for path: String) -> [GitBlameLine]? {
        do {
            return try gitService.getBlame(for: path)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Statistics

    func loadStatistics() {
        Task { @MainActor in
            do {
                stats = try gitService.getRepositoryStats()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
