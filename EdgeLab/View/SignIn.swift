import SwiftUI
import FirebaseAuth

struct SignIn: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var isShowingSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo
                Text("₿")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("SIGN IN")
                    .font(.title)
                    .fontWeight(.bold)

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 30)
                }

                TextField("Username", text: $viewModel.email)
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
                
                HStack {
                    Spacer()
                    NavigationLink("Forgot Password?", destination: ResetPassword())
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                }

                Button(action: {
                    viewModel.signIn()
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
                        // Google Sign-In (Placeholder)
                    }) {
                        Text("G")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // Apple Sign-In (Placeholder)
                    }) {
                        Image(systemName: "apple.logo")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
 
                Button(action: {
                    isShowingSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }

                Spacer()
            }
            .background(Color.white)
            .navigationDestination(isPresented: $viewModel.isSignedIn) {
                DashboardView()
            }
            .navigationDestination(isPresented: $isShowingSignUp) {
                SignUp()
            }
        }
    }
}

#Preview {
    SignIn()
}
