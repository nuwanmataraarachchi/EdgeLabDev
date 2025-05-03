//
//  TradeEntryViewModel.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-03.
//

import Foundation
import FirebaseFirestore

class TradeEntryViewModel: ObservableObject {
    private let db = Firestore.firestore()

    func saveTrade(trade: TradeModel, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("trades").addDocument(data: trade.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
