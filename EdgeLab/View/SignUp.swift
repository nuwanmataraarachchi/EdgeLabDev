//
//  SignUp.swift
//  EdgeLab
//
//  Created by user270106 on 4/23/25.
//

import SwiftUI

struct SignUp: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            Text("₿")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("CREATE ACCOUNT")
                .font(.title)
                .fontWeight(.bold)

            TextField("Full name", text: $fullName)
                .padding()
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 30)
            
            TextField("Email", text: $email)
                .padding()
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 30)
            
            SecureField("Password", text: $password)
                .padding()
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 30)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 30)
            
            Button(action: {}) {
                Text("SIGN UP")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 30)
            
            Text("By Signing Up, you agree to our Terms and Privacy Policy")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                Text("or Sign Up with")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
       
            HStack(spacing: 40) {
                Button(action: {}) {
                    Text("G")
                        .font(.title)
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "apple.logo")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }

            Text("Already have an account? Sign In")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    SignUp()
}
