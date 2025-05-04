//
//  SignUpViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 5/4/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String? = nil
    @Published var isSignedUp: Bool = false
    
    private let authManager = AuthManager()
    private let db = Firestore.firestore()
    
    func signUp() {
        errorMessage = nil
        
        // Validate input
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        do {
            try authManager.validateCredentials(email: email, password: password, confirmPassword: confirmPassword)
        } catch AuthError.invalidEmail {
            errorMessage = "Invalid email format."
            return
        } catch AuthError.weakPassword {
            errorMessage = "Password must be at least 8 characters."
            return
        } catch AuthError.passwordsDontMatch {
            errorMessage = "Passwords do not match."
            return
        } catch {
            errorMessage = "An unexpected error occurred."
            return
        }
        
        // Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            // Successful authentication, save user details to Firestore
            if let user = result?.user {
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "fullName": self.fullName,
                    "email": self.email,
                    "createdAt": Timestamp(date: Date())
                ]
                
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                        return
                    }
                    
                    // Update user profile with full name
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.fullName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            return
                        }
                        
                        // Successful sign-up and data save
                        self.isSignedUp = true
                    }
                }
            }
        }
    }
}
