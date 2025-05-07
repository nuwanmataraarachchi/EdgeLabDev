import SwiftUI

struct TradeDaySummary: Identifiable {
    let id = UUID()
    var date: Date
    var totalGain: Double
    var numberOfTrades: Int
}

struct TradeHistoryCalendarView: View {
    @State private var currentMonthOffset = 0
    private let currentDate = Date()
    
    @State private var selectedTrade: TradeDaySummary?
    
    @State private var tradeSummaries: [TradeDaySummary] = [
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, totalGain: 2.4, numberOfTrades: 2),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, totalGain: -1.3, numberOfTrades: 1),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, totalGain: 0.5, numberOfTrades: 3),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, totalGain: 0.0, numberOfTrades: 0),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, totalGain: 3.7, numberOfTrades: 4),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, totalGain: -2.0, numberOfTrades: 2),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, totalGain: 1.2, numberOfTrades: 1),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, totalGain: -0.4, numberOfTrades: 1),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, totalGain: 0.0, numberOfTrades: 0),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, totalGain: 0.9, numberOfTrades: 2),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -11, to: Date())!, totalGain: -3.1, numberOfTrades: 3),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, totalGain: 2.2, numberOfTrades: 2),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -13, to: Date())!, totalGain: 1.5, numberOfTrades: 1),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!, totalGain: -0.8, numberOfTrades: 1),
        TradeDaySummary(date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!, totalGain: 0.0, numberOfTrades: 0)
    ]
    var body: some View {
        VStack(spacing: 10) {
            // Month Header
            HStack {
                Button(action: {
                    if currentMonthOffset > -12 {
                        currentMonthOffset -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(extractMonthYear())
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if currentMonthOffset < 0 {
                        currentMonthOffset += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .opacity(currentMonthOffset < 0 ? 1 : 0.3)
                        .foregroundColor(.white)
                }
                .disabled(currentMonthOffset >= 0)
            }
            .padding(.horizontal)
            
            // Week Days
            let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Dates
            let days = generateCurrentMonthDates()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
            
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(days, id: \.self) { date in
                    if Calendar.current.isDate(date, equalTo: firstOfMonth(), toGranularity: .month) {
                        let summary = tradeSummaries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
                        
                        VStack(spacing: 3) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let summary = summary {
                                Text(String(format: "%.1f", summary.totalGain))
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                
                                Text("\(summary.numberOfTrades)x")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(6)
                        .background(tileBackground(for: summary))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .onTapGesture {
                            if let summary = summary {
                                selectedTrade = summary
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Calendar View")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedTrade) { trade in
            TradeDetailPopupView(trade: trade)
        }
    }
    
    private func extractMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let date = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: currentDate)!
        return formatter.string(from: date)
    }
    
    private func generateCurrentMonthDates() -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let currentMonth = calendar.date(byAdding: .month, value: currentMonthOffset, to: currentDate)!
        var dates: [Date] = []
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let emptyBoxes = (weekday + 5) % 7
        
        for _ in 0..<emptyBoxes {
            dates.append(Date.distantPast)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func firstOfMonth() -> Date {
        let calendar = Calendar.current
        let currentMonth = calendar.date(byAdding: .month, value: currentMonthOffset, to: currentDate)!
        return calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
    }
    
    private func tileBackground(for summary: TradeDaySummary?) -> LinearGradient {
        if let summary = summary {
            if summary.totalGain > 0 {
                return LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0.2)]),
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if summary.totalGain < 0 {
                return LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.4), Color.red.opacity(0.2)]),
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        return LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct TradeDetailPopupView: View {
    let trade: TradeDaySummary
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Trade Details")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text("Date: \(formatDate(trade.date))")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text("Total Gain: \(String(format: "%.2f", trade.totalGain))")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text("Number of Trades: \(trade.numberOfTrades)")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Button(action: {}) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct TradeHistoryCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TradeHistoryCalendarView()
        }
        .preferredColorScheme(.dark)
    }
}
