import SwiftUI
import FirebaseAuth

struct ResetPassword: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var email: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            Text("₿")
                .font(.system(size: 60))
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("FORGOT PASSWORD?")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)

            TextField("@ Email Address", text: $email)
                .padding()
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 30)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            Button(action: {
                viewModel.sendPasswordReset(email: email) { result in
                    switch result {
                    case .success:
                        alertMessage = viewModel.errorMessage ?? "Password reset email sent successfully."
                        showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            dismiss()
                        }
                    case .failure(let error):
                        alertMessage = viewModel.errorMessage ?? "Failed to send reset email: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }) {
                Text("SEND RESET LINK")
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
            .disabled(email.isEmpty)

            Text("Use Phone Number Instead")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Spacer()

            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                    Text("Back to Sign In")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Reset Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ResetPassword()
}
