// PnLChartViewModel.swift
// EdgeLab
//
// Created by Nuwan Mataraarachchi on 2025-05-04.
// PnLChartViewModel.swift
// EdgeLab

import Foundation
import FirebaseFirestore
import Combine

class PnLChartViewModel: ObservableObject {
    @Published var accumulatedData: [PnLData] = []

    private let db = Firestore.firestore()
    private let userID = "YOUR_USER_ID" // Replace with actual user ID or auth logic

    init() {
        fetchTrades()
    }

    func fetchTrades() {
        db.collection("trades")
            .whereField("userId", isEqualTo: userID)
            .order(by: "date")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Failed to fetch trades: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                var accumulated: [PnLData] = []
                var runningTotal: Double = 0.0

                for doc in documents {
                    let data = doc.data()

                    guard let gainLoss = data["gainLoss"] as? Double,
                          let timestamp = data["date"] as? Timestamp else {
                        continue
                    }

                    let date = timestamp.dateValue()
                    runningTotal += gainLoss
                    accumulated.append(PnLData(date: date, gainLoss: runningTotal))
                }

                DispatchQueue.main.async {
                    self.accumulatedData = accumulated
                }
            }
    }
}
