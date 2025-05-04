//
//  WeeklyReport.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation

class WeeklyReport: ObservableObject {
    @Published var weekStart: Date
    @Published var winRate: Double
    @Published var profitLoss: Double
    @Published var tradeFrequency: Int
    @Published private(set) var trades: [Trade]
    
    init(weekStart: Date, trades: [Trade] = []) {
        self.weekStart = weekStart
        self.trades = trades
        self.winRate = 0.0
        self.profitLoss = 0.0
        self.tradeFrequency = 0
    }
    
    func getReport() -> (winRate: Double, profitLoss: Double, tradeFrequency: Int) {
        return (winRate, profitLoss, tradeFrequency)
    }
}
