//
//  SessionAnalyticsViewModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-07.
//


//
//  SessionAnalyticsViewModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-06.
//


import Foundation
import FirebaseFirestore

class SessionAnalyticsViewModel: ObservableObject {
    @Published var sessionStats: [SessionStats] = []

    private let db = Firestore.firestore()

    func fetchTrades() {
        db.collection("trades").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching trades: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            let trades: [TradeModel] = documents.compactMap { doc in
                let data = doc.data()

                guard let asset = data["asset"] as? String,
                      let timestamp = data["date"] as? Timestamp,
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
                    asset: asset,
                    date: timestamp.dateValue(),
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

            self.calculateSessionStats(from: trades)
        }
    }

    private func calculateSessionStats(from trades: [TradeModel]) {
        let sessions = ["Asian", "London", "Newyork"]

        self.sessionStats = sessions.map { session in
            let filtered = trades.filter { $0.session.lowercased() == session.lowercased() }

            let wins = filtered.filter { $0.outcome.lowercased() == "win" }
            let losses = filtered.filter { $0.outcome.lowercased() == "loss" }

            let total = wins.count + losses.count
            let winRate = total > 0 ? (Double(wins.count) / Double(total)) * 100 : 0

            let avgProfit = filtered
                .compactMap { Double($0.rr) }
                .reduce(0, +) / Double(filtered.count == 0 ? 1 : filtered.count)

            let totalRisk = filtered
                .compactMap { Double($0.risk) }
                .reduce(0, +)

            let totalRR = filtered
                .compactMap { Double($0.rr) }
                .reduce(0, +)

            let riskReward = totalRisk == 0 ? 0 : totalRR / totalRisk

            return SessionStats(
                name: session,
                winRate: winRate,
                totalTrades: total,
                losses: losses.count,
                avgProfit: avgProfit,
                riskReward: riskReward
            )
        }
    }
}
