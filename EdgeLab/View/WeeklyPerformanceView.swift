import SwiftUI
import FirebaseAuth

struct WeeklyPerformanceView: View {
    @StateObject private var report: WeeklyReport
    @State private var selectedWeekStart: Date
    
    init() {
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        self._report = StateObject(wrappedValue: WeeklyReport(weekStart: weekStart))
        self._selectedWeekStart = State(wrappedValue: weekStart)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Weekly Performance")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Week Selector
                    HStack {
                        Button(action: {
                            selectedWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeekStart) ?? Date()
                            report.weekStart = selectedWeekStart
                            report.fetchTrades()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                        Text(weekRangeString)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(action: {
                            selectedWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeekStart) ?? Date()
                            report.weekStart = selectedWeekStart
                            report.fetchTrades()
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats Section
                    HStack(spacing: 15) {
                        StatCard(title: "Win Rate", value: "\(String(format: "%.1f", report.winRate))%", color: .green)
                        StatCard(title: "Net P&L", value: "\(String(format: "%.2f", report.profitLoss))", color: report.profitLoss >= 0 ? .green : .red)
                        StatCard(title: "Trades", value: "\(report.tradeFrequency)", color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // Chart Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Daily P&L")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let errorMessage = report.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else {
                            WeeklyPnLChart(dailyPnL: report.dailyPnL)
                                .frame(height: 300)
                                .padding(.horizontal)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
            }
            .navigationBarTitle("Weekly Performance", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // Handle back navigation if needed
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            })
        }
        .preferredColorScheme(.dark)
    }
    
    private var weekRangeString: String {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: selectedWeekStart) ?? selectedWeekStart
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: selectedWeekStart)) - \(formatter.string(from: weekEnd))"
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
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

// Weekly P&L Chart Component
struct WeeklyPnLChart: View {
    let dailyPnL: [String: Double]
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        GeometryReader { geometry in
            let maxPnL = dailyPnL.values.map { abs($0) }.max() ?? 1.0
            let chartHeight = geometry.size.height - 60 // Space for labels
            let zeroPosition = chartHeight / 2 // Middle for zero line
            let yAxisStep = maxPnL > 0 ? maxPnL / 4 : 1.0 // Y-axis steps
            
            ZStack {
                // Background Grid with spaced Y-axis labels
                VStack {
                    ForEach([-4, -2, 0, 2, 4], id: \.self) { step in
                        HStack {
                            Text(String(format: "%.1f", Double(step) * yAxisStep))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 50, alignment: .trailing)
                            if step != 0 { // Skip grid line for zero (drawn separately)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                            }
                        }
                        .offset(y: -CGFloat(step) * (chartHeight / 8)) // Increased spacing
                    }
                }
                
                // Zero Line
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .offset(y: zeroPosition - chartHeight / 2)
                
                // Bars and Labels
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        VStack {
                            Spacer()
                            if let pnL = dailyPnL[day], pnL != 0 {
                                // Bar
                                Rectangle()
                                    .fill(pnL >= 0 ? Color.green : Color.red)
                                    .frame(
                                        width: geometry.size.width / 10,
                                        height: CGFloat(abs(pnL) / maxPnL) * (chartHeight / 2)
                                    )
                                    .offset(y: pnL >= 0 ? -CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) : CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4))
                                
                                // P&L Label
                                Text(String(format: "%.1f", pnL))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(pnL >= 0 ? Color.green : Color.red)
                                    .cornerRadius(3)
                                    .offset(y: pnL >= 0 ? -CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) - 20 : CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) + 20)
                            }
                            Spacer()
                            // Day Label
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .offset(x: 50) // Space for Y-axis labels
            }
        }
    }
}

struct WeeklyPerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyPerformanceView()
            .preferredColorScheme(.dark)
    }
}
