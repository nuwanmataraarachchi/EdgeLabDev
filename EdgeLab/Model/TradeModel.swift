//
//  TradeModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-03.
//


// TradeModel.swift

import Foundation
import FirebaseFirestore

struct TradeModel: Identifiable {
    var id = UUID()
    let asset: String
    let date: Date
    let day: String
    let session: String
    let isSessionTrading: Bool
    let direction: String
    let risk: String
    let rr: String
    let entryCriteria: String
    let grade: String
    let outcome: String
    let chartViewURL: String
    let notes: String

    func toDictionary() -> [String: Any] {
        return [
            "asset": asset,
            "date": Timestamp(date: date),
            "day": day,
            "session": session,
            "isSessionTrading": isSessionTrading,
            "direction": direction,
            "risk": risk,
            "rr": rr,
            "entryCriteria": entryCriteria,
            "grade": grade,
            "outcome": outcome,
            "chartViewURL": chartViewURL,
            "notes": notes
        ]
    }
}
