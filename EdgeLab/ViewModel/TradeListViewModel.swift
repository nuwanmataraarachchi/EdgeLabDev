//
//  TradeListViewModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-03.
//
import Foundation
import FirebaseFirestore

struct Trade: Identifiable, Equatable {
    var id: String
    var date: String
    var asset: String
    var direction: String
    var outcome: String
    var gain: Double
    var notes: String
    var risk: String
    var rr: String
    var entryCriteria: String
    var grade: String
    var session: String
    var isSessionTrading: Bool
    var chartViewURL: String
    
    static func == (lhs: Trade, rhs: Trade) -> Bool {
        return lhs.id == rhs.id
    }
}

class TradeListViewModel: ObservableObject {
    @Published var trades: [Trade] = []
    private var db = Firestore.firestore()

    init() {
        fetchTrades()
    }

    // MARK: - Fetch Trades
    func fetchTrades() {
        db.collection("trades")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching trades: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found.")
                    return
                }

                self.trades = documents.compactMap { doc -> Trade? in
                    let data = doc.data()
                    let id = doc.documentID
                    let date = data["date"] as? String ?? "N/A"
                    let asset = data["asset"] as? String ?? "N/A"
                    let direction = data["direction"] as? String ?? "N/A"
                    let outcome = data["outcome"] as? String ?? "N/A"
                    let gain = data["gain"] as? Double ?? 0.0
                    let notes = data["notes"] as? String ?? ""
                    let risk = data["risk"] as? String ?? "0"
                    let rr = data["rr"] as? String ?? "0"
                    let entryCriteria = data["entryCriteria"] as? String ?? ""
                    let grade = data["grade"] as? String ?? "C"
                    let session = data["session"] as? String ?? "N/A"
                    let isSessionTrading = data["isSessionTrading"] as? Bool ?? false
                    let chartViewURL = data["chartViewURL"] as? String ?? ""
                    
                    return Trade(
                        id: id,
                        date: date,
                        asset: asset,
                        direction: direction,
                        outcome: outcome,
                        gain: gain,
                        notes: notes,
                        risk: risk,
                        rr: rr,
                        entryCriteria: entryCriteria,
                        grade: grade,
                        session: session,
                        isSessionTrading: isSessionTrading,
                        chartViewURL: chartViewURL
                    )
                }
            }
    }

    // MARK: - Update Notes
    func updateNotes(for trade: Trade, with newNotes: String) {
        db.collection("trades").document(trade.id).updateData(["notes": newNotes]) { error in
            if let error = error {
                print("Failed to update notes: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete Trade
    func deleteTrade(_ trade: Trade) {
        db.collection("trades").document(trade.id).delete { error in
            if let error = error {
                print("Failed to delete trade: \(error.localizedDescription)")
            }
        }
    }
}
