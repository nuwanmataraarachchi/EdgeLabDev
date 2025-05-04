import SwiftUI
import FirebaseAuth

struct SignUp: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo
                Text("₿")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("CREATE ACCOUNT")
                    .font(.title)
                    .fontWeight(.bold)

                // Error Message
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
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                
                Button(action: {
                    viewModel.signUp()
                }) {
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
                    Button(action: {
                        // Google Sign-Up (Placeholder)
                    }) {
                        Text("G")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // Apple Sign-Up (Placeholder)
                    }) {
                        Image(systemName: "apple.logo")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }

                NavigationLink("Already have an account? Sign In", destination: SignIn())
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                
                Spacer()
            }
            .background(Color.white)
            .navigationDestination(isPresented: $viewModel.isSignedUp) {
                DashboardView()
            }
        }
    }
}

#Preview {
    SignUp()
}
