//
//  StatsView.swift
//  GitDash
//
//  Created on 2026-03-25.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var viewModel: RepositoryViewModel
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let stats = viewModel.stats {
                    OverviewSection(stats: stats)

                    ContributorsSection(contributors: stats.contributors)

                    CommitFrequencySection(frequency: stats.commitFrequency)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        if isLoading {
                            ProgressView()
                        } else {
                            Button(action: loadStats) {
                                Label("Load Statistics", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .onAppear {
            if viewModel.stats == nil {
                loadStats()
            }
        }
    }

    private func loadStats() {
        isLoading = true
        viewModel.loadStatistics()
        isLoading = false
    }
}

struct OverviewSection: View {
    let stats: RepositoryStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 40) {
                StatCard(title: "Total Commits", value: "\(stats.totalCommits)", icon: "clock.arrow.circlepath")
                StatCard(title: "Branches", value: "\(stats.totalBranches)", icon: "arrow.triangle.branch")
                StatCard(title: "Contributors", value: "\(stats.contributors.count)", icon: "person.2")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContributorsSection: View {
    let contributors: [ContributorStats]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Contributors")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                ForEach(contributors.prefix(10)) { contributor in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contributor.name)
                                .font(.headline)
                            Text(contributor.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text("\(contributor.commitCount)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 4)

                    if contributor.id != contributors.prefix(10).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CommitFrequencySection: View {
    let frequency: [CommitFrequency]

    var recentFrequency: [CommitFrequency] {
        Array(frequency.suffix(30))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Commit Activity (Last 30 Days)")
                .font(.title2)
                .fontWeight(.semibold)

            if #available(macOS 13.0, *) {
                Chart(recentFrequency) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Commits", item.count)
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 200)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(recentFrequency) { item in
                        HStack {
                            Text(item.date, style: .date)
                                .font(.caption)
                                .frame(width: 100, alignment: .leading)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor)
                                .frame(width: CGFloat(item.count) * 10, height: 20)

                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
