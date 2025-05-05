//
//  SettingsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var user = User(email: "", password: "", username: "")
    @StateObject private var report = WeeklyReport(weekStart: Date())
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Picture with Edit Icon
                VStack(spacing: 10) {
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    Text(user.username)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                // Edit Name and Email
                Form {
                    TextField("Username", text: $user.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Email", text: $user.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Button("Save Changes") {
                        user.updateProfile(email: user.email, username: user.username, tradingPreferences: user.tradingPreferences)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                // Stats Section
                HStack(spacing: 10) {
                    StatCard(title: "Win Rate", value: "\(String(format: "%.1f", report.winRate))%", color: .green)
                    StatCard(title: "Net P&L", value: "\(String(format: "%.2f", report.profitLoss))", color: report.profitLoss >= 0 ? .green : .red)
                    StatCard(title: "Trades", value: "\(report.tradeFrequency)", color: .blue)
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .alert(isPresented: $showingLogoutAlert) {
                        Alert(
                            title: Text("Log Out"),
                            message: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Log Out")) {
                                do {
                                    try Auth.auth().signOut()
                                    if let window = UIApplication.shared.windows.first {
                                        window.rootViewController = UIHostingController(rootView: SignIn())
                                        window.makeKeyAndVisible()
                                    }
                                } catch {
                                    print("Error logging out: \(error.localizedDescription)")
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                if let user = Auth.auth().currentUser {
                                    user.delete { error in
                                        if let error = error {
                                            print("Error deleting account: \(error.localizedDescription)")
                                        } else {
                                            if let window = UIApplication.shared.windows.first {
                                                window.rootViewController = UIHostingController(rootView: SignUp())
                                                window.makeKeyAndVisible()
                                            }
                                        }
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .background(Color.white)        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Placeholder for SignInView (replace with actual implementation)
struct SignInView: View {
    var body: some View {
        Text("Sign In View")
            .navigationBarTitle("Sign In")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
