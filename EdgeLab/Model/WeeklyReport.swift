//
//  WeeklyReport.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
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
        
        // Initialize daily PnL with default values for all days
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        dailyPnL = Dictionary(uniqueKeysWithValues: days.map { ($0, 0.0) })
        
        fetchWeeklyTrades()
    }
    
    func fetchWeeklyTrades() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not signed in."
            return
        }
        
        isLoading = true
        
        // Adjust weekStart to the start of the week (Monday)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)
        guard let adjustedWeekStart = calendar.date(from: components),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: adjustedWeekStart) else {
            errorMessage = "Failed to calculate week range."
            isLoading = false
            return
        }
        
        self.weekStart = adjustedWeekStart
        
        // Get the formatted date range for display purposes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let startDateStr = dateFormatter.string(from: adjustedWeekStart)
        let endDateStr = dateFormatter.string(from: weekEnd)
        
        print("Fetching trades from \(startDateStr) to \(endDateStr) for user: \(userId)")
        
        db.collection("trades")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: adjustedWeekStart))
            .whereField("date", isLessThan: Timestamp(date: weekEnd))
            .order(by: "date", descending: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching trades: \(error.localizedDescription)"
                    print(self.errorMessage!)
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self.errorMessage = "No trades found for the selected week."
                    print("No trades found for the week of \(startDateStr) to \(endDateStr)")
                    return
                }
                
                print("Found \(documents.count) trades for the week")
                
                var trades: [TradeModel] = []
                for doc in documents {
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
        tradeFrequency = trades.count
        errorMessage = trades.isEmpty ? "No trades found for this week." : nil
        
        print("Processed \(trades.count) trades. Win rate: \(winRate)%, Net P&L: \(profitLoss)")
        print("Daily P&L: \(dailyPnL)")
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

extension TradeModel {
    init(id: String, asset: String, date: Date, day: String, session: String, isSessionTrading: Bool, direction: String, risk: String, rr: String, entryCriteria: String, grade: String, outcome: String, chartViewURL: String, notes: String) {
        self.init(
            id: UUID(uuidString: id) ?? UUID(),
            asset: asset,
            date: date,
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
}
