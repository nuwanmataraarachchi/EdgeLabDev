//
//  DashboardView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var marketDataViewModel = MarketDataViewModel()
    @State private var winRate = 75.0
    @State private var riskReward = 1.5
    @State private var streak = 5
    let currentPage = "Home"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Title
                Text("")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Key Metrics Section
                HStack(spacing: 15) {
                    MetricCard(title: "Win Rate", value: "\(Int(winRate))%")
                    MetricCard(title: "Risk/Reward", value: "\(riskReward)")
                    MetricCard(title: "Streak", value: "\(streak)")
                }
                .padding(.horizontal)
                
                // ✅ Rainbow Win Rate Gauge
                WinRateGaugeView(winRate: winRate)
                    .padding(.top, -10)

                // Market Data Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Market Data")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    if marketDataViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = marketDataViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(marketDataViewModel.stockData.sorted(by: { $0.symbol < $1.symbol })) { stock in
                            Text("\(stock.symbol): $\(String(format: "%.2f", stock.price))")
                                .font(.title3)
                                .padding(.vertical, 2)
                        }
                        
                        if !marketDataViewModel.stockData.isEmpty {
                            MarketDataChart(
                                stockData: marketDataViewModel.stockData
                                    .filter { $0.symbol == "AAPL" },
                                symbol: "AAPL"
                            )
                            .padding(.top, 10)
                        }
                    }
                    
                    Divider()
                }
                .padding(.horizontal)
                
                // Weekly Performance
                NavigationLink(destination: WeeklyPerformanceView()) {
                    Text("Weekly Performance")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Community
                NavigationLink(destination: CommunityView()) {
                    Text("Community")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Bottom Navigation Tray
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
            .background(Color.black.ignoresSafeArea()) // ✅ Dark background
            .navigationBarHidden(true)
            .onAppear {
                marketDataViewModel.connectWebSocket(symbols: ["AAPL", "TSLA", "MSFT"])
            }
            .onDisappear {
                marketDataViewModel.disconnectWebSocket()
            }
        }
    }
}

// MARK: - MetricCard
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

// MARK: - BottomTrayButton
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

// MARK: - Rainbow Gauge
struct WinRateGaugeView: View {
    let winRate: Double // 0 to 100
    
    var body: some View {
        ZStack {
            Gauge(value: winRate, in: 0...100) {
                Text("Win Rate")
            } currentValueLabel: {
                Text("\(Int(winRate))%")
                    .font(.title2)
                    .foregroundColor(.white)
            } minimumValueLabel: {
                Text("0%")
                    .foregroundColor(.gray)
            } maximumValueLabel: {
                Text("100%")
                    .foregroundColor(.gray)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(AngularGradient(
                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            ))
        }
        .frame(width: 150, height: 150)
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark) // ✅ Force dark mode in preview
    }
}
