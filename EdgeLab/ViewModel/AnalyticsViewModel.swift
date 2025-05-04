//  AnalyticsViewModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-04.
//
//
import Foundation
import FirebaseFirestore
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var winRate: Double = 0.0
    @Published var totalTrades: Int = 0
    @Published var avgProfit: Double = 0.0
    @Published var overallGain: Double = 0.0  // <- Renamed from sessionWinRate
    @Published var losses: Int = 0
    @Published var riskReward: Double = 0.0
    @Published var lastTrades: [TradePreview] = []
    @Published var accPnl: Double = 0.0

    private var db = Firestore.firestore()

    func fetchAnalyticsData() {
        db.collection("trades").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, error == nil else {
                print("Firestore error: \(error?.localizedDescription ?? "")")
                return
            }

            var trades: [TradeModel] = []

            for doc in querySnapshot?.documents ?? [] {
                let data = doc.data()
                let trade = TradeModel(
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

            self.processTrades(trades)
        }
    }

    private func processTrades(_ trades: [TradeModel]) {
        totalTrades = trades.count

        let winTrades = trades.filter { $0.outcome.lowercased() == "win" }
        let lossTrades = trades.filter { $0.outcome.lowercased() == "loss" }

        let totalForWinRate = winTrades.count + lossTrades.count
        winRate = totalForWinRate > 0 ? (Double(winTrades.count) / Double(totalForWinRate)) * 100 : 0
        self.losses = lossTrades.count

        let profits = trades.compactMap { Double($0.rr) }
        avgProfit = profits.isEmpty ? 0 : profits.reduce(0, +) / Double(profits.count)

        // ✅ Calculate overallGain = Σ (risk * rr), negative if loss
        var totalGain = 0.0
        for trade in trades {
            guard
                let risk = Double(trade.risk),
                let rr = Double(trade.rr)
            else { continue }

            let gain: Double
            if trade.outcome.lowercased() == "loss" {
                gain = -risk // Loss means we lose the risk amount
            } else if trade.outcome.lowercased() == "win" {
                gain = risk * rr // Win means we gain risk * rr
            } else {
                gain = 0.0 // For non-win/loss (e.g., break-even)
            }

            totalGain += gain
        }
        overallGain = totalGain

        let risks = trades.compactMap { Double($0.risk) }
        riskReward = risks.isEmpty || profits.isEmpty ? 0 : (profits.reduce(0, +) / risks.reduce(0, +))

        accPnl = profits.reduce(0, +)

        // Sort trades by date in descending order to get the most recent ones first
        let sortedTrades = trades.sorted { $0.date > $1.date }

        // Take the top 5 most recent trades, maintaining the order
        lastTrades = Array(sortedTrades.prefix(5)).map {
            let outcomeSymbol: String
            switch $0.outcome.lowercased() {
            case "win": outcomeSymbol = "W"
            case "loss": outcomeSymbol = "L"
            case "be", "break-even", "b/e": outcomeSymbol = "BE"
            default: outcomeSymbol = "?"
            }

            return TradePreview(
                type: outcomeSymbol,
                asset: $0.asset,
                date: DateFormatter.localizedString(from: $0.date, dateStyle: .short, timeStyle: .none),
                pl: $0.rr
            )
        }
    }
}
