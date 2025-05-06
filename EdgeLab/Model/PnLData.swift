//
//  PnLData.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-04.
// PnLData.swift
// EdgeLab
import Foundation

struct PnLData: Identifiable {
    var id = UUID()
    var date: Date
    var gainLoss: Double
}
