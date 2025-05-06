import SwiftUI

struct WeeklyPerformanceView: View {
    @StateObject private var report: WeeklyReport
    @Environment(\.dismiss) private var dismiss
    @State private var weekStartDisplay: String = ""
    @State private var weekEndDisplay: String = ""
    
    init(weekStart: Date = Date()) {
        _report = StateObject(wrappedValue: WeeklyReport(weekStart: weekStart))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: {
                                report.changeWeek(by: -1)
                                updateDateDisplay()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("\(weekStartDisplay) - \(weekEndDisplay)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                report.changeWeek(by: 1)
                                updateDateDisplay()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        HStack(spacing: 15) {
                            StatCard(title: "Win Rate", value: "\(String(format: "%.1f", report.winRate))%", color: .green)
                            StatCard(title: "Net P&L", value: "\(String(format: "%.2f", report.profitLoss))",
                                    color: report.profitLoss >= 0 ? .green : .red)
                        }
                        .padding(.horizontal)

                        HStack(spacing: 15) {
                            StatCard(title: "Total Trades", value: "\(report.tradeFrequency)",
                                    color: .blue)
                            StatCard(title: "Avg Daily P&L",
                                    value: "\(String(format: "%.2f", calculateAvgDailyPnL()))",
                                    color: calculateAvgDailyPnL() >= 0 ? .green : .red)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daily P&L")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if report.isLoading {
                                ProgressView()
                                    .frame(height: 300)
                                    .tint(.white)
                            } else if let errorMessage = report.errorMessage {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.largeTitle)
                                        .foregroundColor(.orange)
                                        .padding()
                                    
                                    Text(errorMessage)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            } else {
                                WeeklyPnLChart(dailyPnL: report.dailyPnL)
                                    .frame(height: 300)
                                    .padding(.horizontal)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .onAppear {
            updateDateDisplay()
        }
    }
    
    private func updateDateDisplay() {
        let calendar = Calendar.current
        let weekStart = report.weekStart
        guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        weekStartDisplay = dateFormatter.string(from: weekStart)
        weekEndDisplay = dateFormatter.string(from: weekEnd)
    }
    
    private func calculateAvgDailyPnL() -> Double {
        let activeDays = report.dailyPnL.values.filter { $0 != 0.0 }
        return activeDays.isEmpty ? 0.0 : activeDays.reduce(0, +) / Double(activeDays.count)
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct WeeklyPnLChart: View {
    let dailyPnL: [String: Double]
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        GeometryReader { geometry in
            let maxPnL = max(0.1, dailyPnL.values.map { abs($0) }.max() ?? 1.0)
            let chartHeight = geometry.size.height - 60
            let zeroPosition = chartHeight / 2
            let yAxisStep = maxPnL > 0 ? maxPnL / 3 : 1.0
            let barWidth = (geometry.size.width - 60) / CGFloat(days.count) - 8
            
            ZStack {
                // Background Grid
                VStack {
                    ForEach([-3, -2, -1, 0, 1, 2, 3], id: \.self) { step in
                        HStack {
                            Text(String(format: "%.1f", Double(step) * yAxisStep))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 50, alignment: .trailing)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .offset(y: -CGFloat(step) * (chartHeight / 6))
                    }
                }
                
                // Zero Line
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .offset(y: zeroPosition - chartHeight / 2)
                
                // Bars and Labels
                HStack(alignment: .center, spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        VStack {
                            Spacer()
                            ZStack(alignment: .center) {
                                if let pnL = dailyPnL[day], abs(pnL) > 0.01 {
                                    let barHeight = CGFloat(abs(pnL) / maxPnL) * (chartHeight / 2)
                                    Rectangle()
                                        .fill(pnL >= 0 ? Color.green : Color.red)
                                        .frame(width: barWidth, height: min(barHeight, chartHeight / 2))
                                        .offset(y: pnL >= 0 ? -barHeight / 2 : barHeight / 2)
                                    
                                    Text(String(format: "%.1f", pnL))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(pnL >= 0 ? Color.green : Color.red)
                                        .cornerRadius(3)
                                        .offset(y: pnL >= 0 ? -barHeight - 20 : barHeight + 20)
                                }
                            }
                            Spacer()
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .offset(x: 50)
            }
            .frame(height: chartHeight)
        }
        .padding(.vertical)
    }
}

struct WeeklyPerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyPerformanceView(weekStart: Date())
    }
}
