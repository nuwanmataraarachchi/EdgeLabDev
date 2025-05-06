import Foundation
import FirebaseFirestore
import Combine

class WeeklyReport: ObservableObject {
    @Published var winRate: Double = 0.0
    @Published var profitLoss: Double = 0.0
    @Published var dailyPnL: [String: Double] = [:]
    @Published var errorMessage: String?
    @Published var tradeFrequency: Int = 0
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private(set) var weekStart: Date
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    init(weekStart: Date) {
        self.weekStart = calendar.startOfDay(for: weekStart)
        
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        dailyPnL = Dictionary(uniqueKeysWithValues: days.map { ($0, 0.0) })
        
        fetchWeeklyTrades()
    }
    
    func fetchWeeklyTrades() {
        isLoading = true
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)
        components.weekday = 2 // Monday
        guard let adjustedWeekStart = calendar.date(from: components),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: adjustedWeekStart) else {
            errorMessage = "Failed to calculate week range."
            isLoading = false
            return
        }
        
        self.weekStart = adjustedWeekStart
        
        db.collection("trades")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: adjustedWeekStart))
            .whereField("date", isLessThan: Timestamp(date: weekEnd))
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching trades: \(error.localizedDescription)"
                    return
                }
                
                var trades: [TradeModel] = []
                
                for doc in querySnapshot?.documents ?? [] {
                    let data = doc.data()
                    let trade = TradeModel(
                        id: UUID(uuidString: doc.documentID) ?? UUID(),
                        asset: data["asset"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        day: data["day"] as? String ?? "",
                        session: data["session"] as? String ?? "",
                        isSessionTrading: data["isSessionTrading"] as? Bool ?? false,
                        direction: data["direction"] as? String ?? "",
                        risk: data["risk"] as? String ?? "",
                        rr: data["rr"] as? String ?? "",
                        entryCriteria: data["entryCriteria"] as? String ?? "",
                        grade: data["grade"] as? String ?? "",
                        outcome: data["outcome"] as? String ?? "",
                        chartViewURL: data["chartViewURL"] as? String ?? "",
                        notes: data["notes"] as? String ?? ""
                    )
                    trades.append(trade)
                }
                
                self.processWeeklyTrades(trades)
            }
    }
    
    private func processWeeklyTrades(_ trades: [TradeModel]) {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        dailyPnL = Dictionary(uniqueKeysWithValues: days.map { ($0, 0.0) })
        
        tradeFrequency = trades.count
        
        let winTrades = trades.filter { $0.outcome.lowercased() == "win" }
        let lossTrades = trades.filter { $0.outcome.lowercased() == "loss" }
        let totalForWinRate = winTrades.count + lossTrades.count
        winRate = totalForWinRate > 0 ? (Double(winTrades.count) / Double(totalForWinRate)) * 100 : 0.0
        
        var totalPnL: Double = 0.0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        for trade in trades {
            guard let risk = Double(trade.risk.trimmingCharacters(in: .whitespaces)),
                  let rr = Double(trade.rr.trimmingCharacters(in: .whitespaces)) else {
                continue
            }
            
            let gain: Double
            if trade.outcome.lowercased() == "win" {
                gain = risk * rr
            } else if trade.outcome.lowercased() == "loss" {
                gain = -risk
            } else {
                gain = 0.0
            }
            
            totalPnL += gain
            
            let day = dateFormatter.string(from: trade.date).prefix(3).capitalized
            if days.contains(day) {
                dailyPnL[day, default: 0.0] += gain
            }
        }
        
        profitLoss = totalPnL
        errorMessage = trades.isEmpty ? "No trades found for this week." : nil
    }
    
    func refreshData() {
        fetchWeeklyTrades()
    }
    
    func changeWeek(by offset: Int) {
        guard let newWeekStart = calendar.date(byAdding: .day, value: 7 * offset, to: weekStart) else {
            return
        }
        
        self.weekStart = calendar.startOfDay(for: newWeekStart)
        fetchWeeklyTrades()
    }
}
