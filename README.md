# GitDash

A beautiful and powerful visual Git client for macOS 14+.

## Features

- **Commit History Timeline**: View your repository's commit history with an intuitive graph visualization showing branches and merges
- **Advanced Diff Viewer**: Side-by-side or unified diff views with syntax highlighting
- **Staging Area**: Stage and unstage individual files or hunks with ease
- **Commit Management**: Create commits with detailed messages
- **Branch Management**: Create, switch, and delete branches effortlessly
- **Stash Support**: Stash, apply, pop, and manage your work-in-progress changes
- **File Blame**: View line-by-line commit information for any file
- **Repository Statistics**: Visualize contributors, commit frequency, and repository insights
- **Dark Mode**: Full support for macOS dark mode

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building)
- Git installed on your system

## Installation

### From Source

1. Clone this repository
2. Open `GitDash.xcodeproj` in Xcode
3. Build and run the project (⌘R)

### From App Store

Available on the Mac App Store for $6.99

## Usage

1. Launch GitDash
2. Click "Open Repository" or use ⌘O to select a Git repository folder
3. Explore your repository using the sidebar navigation:
   - **Commits**: Browse commit history
   - **Changes**: View and stage changes, create commits
   - **Branches**: Manage branches
   - **Stashes**: Work with stashed changes
   - **Blame**: View file blame information
   - **Statistics**: Analyze repository metrics

## Architecture

GitDash is built with:
- **SwiftUI**: Modern declarative UI framework
- **AppKit**: Native macOS integration
- **MVVM**: Clean separation of concerns
- **Process API**: Direct Git CLI integration with no external dependencies

## Bundle ID

`com.lopodragon.gitdash`

## License

MIT License - See LICENSE file for details

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

## Privacy

GitDash operates entirely locally on your machine. No data is collected or transmitted.

---

Made with ❤️ for the Git community
