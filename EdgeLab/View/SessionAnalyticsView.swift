//
//  SessionAnalyticsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-07.
//


import SwiftUI

struct SessionAnalyticsView: View {
    @StateObject private var viewModel = SessionAnalyticsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Session-Based Analytics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ForEach(viewModel.sessionStats) { stat in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(stat.name) Session")
                            .font(.headline)
                            .foregroundColor(.white)

                        // Gauge for win rate
                        Gauge(value: stat.winRate, in: 0...100) {
                            Text("Win Rate")
                        } currentValueLabel: {
                            Text(String(format: "%.1f%%", stat.winRate))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .gaugeStyle(.accessoryCircular) // Default circular style for iOS
                        .accentColor(.green)  // You can change the color here

                        HStack {
                            StatBlock(title: "Trades", value: "\(stat.totalTrades)", icon: "list.number")
                            StatBlock(title: "Losses", value: "\(stat.losses)", icon: "xmark.octagon")
                        }

                        HStack {
                            StatBlock(title: "Avg Profit", value: String(format: "%.2f", stat.avgProfit), icon: "arrow.up.right")
                            StatBlock(title: "RR Ratio", value: String(format: "%.2f", stat.riskReward), icon: "chart.bar.xaxis")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchTrades()  // Fetch the trades data when the view appears
        }
    }
}

#Preview {
    return SessionAnalyticsView()
}
