//  AnalyticsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel = AnalyticsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                statRows
                pnlSection
                recentTrades
                Spacer()
            }
            .padding()
            .background(Color.black)
            .cornerRadius(12)
        }
        .navigationBarTitle("Analytics", displayMode: .inline)
        .onAppear {
            viewModel.fetchAnalyticsData()
        }
    }

    private var header: some View {
        Text("Analytics View")
            .font(.title) // Adjusted font size for header
            .fontWeight(.bold)
            .padding(.top)
            .foregroundColor(.white)
    }

    private var statRows: some View {
        VStack(spacing: 12) {
            HStack {
                StatBlock(title: "Win Rate", value: String(format: "%.2f", viewModel.winRate), icon: "percent")
                StatBlock(title: "Total Trades", value: "\(viewModel.totalTrades)", icon: "number")
                StatBlock(title: "Avg Profit", value: String(format: "%.2f", viewModel.avgProfit), icon: "dollarsign.circle")
            }
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Overall Gain")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "arrow.triangle.turn.up.right.circle")
                            .foregroundColor(.white)
                    }
                    Text(formattedGain(viewModel.overallGain))
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.overallGain >= 0 ? .green : .red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)

                StatBlock(title: "Losses", value: "\(viewModel.losses)", icon: "chart.bar.xaxis")
                StatBlock(title: "Risk/Reward", value: String(format: "%.2f", viewModel.riskReward), icon: "info.circle")
            }
        }
    }

    private func formattedGain(_ gain: Double) -> String {
        if gain >= 0 {
            return String(format: "+%.0f%%", gain)
        } else {
            return String(format: "%.0f%%", gain)
        }
    }

    private var pnlSection: some View {
        VStack(alignment: .leading) {
            Text("Accumulative P&L")
                .font(.headline)
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.4))
                .frame(height: 120)
                .overlay(
                    Text("Graph Placeholder\n\(String(format: "%.2f", viewModel.accPnl))")
                        .foregroundColor(.gray)
                )

            HStack {
                Text("Jan 23, 24")
                Spacer()
                Text("Feb 09, 24")
            }
            .foregroundColor(.gray)
            .font(.caption)
        }
    }

    private var recentTrades: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Last Five Trades")
                .font(.headline)
                .foregroundColor(.white)

            // Header row
            HStack {
                Text("Asset")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 100, alignment: .leading) // Fixed width for alignment
                Spacer()
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 120, alignment: .leading) // Fixed width for alignment
                Spacer()
                Text("Outcome")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .leading) // Fixed width for alignment
            }
            .padding(.bottom, 2)

            ForEach(viewModel.lastTrades.prefix(5), id: \.self) { trade in
                HStack {
                    Text(trade.asset)
                        .foregroundColor(.gray)
                        .frame(width: 100, alignment: .leading) // Fixed width for alignment
                    Spacer()
                    Text(trade.date)
                        .foregroundColor(.gray)
                        .frame(width: 120, alignment: .leading) // Fixed width for alignment
                    Spacer()
                    Text(trade.type)
                        .fontWeight(.bold)
                        .foregroundColor(colorForType(trade.type))
                        .frame(width: 80, alignment: .leading) // Fixed width for alignment
                }
            }
        }
    }

    private func colorForType(_ type: String) -> Color {
        switch type {
        case "W":
            return .green
        case "L":
            return .red
        case "BE":
            return .blue
        default:
            return .gray
        }
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100) // Consistent size for all blocks
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
    }
}

struct TradePreview: Hashable {
    let type: String
    let asset: String
    let date: String
    let pl: String
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .preferredColorScheme(.dark)
    }
}
