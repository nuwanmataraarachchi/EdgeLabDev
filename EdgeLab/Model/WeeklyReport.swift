////
////  WeeklyReport.swift
////  EdgeLab
////
////  Created by user270106 on 5/3/25.
////
//
//import Foundation
//
//class WeeklyReport: ObservableObject {
//    @Published var weekStart: Date
//    @Published var winRate: Double
//    @Published var profitLoss: Double
//    @Published var tradeFrequency: Int
//    @Published private(set) var trades: [Trade]
//    
//    init(weekStart: Date, trades: [Trade] = []) {
//        self.weekStart = weekStart
//        self.trades = trades
//        self.winRate = 0.0
//        self.profitLoss = 0.0
//        self.tradeFrequency = 0
//    }
//    
//    func calculateMetrics(trades: [Trade]) {
//        self.trades = trades
//        self.tradeFrequency = trades.count
//        self.profitLoss = trades.reduce(0.0) { $0 + $1.profitLoss }
//        let wins = trades.filter { $0.profitLoss > 0 }.count
//        self.winRate = tradeFrequency > 0 ? Double(wins) / Double(tradeFrequency) : 0.0
//    }
//    
//    func getReport() -> (winRate: Double, profitLoss: Double, tradeFrequency: Int) {
//        return (winRate, profitLoss, tradeFrequency)
//    }
//}
