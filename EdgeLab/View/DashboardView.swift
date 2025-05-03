//
//  DashboardView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct DashboardView: View {
    @State private var winRate = 75.0
    @State private var riskReward = 1.5
    @State private var streak = 5
    @State private var marketData = "1.23 USD"
    let currentPage = "Home"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Title
                Text("EdgeLab Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Key Metrics Section
                HStack(spacing: 15) {
                    MetricCard(title: "Win Rate", value: "\(winRate)%")
                    MetricCard(title: "Risk/Reward", value: "\(riskReward)")
                    MetricCard(title: "Streak", value: "\(streak)")
                }
                .padding(.horizontal)

                // Market Data Section
                VStack {
                    Text("Market Data")
                        .font(.headline)
                        .padding(.top, 10)

                    Text("Current Market Price: \(marketData)")
                        .font(.title3)
                        .padding(.bottom, 10)

                    Divider()
                }
                .padding(.horizontal)

                Spacer()

                // Tray Bar
                HStack {
                    BottomTrayButton(icon: "house.fill", label: "Home", destination: DashboardView(), isActive: currentPage == "Home")
                    BottomTrayButton(icon: "chart.bar.fill", label: "Stats", destination: AnalyticsView(), isActive: currentPage == "Stats")
                    BottomTrayButton(icon: "plus.circle", label: "Entry", destination: TradeEntryView(), isActive: currentPage == "Entry")
                    BottomTrayButton(icon: "clock.fill", label: "History", destination: TradeHistoryView(), isActive: currentPage == "History")
                    BottomTrayButton(icon: "gearshape.fill", label: "Settings", destination: SettingsView(), isActive: currentPage == "Settings")
                }
                .padding(.bottom, 10)
                .padding(.top, 6)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .shadow(radius: 2)
            }
            .navigationBarHidden(true)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(width: 110, height: 100)
        .background(Color.blue.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(12)
    }
}

struct BottomTrayButton<Destination: View>: View {
    let icon: String
    let label: String
    let destination: Destination
    let isActive: Bool

    var body: some View {
        Group {
            if isActive {
                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.gray)
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            } else {
                NavigationLink(destination: destination) {
                    VStack(spacing: 5) {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.blue)
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
