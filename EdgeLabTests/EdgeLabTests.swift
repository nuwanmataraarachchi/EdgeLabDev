//
//  EdgeLabTests.swift
//  EdgeLabTests
//
//  Created by Nuwan Mataraarachchi on 2025-04-20.
//

import XCTest
@testable import EdgeLab

final class AuthenticationTests: XCTestCase {
    var authManager: AuthManager!
    
    override func setUp() {
        super.setUp()
        authManager = AuthManager()
    }
    
    override func tearDown() {
        authManager = nil
        super.tearDown()
    }
    
    // Sign Up Tests
    
    func testSuccessfulSignUp() throws {
        let email = "test@example.com"
        let password = "password123"
        let confirmPassword = "password123"
        
        let user = try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)
        
        XCTAssertEqual(user.email, email, "User email should match the input email")
    }
    
    func testSignUpWithInvalidEmail() {
        let email = "invalid-email"
        let password = "password123"
        let confirmPassword = "password123"
        
        XCTAssertThrowsError(try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)) { error in
            XCTAssertEqual(error as? AuthError, .invalidEmail, "Should throw invalid email error")
        }
    }
    
    func testSignUpWithWeakPassword() {
        let email = "test@example.com"
        let password = "weak"
        let confirmPassword = "weak"
        
        XCTAssertThrowsError(try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)) { error in
            XCTAssertEqual(error as? AuthError, .weakPassword, "Should throw weak password error")
        }
    }
    
    func testSignUpWithMismatchedPasswords() {
        let email = "test@example.com"
        let password = "password123"
        let confirmPassword = "different123"
        
        XCTAssertThrowsError(try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)) { error in
            XCTAssertEqual(error as? AuthError, .passwordsDontMatch, "Should throw passwords don't match error")
        }
    }
    
    func testSignUpWithExistingEmail() throws {
        let email = "existing@example.com"
        let password = "password123"
        let confirmPassword = "password123"

        _ = try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)

        XCTAssertThrowsError(try authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)) { error in
            XCTAssertEqual(error as? AuthError, .emailAlreadyExists, "Should throw email already exists error")
        }
    }
    
    // Sign In Tests
    
    func testSuccessfulSignIn() throws {
        let email = "signin@example.com"
        let password = "password123"

        _ = try authManager.signUp(email: email, password: password, confirmPassword: password)
        
        let user = try authManager.signIn(email: email, password: password)
        XCTAssertEqual(user.email, email, "Signed in user email should match")
    }
    
    func testSignInWithInvalidCredentials() {
        let email = "nonexistent@example.com"
        let password = "wrongpassword"
        
        XCTAssertThrowsError(try authManager.signIn(email: email, password: password)) { error in
            XCTAssertEqual(error as? AuthError, .invalidCredentials, "Should throw invalid credentials error")
        }
    }
    
    func testSignInWithWrongPassword() throws {
        let email = "wrongpass@example.com"
        let password = "correct123"
        let wrongPassword = "wrong123"

        _ = try authManager.signUp(email: email, password: password, confirmPassword: password)
        
        XCTAssertThrowsError(try authManager.signIn(email: email, password: wrongPassword)) { error in
            XCTAssertEqual(error as? AuthError, .invalidCredentials, "Should throw invalid credentials error")
        }
    }
}

