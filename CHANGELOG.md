# Changelog

All notable changes to GitDash will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added
- Initial release of GitDash
- Commit history timeline with graph visualization
- Side-by-side and unified diff viewers with syntax highlighting
- Staging area with file and hunk management
- Commit functionality with message editor
- Branch management (create, switch, delete)
- Stash support (create, apply, pop, drop)
- File blame view with author and date information
- Repository statistics dashboard
  - Contributor rankings
  - Commit frequency charts
  - Repository overview metrics
- Full dark mode support
- Native macOS 14+ integration
- Keyboard shortcuts for common operations
- Zero external dependencies (uses native Git CLI)

### Technical
- Built with SwiftUI and AppKit
- MVVM architecture
- Process API for Git operations
- Bundle ID: com.lopodragon.gitdash
- Minimum system version: macOS 14.0

[1.0.0]: https://github.com/lopodragon/gitdash/releases/tag/v1.0.0
