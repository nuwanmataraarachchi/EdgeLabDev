//
//  SignInViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 5/4/25.
//

import Foundation
import FirebaseAuth

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isSignedIn: Bool = false
    
    func signIn() {
        errorMessage = nil
        
        // Validate input
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            // Successful sign-in
            self.isSignedIn = true
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
            errorMessage = nil
            
            if email.isEmpty {
                errorMessage = "Please enter an email address."
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email is empty"])))
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                self.errorMessage = "Password reset email sent. Please check your inbox."
                completion(.success(()))
            }
        }
}
