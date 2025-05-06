//
//  SessionStats.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-07.
//


//
//  SessionStats.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-06.
//


import Foundation

struct SessionStats: Identifiable {
    let id = UUID()
    let name: String
    let winRate: Double
    let totalTrades: Int
    let losses: Int
    let avgProfit: Double
    let riskReward: Double
}
