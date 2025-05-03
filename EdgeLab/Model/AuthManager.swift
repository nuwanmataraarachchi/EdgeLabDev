//
//  AuthManager.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation

class AuthManager {
    private var users: [User] = []
    
    func signUp(email: String, password: String, confirmPassword: String) throws -> User {
        if !isValidEmail(email) {
            throw AuthError.invalidEmail
        }
        if password.count < 8 {
            throw AuthError.weakPassword
        }
        if password != confirmPassword {
            throw AuthError.passwordsDontMatch
        }
        if users.contains(where: { $0.email == email }) {
            throw AuthError.emailAlreadyExists
        }
        
        let newUser = User(email: email, password: password, username: email, tradingPreferences: [])
        users.append(newUser)
        return newUser
    }
    
    func signIn(email: String, password: String) throws -> User {
        guard let user = users.first(where: { $0.email == email && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        return user
    }
    
    func validateCredentials(email: String, password: String, confirmPassword: String) throws -> Bool {
        if !isValidEmail(email) {
            throw AuthError.invalidEmail
        }
        if password.count < 8 {
            throw AuthError.weakPassword
        }
        if password != confirmPassword {
            throw AuthError.passwordsDontMatch
        }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
