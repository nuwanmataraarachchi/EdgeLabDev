//
//  WeeklyReport.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class WeeklyReport: ObservableObject {
    @Published var weekStart: Date
    @Published var winRate: Double = 0.0
    @Published var profitLoss: Double = 0.0
    @Published var tradeFrequency: Int = 0
    @Published var dailyPnL: [String: Double] = ["Mon": 0.0, "Tue": 0.0, "Wed": 0.0, "Thu": 0.0, "Fri": 0.0, "Sat": 0.0, "Sun": 0.0]
    @Published private(set) var trades: [TradeModel] = []
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    init(weekStart: Date) {
        self.weekStart = weekStart
        fetchTrades()
    }
    
    func fetchTrades() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to view trades."
            return
        }
        
        // Calculate the week end date
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        // Fetch trades for the week from Firestore
        db.collection("trades")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: weekStart))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: weekEnd))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to fetch trades: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No trades found for this week."
                    return
                }
                
                self.trades = documents.compactMap { doc -> TradeModel? in
                    let data = doc.data()
                    guard let asset = data["asset"] as? String,
                          let dateTimestamp = data["date"] as? Timestamp,
                          let day = data["day"] as? String,
                          let session = data["session"] as? String,
                          let isSessionTrading = data["isSessionTrading"] as? Bool,
                          let direction = data["direction"] as? String,
                          let risk = data["risk"] as? String,
                          let rr = data["rr"] as? String,
                          let entryCriteria = data["entryCriteria"] as? String,
                          let grade = data["grade"] as? String,
                          let outcome = data["outcome"] as? String,
                          let chartViewURL = data["chartViewURL"] as? String,
                          let notes = data["notes"] as? String else {
                        return nil
                    }
                    
                    return TradeModel(
                        id: UUID(uuidString: doc.documentID) ?? UUID(),
                        asset: asset,
                        date: dateTimestamp.dateValue(),
                        day: day,
                        session: session,
                        isSessionTrading: isSessionTrading,
                        direction: direction,
                        risk: risk,
                        rr: rr,
                        entryCriteria: entryCriteria,
                        grade: grade,
                        outcome: outcome,
                        chartViewURL: chartViewURL,
                        notes: notes
                    )
                }
                
                self.calculateMetrics()
            }
    }
    
    private func calculateMetrics() {
        // Reset metrics
        dailyPnL = ["Mon": 0.0, "Tue": 0.0, "Wed": 0.0, "Thu": 0.0, "Fri": 0.0, "Sat": 0.0, "Sun": 0.0]
        tradeFrequency = trades.count
        profitLoss = 0.0
        winRate = 0.0
        
        var wins = 0
        for trade in trades {
            // Parse outcome (e.g., "+50" or "-30" or "10.0" as shown in the screenshot)
            let outcomeStr = trade.outcome.replacingOccurrences(of: "+", with: "")
            if let pnL = Double(outcomeStr) {
                profitLoss += pnL
                dailyPnL[trade.day, default: 0.0] += pnL
                if pnL > 0 {
                    wins += 1
                }
            } else {
                print("Invalid outcome format for trade: \(trade.outcome)")
            }
        }
        
        if tradeFrequency > 0 {
            winRate = (Double(wins) / Double(tradeFrequency)) * 100
        }
    }
    
    func getReport() -> (winRate: Double, profitLoss: Double, tradeFrequency: Int) {
        return (winRate, profitLoss, tradeFrequency)
    }
}
