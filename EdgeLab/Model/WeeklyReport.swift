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
    @Published var tradeFrequency: Int = 0 // New property for total trades in the week

    private var db = Firestore.firestore()
    private let weekStart: Date
    private let calendar = Calendar.current

    init(weekStart: Date) {
        self.weekStart = calendar.startOfDay(for: weekStart)
        fetchWeeklyTrades()
    }

    func fetchWeeklyTrades() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not signed in."
            return
        }

        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            errorMessage = "Failed to calculate week range."
            return
        }

        db.collection("trades")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: weekStart))
            .whereField("date", isLessThan: Timestamp(date: weekEnd))
            .order(by: "date", descending: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Error fetching trades: \(error.localizedDescription)"
                    print(self.errorMessage!)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No trades found for the selected week."
                    print(self.errorMessage!)
                    return
                }

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
            guard let risk = Double(trade.risk),
                  let rr = Double(trade.rr) else { continue }

            let gain: Double
            if trade.outcome.lowercased() == "win" {
                gain = risk * rr
            } else if trade.outcome.lowercased() == "loss" {
                gain = -risk
            } else {
                gain = 0.0
            }

            totalPnL += gain

            let day = dateFormatter.string(from: trade.date).capitalized
            if days.contains(day) {
                dailyPnL[day, default: 0.0] += gain
            }
        }

        profitLoss = totalPnL
        tradeFrequency = trades.count
        errorMessage = trades.isEmpty ? "No trades found for this week." : nil
    }
}
