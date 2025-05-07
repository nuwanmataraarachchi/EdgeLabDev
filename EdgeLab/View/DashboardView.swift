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
    @State private var currentStreak = 0
    @State private var tradeCount = 0
    @State private var animatedTradeCount = 0
    @State private var showLetters: [Bool] = Array(repeating: false, count: 7)
    let logoText = Array("EDGELAB")
    let animationDuration = 0.4
    let currentPage = "Home"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                //Animated EDGELAB Logo with adjusted padding
                HStack(spacing: 0) {
                    ForEach(0..<logoText.count, id: \.self) { index in
                        Text(String(logoText[index]))
                            .foregroundColor(index < 4 ? .white : .blue)
                            .font(.system(size: 34, weight: .black, design: .default))
                            .opacity(showLetters[index] ? 1 : 0)
                            .offset(y: showLetters[index] ? 0 : 10)
                            .animation(.easeOut(duration: animationDuration).delay(Double(index) * 0.07), value: showLetters[index])
                    }
                }
                .padding(.top, 45) // Adjusted to make the logo lower
                .onAppear {
                    startLoopingAnimation()
                }
       

                // App Title (was empty before)
                Text("")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Key Metrics Section
                HStack(spacing: 15) {
                    MetricCard(title: "Win Rate", value: "\(Int(winRate))%", height: 80)
                    MetricCard(title: "Risk/Reward", value: "\(riskReward)", height: 80)
                    MetricCard(title: "Streak", value: "\(streak)", height: 80)
                }
                .padding(.horizontal)
                
                // ✅ Modern Win Rate Gauge + Animated Counter
                HStack {
                    WinRateGaugeView(winRate: winRate)
                    
                    // Animated counter on the right side
                    VStack(spacing: 25) {
                        VStack {
                            Text("ProfitFactor")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(currentStreak)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        
                        VStack {
                            Text("Trades")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(animatedTradeCount)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            currentStreak = streak
                        }
                        
                        tradeCount = 42 // ✅ Dummy trade count
                        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                            if animatedTradeCount < tradeCount {
                                animatedTradeCount += 1
                            } else {
                                timer.invalidate()
                            }
                        }
                    }
                }
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
                        .padding(.vertical, 6) // Adjusted height here
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
                        .padding(.vertical, 6) // Adjusted height here
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
    
    // MARK: - Animated EDGELAB Logo
    private func startLoopingAnimation() {
        Timer.scheduledTimer(withTimeInterval: animationDuration * Double(logoText.count) + 1.2, repeats: true) { _ in
            for i in 0..<logoText.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                    withAnimation {
                        showLetters[i] = true
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * Double(logoText.count) + 0.6) {
                withAnimation {
                    showLetters = Array(repeating: false, count: 7)
                }
            }
        }
    }
}

// MARK: - MetricCard
struct MetricCard: View {
    let title: String
    let value: String
    let height: CGFloat
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(width: 110, height: height)
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
                EmptyView()
            } currentValueLabel: {
                Text("\(Int(winRate))%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            } minimumValueLabel: {
                Text("0%")
                    .foregroundColor(.gray)
            } maximumValueLabel: {
                Text("100%")
                    .foregroundColor(.gray)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(AngularGradient(
                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .mint, .blue, .purple]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            ))
            .scaleEffect(1.5) // ✅ Enlarged gauge only

            VStack {
                Spacer()
                Text("Win Rate")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
        }
        .frame(width: 220, height: 220)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.2))
        )
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark) // ✅ Force dark mode in preview
    }
}
