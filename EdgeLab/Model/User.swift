//
//  User.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation

class User: Identifiable, ObservableObject {
    let id: UUID
    @Published var email: String
    @Published var password: String
    @Published var username: String
    @Published var tradingPreferences: [String]
    
    init(id: UUID = UUID(), email: String, password: String, username: String, tradingPreferences: [String] = []) {
        self.id = id
        self.email = email
        self.password = password
        self.username = username
        self.tradingPreferences = tradingPreferences
    }
    
    func updateProfile(email: String, username: String, tradingPreferences: [String]) {
        self.email = email
        self.username = username
        self.tradingPreferences = tradingPreferences
    }
}
