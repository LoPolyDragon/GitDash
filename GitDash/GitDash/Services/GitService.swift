//
//  GitService.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation

class GitService {
    private let repositoryPath: URL

    init(repositoryPath: URL) {
        self.repositoryPath = repositoryPath
    }

    // MARK: - Process Execution

    private func executeGitCommand(_ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = repositoryPath

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if process.terminationStatus != 0 {
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw GitError.commandFailed(errorMessage)
        }

        return String(data: outputData, encoding: .utf8) ?? ""
    }

    // MARK: - Repository Operations

    func isValidRepository() -> Bool {
        do {
            _ = try executeGitCommand(["rev-parse", "--git-dir"])
            return true
        } catch {
            return false
        }
    }

    // MARK: - Commit History

    func getCommitHistory(limit: Int = 100) throws -> [GitCommit] {
        let format = "%H%n%h%n%an%n%ae%n%at%n%P%n%D%n%B%n--END--"
        let output = try executeGitCommand(["log", "--format=\(format)", "-n", "\(limit)", "--all"])

        return parseCommits(from: output)
    }

    private func parseCommits(from output: String) -> [GitCommit] {
        var commits: [GitCommit] = []
        let commitBlocks = output.components(separatedBy: "--END--\n").filter { !$0.isEmpty }

        for block in commitBlocks {
            let lines = block.components(separatedBy: "\n")
            guard lines.count >= 8 else { continue }

            let hash = lines[0]
            let shortHash = lines[1]
            let author = lines[2]
            let email = lines[3]
            let timestamp = TimeInterval(lines[4]) ?? 0
            let date = Date(timeIntervalSince1970: timestamp)
            let parents = lines[5].split(separator: " ").map(String.init)
            let refs = lines[6].isEmpty ? [] : lines[6].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let message = lines[7..<lines.count].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

            commits.append(GitCommit(
                id: hash,
                shortHash: shortHash,
                author: author,
                email: email,
                date: date,
                message: message,
                parentHashes: parents,
                refs: refs
            ))
        }

        return commits
    }

    // MARK: - Branch Operations

    func getBranches() throws -> [GitBranch] {
        let output = try executeGitCommand(["branch", "-a"])
        var branches: [GitBranch] = []

        for line in output.components(separatedBy: "\n") {
            guard !line.isEmpty else { continue }

            let isCurrent = line.hasPrefix("*")
            let branchName = line.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)

            if branchName.hasPrefix("remotes/") {
                let remoteName = branchName.replacingOccurrences(of: "remotes/", with: "")
                branches.append(GitBranch(name: remoteName, isCurrent: false, isRemote: true))
            } else {
                branches.append(GitBranch(name: branchName, isCurrent: isCurrent, isRemote: false))
            }
        }

