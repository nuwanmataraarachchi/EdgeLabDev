//
//  SwiftUIView.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import SwiftUI
import PhotosUI

struct NewPostView: View {
    @StateObject private var viewModel = NewPostViewModel()
    @State private var photosPickerItem: PhotosPickerItem? = nil
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLinkInput = false
    @State private var linkText = ""
    let categories = ["Category", "Trading", "Lifestyle", "News", "Crypto"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                // Title Field
                TextField("Title", text: $viewModel.title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textFieldStyle(PlainTextFieldStyle())
                    .lineLimit(1)
                    .disableAutocorrection(false)
                    .onChange(of: viewModel.title) { newValue in
                        let wordCount = newValue.split(separator: " ").count
                        if wordCount > 20 {
                            viewModel.title = newValue.split(separator: " ").prefix(20).joined(separator: " ")
                        }
                    }
                
                // Category Picker
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Text Editor
                TextEditor(text: $viewModel.postContent)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .foregroundColor(viewModel.postContent.isEmpty ? .gray : .primary)
                    .disableAutocorrection(false)
                    .textInputAutocapitalization(.sentences)
                    .onTapGesture {
                        if viewModel.postContent == "Write Something..." {
                            viewModel.postContent = ""
                        }
                    }
                
                // Image Preview (if selected)
                if let image = viewModel.selectedImage {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.clearImage()
                            photosPickerItem = nil
                        }) {
                            Text("Remove Image")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Bottom Toolbar
                HStack(spacing: 20) {
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    .onChange(of: photosPickerItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                viewModel.selectedImage = uiImage
                            }
                        }
                    }
                    
                    Button(action: {
                        showLinkInput = true
                    }) {
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                    }
                    .sheet(isPresented: $showLinkInput) {
                        VStack {
                            Text("Enter Link")
                                .font(.headline)
                                .padding()
                            TextField("https://example.com", text: $linkText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            HStack {
                                Button("Cancel") {
                                    showLinkInput = false
                                    linkText = ""
                                }
                                .padding()
                                Button("Add") {
                                    if !linkText.isEmpty {
                                        viewModel.postContent += "\n[Link](\(linkText))"
                                        showLinkInput = false
                                        linkText = ""
                                    }
                                }
                                .padding()
                                .disabled(linkText.isEmpty)
                            }
                        }
                        .presentationDetents([.medium])
                    }
                    
                    Button(action: {
                        // Formatting action (placeholder)
                    }) {
                        Image(systemName: "textformat")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.createPost()
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Post Creation"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("OK")) {
                        viewModel.clearForm()
                        dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                    }
                )
            }
            .onChange(of: viewModel.isPostCreated) { isCreated in
                if isCreated {
                    alertMessage = "Article posted successfully!"
                    showAlert = true
                }
            }
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
