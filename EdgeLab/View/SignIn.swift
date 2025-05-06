import SwiftUI
import FirebaseAuth

struct SignIn: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var isShowingSignUp = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("₿")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top, 40)

                    Text("SIGN IN")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal, 30)
                    }

                    TextField("Username", text: $viewModel.email)
                        .padding()
                        .frame(height: 50)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(height: 50)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                    
                    HStack {
                        Spacer()
                        NavigationLink("Forgot Password?", destination: ResetPassword())
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 30)
                    }

                    Button(action: {
                        viewModel.signIn()
                    }) {
                        Text("SIGN IN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)

                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("or")
                            .foregroundColor(Color.gray.opacity(0.7))
                            .padding(.horizontal, 10)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 30)
                    
                    HStack(spacing: 40) {
                        Button(action: {
                        }) {
                            Text("G")
                                .font(.title)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                        }) {
                            Image(systemName: "apple.logo")
                                .font(.title)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(25)
                        }
                    }
     
                    Button(action: {
                        isShowingSignUp = true
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.bottom, 40)
                    }

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $viewModel.isSignedIn) {
                DashboardView()
            }
            .navigationDestination(isPresented: $isShowingSignUp) {
                SignUp()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SignIn()
}
