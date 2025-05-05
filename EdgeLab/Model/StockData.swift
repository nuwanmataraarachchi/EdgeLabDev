//
//  StockData.swift
//  EdgeLab
//
//  Created by user270106 on 5/6/25.
//

import Foundation

struct StockData: Identifiable, Codable {
    var id = UUID()
    let symbol: String
    let price: Double
    let timestamp: Date
}
