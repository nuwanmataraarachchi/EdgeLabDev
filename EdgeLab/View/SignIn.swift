//
//  SignIn.swift
//  EdgeLab
//
//  Created by user270106 on 4/23/25.
//

import SwiftUI

struct SignIn: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            Text("₿")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("SIGN IN")
                .font(.title)
                .fontWeight(.bold)

            TextField("Username", text: $email)
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
            
            HStack {
                Spacer()
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
            }

            Button(action: {
            }) {
                Text("SIGN IN")
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

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                Text("or")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            
            HStack(spacing: 40) {
                Button(action: {
                }) {
                    Text("G")
                        .font(.title)
                        .foregroundColor(.black)
                }
                
                Button(action: {
                }) {
                    Image(systemName: "apple.logo")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
 
            Text("Don't have an account? Sign Up")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    SignIn()
}
