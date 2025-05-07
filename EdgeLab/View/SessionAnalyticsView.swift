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

                        CustomGradientGauge(value: stat.winRate)

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
            viewModel.fetchTrades()
        }
    }
}

struct CustomGradientGauge: View {
    var value: Double // 0 to 100

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 10)

            Circle()
                .trim(from: 0.0, to: CGFloat(value / 100))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.red, Color.green]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text(String(format: "%.1f%%", value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    return SessionAnalyticsView()
}
