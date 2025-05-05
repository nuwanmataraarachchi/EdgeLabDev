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
                    
                    return Trade(id: id, date: date, asset: asset, direction: direction, outcome: outcome, gain: gain, notes: notes)
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