        return branches
    }

    func createBranch(_ name: String) throws {
        _ = try executeGitCommand(["branch", name])
    }

    func switchBranch(_ name: String) throws {
        _ = try executeGitCommand(["checkout", name])
    }

    func deleteBranch(_ name: String, force: Bool = false) throws {
        let flag = force ? "-D" : "-d"
        _ = try executeGitCommand(["branch", flag, name])
    }

    func getCurrentBranch() throws -> String {
        try executeGitCommand(["branch", "--show-current"]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Status Operations

    func getStatus() throws -> [GitFileStatus] {
        let output = try executeGitCommand(["status", "--porcelain"])
        var files: [GitFileStatus] = []

        for line in output.components(separatedBy: "\n") {
            guard !line.isEmpty else { continue }

            let statusCode = String(line.prefix(2))
            let path = String(line.dropFirst(3))

            let indexStatus = String(statusCode.prefix(1))
            let workingStatus = String(statusCode.suffix(1))

            if indexStatus != " " && indexStatus != "?" {
                let type = GitFileStatusType(from: indexStatus)
                files.append(GitFileStatus(path: path, statusType: type, isStaged: true))
            }

            if workingStatus != " " {
                let type = GitFileStatusType(from: workingStatus)
                files.append(GitFileStatus(path: path, statusType: type, isStaged: false))
            }
        }

        return files
    }

    // MARK: - Staging Operations

    func stageFile(_ path: String) throws {
        _ = try executeGitCommand(["add", path])
    }

    func unstageFile(_ path: String) throws {
        _ = try executeGitCommand(["reset", "HEAD", path])
    }

    func stageHunk(_ path: String, hunkHeader: String) throws {
        // Interactive staging via patch mode
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["add", "-p", path]
        process.currentDirectoryURL = repositoryPath

        try process.run()
        process.waitUntilExit()
    }

    // MARK: - Commit Operations

    func commit(message: String) throws {
        _ = try executeGitCommand(["commit", "-m", message])
    }

    // MARK: - Diff Operations

    func getDiff(for path: String, staged: Bool = false) throws -> GitDiff {
        let args = staged ? ["diff", "--cached", path] : ["diff", path]
        let output = try executeGitCommand(args)

        return parseDiff(output: output, filePath: path, isStaged: staged)
    }

    func getCommitDiff(_ commitHash: String) throws -> String {
        try executeGitCommand(["show", commitHash])
    }

    private func parseDiff(output: String, filePath: String, isStaged: Bool) -> GitDiff {
        var hunks: [DiffHunk] = []
        let lines = output.components(separatedBy: "\n")

        var currentHunk: DiffHunk?
        var currentLines: [DiffLine] = []
        var oldLineNum = 0
        var newLineNum = 0

        for line in lines {
            if line.hasPrefix("@@") {
                if let hunk = currentHunk {
                    hunks.append(DiffHunk(
                        header: hunk.header,
                        oldStart: hunk.oldStart,
                        oldCount: hunk.oldCount,
                        newStart: hunk.newStart,
                        newCount: hunk.newCount,
                        lines: currentLines
                    ))
                    currentLines = []
                }

                let hunkHeader = line
                let pattern = #"@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    let oldStart = Int((line as NSString).substring(with: match.range(at: 1))) ?? 0
                    let oldCount = Int((line as NSString).substring(with: match.range(at: 2))) ?? 1
                    let newStart = Int((line as NSString).substring(with: match.range(at: 3))) ?? 0
                    let newCount = Int((line as NSString).substring(with: match.range(at: 4))) ?? 1

                    currentHunk = DiffHunk(header: hunkHeader, oldStart: oldStart, oldCount: oldCount,
                                          newStart: newStart, newCount: newCount, lines: [])
                    oldLineNum = oldStart
                    newLineNum = newStart

                    currentLines.append(DiffLine(content: line, type: .hunkHeader, oldLineNumber: nil, newLineNumber: nil))
                }
            } else if line.hasPrefix("+") {
                currentLines.append(DiffLine(content: line, type: .addition, oldLineNumber: nil, newLineNumber: newLineNum))
                newLineNum += 1
            } else if line.hasPrefix("-") {
                currentLines.append(DiffLine(content: line, type: .deletion, oldLineNumber: oldLineNum, newLineNumber: nil))
                oldLineNum += 1
            } else if line.hasPrefix(" ") {
                currentLines.append(DiffLine(content: line, type: .context, oldLineNumber: oldLineNum, newLineNumber: newLineNum))
                oldLineNum += 1
                newLineNum += 1
            } else if !line.isEmpty && !line.hasPrefix("diff") && !line.hasPrefix("index") && !line.hasPrefix("---") && !line.hasPrefix("+++") {
                currentLines.append(DiffLine(content: line, type: .header, oldLineNumber: nil, newLineNumber: nil))
            }
        }

        if let hunk = currentHunk {
            hunks.append(DiffHunk(
                header: hunk.header,
                oldStart: hunk.oldStart,
                oldCount: hunk.oldCount,
                newStart: hunk.newStart,
                newCount: hunk.newCount,
                lines: currentLines
            ))
        }

        return GitDiff(filePath: filePath, hunks: hunks, isStaged: isStaged)
    }

    // MARK: - Stash Operations

    func getStashes() throws -> [GitStash] {
        let output = try executeGitCommand(["stash", "list", "--format=%gd|%s|%gs|%at"])
        var stashes: [GitStash] = []

        for (index, line) in output.components(separatedBy: "\n").enumerated() {
            guard !line.isEmpty else { continue }

            let parts = line.components(separatedBy: "|")
            guard parts.count >= 4 else { continue }

            let id = parts[0]
            let message = parts[1]
            let branch = parts[2].replacingOccurrences(of: "WIP on ", with: "")
            let timestamp = TimeInterval(parts[3]) ?? 0
            let date = Date(timeIntervalSince1970: timestamp)

            stashes.append(GitStash(id: id, index: index, message: message, branch: branch, date: date))
        }

        return stashes
    }

    func createStash(message: String? = nil) throws {
        if let message = message {
            _ = try executeGitCommand(["stash", "push", "-m", message])
        } else {
            _ = try executeGitCommand(["stash", "push"])
        }
    }

    func applyStash(_ stashId: String) throws {
        _ = try executeGitCommand(["stash", "apply", stashId])
    }

    func popStash(_ stashId: String) throws {
        _ = try executeGitCommand(["stash", "pop", stashId])
    }

    func dropStash(_ stashId: String) throws {
        _ = try executeGitCommand(["stash", "drop", stashId])
    }

    // MARK: - Blame Operations

    func getBlame(for path: String) throws -> [GitBlameLine] {
        let output = try executeGitCommand(["blame", "--line-porcelain", path])
        return parseBlame(output: output)
    }

    private func parseBlame(output: String) -> [GitBlameLine] {
        var blameLines: [GitBlameLine] = []
        let lines = output.components(separatedBy: "\n")

        var currentHash = ""
        var currentAuthor = ""
        var currentDate = Date()
        var lineNumber = 1

        var i = 0
        while i < lines.count {
            let line = lines[i]

            if line.starts(with: "\t") {
                let content = String(line.dropFirst())
                blameLines.append(GitBlameLine(
                    lineNumber: lineNumber,
                    content: content,
                    commitHash: currentHash,
                    author: currentAuthor,
                    date: currentDate
                ))
                lineNumber += 1
                i += 1
            } else if !line.isEmpty {
                let parts = line.split(separator: " ", maxSplits: 1)
                if parts.count > 0 && parts[0].count == 40 {
                    currentHash = String(parts[0])
                } else if line.hasPrefix("author ") {
                    currentAuthor = String(line.dropFirst(7))
                } else if line.hasPrefix("author-time ") {
                    if let timestamp = TimeInterval(line.dropFirst(12)) {
                        currentDate = Date(timeIntervalSince1970: timestamp)
                    }
                }
                i += 1
            } else {
                i += 1
            }
        }

        return blameLines
    }

    // MARK: - Statistics

    func getRepositoryStats() throws -> RepositoryStats {
        let totalCommits = try getTotalCommits()
        let branches = try getBranches()
        let contributors = try getContributors()
        let frequency = try getCommitFrequency()

        return RepositoryStats(
            totalCommits: totalCommits,
            totalBranches: branches.count,
            contributors: contributors,
            commitFrequency: frequency
        )
    }

    private func getTotalCommits() throws -> Int {
        let output = try executeGitCommand(["rev-list", "--count", "HEAD"])
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private func getContributors() throws -> [ContributorStats] {
        let output = try executeGitCommand(["shortlog", "-sne", "HEAD"])
        var contributors: [ContributorStats] = []

        for line in output.components(separatedBy: "\n") {
            guard !line.isEmpty else { continue }

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let parts = trimmed.split(separator: "\t", maxSplits: 1)
            guard parts.count == 2 else { continue }

            let count = Int(parts[0]) ?? 0
            let nameEmail = String(parts[1])

            if let emailRange = nameEmail.range(of: "<.*>", options: .regularExpression) {
                let name = nameEmail[..<emailRange.lowerBound].trimmingCharacters(in: .whitespaces)
                let email = nameEmail[emailRange].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))

                contributors.append(ContributorStats(name: name, email: email, commitCount: count))
            }
        }

        return contributors.sorted { $0.commitCount > $1.commitCount }
    }

    private func getCommitFrequency() throws -> [CommitFrequency] {
        let output = try executeGitCommand(["log", "--format=%at", "--all"])
        var dateCounts: [String: Int] = [:]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for line in output.components(separatedBy: "\n") {
            guard !line.isEmpty, let timestamp = TimeInterval(line) else { continue }

            let date = Date(timeIntervalSince1970: timestamp)
            let dateString = dateFormatter.string(from: date)

            dateCounts[dateString, default: 0] += 1
        }

        return dateCounts.map { key, value in
            CommitFrequency(date: dateFormatter.date(from: key) ?? Date(), count: value)
        }.sorted { $0.date < $1.date }
    }
}

// MARK: - Error Handling

enum GitError: LocalizedError {
    case commandFailed(String)
    case invalidRepository

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return "Git command failed: \(message)"
        case .invalidRepository:
            return "Not a valid Git repository"
        }
    }
}
