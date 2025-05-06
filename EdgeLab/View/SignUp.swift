import SwiftUI
import FirebaseAuth

struct SignUp: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("₿")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .foregroundColor(.white)
                    
                    Text("CREATE ACCOUNT")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal, 30)
                    }

                    TextField("Full name", text: $viewModel.fullName)
                        .padding()
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .padding()
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Button(action: {
                        viewModel.signUp()
                    }) {
                        Text("SIGN UP")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
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
                            .foregroundColor(.gray.opacity(0.5))
                        Text("or")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 30)
                    
                    Text("Sign Up With")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
               
                    HStack(spacing: 40) {
                        Button(action: {
                        }) {
                            Text("G")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                        }) {
                            Image(systemName: "apple.logo")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }

                    NavigationLink("Already have an account? Sign In", destination: SignIn())
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $viewModel.isSignedUp) {
                DashboardView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SignUp()
}
