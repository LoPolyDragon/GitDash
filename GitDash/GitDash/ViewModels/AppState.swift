//
//  AppState.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var currentRepository: GitRepository?
    @Published var repositoryViewModel: RepositoryViewModel?

    func openRepository(at url: URL) {
        currentRepository = GitRepository(path: url)
        repositoryViewModel = RepositoryViewModel(repository: url)
    }

    func closeRepository() {
        currentRepository = nil
        repositoryViewModel = nil
    }
}
