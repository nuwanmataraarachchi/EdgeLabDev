//
//  PsychologicInsight.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//
import Foundation

struct EmotionTag: Identifiable {
    let id: UUID
    let name: String
    let timestamp: Date
    
    init(id: UUID = UUID(), name: String, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}

class PsychologicInsight: Identifiable, ObservableObject {
    let id: UUID
    @Published var insight: String
    @Published var recommendation: String
    @Published private(set) var trades: [Trade]
    
    init(id: UUID = UUID(), insight: String, recommendation: String, trades: [Trade] = []) {
        self.id = id
        self.insight = insight
        self.recommendation = recommendation
        self.trades = trades
    }
    
    func generateInsight(trades: [Trade]) {
        self.trades = trades
        let totalProfitLoss = trades.reduce(0.0) { $0 + $1.profitLoss }
        self.insight = totalProfitLoss >= 0 ? "Positive trading behavior" : "Risky trading behavior"
        self.recommendation = totalProfitLoss >= 0 ? "Maintain strategy" : "Review risk management"
    }
}
