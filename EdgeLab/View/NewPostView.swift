//
//  SwiftUIView.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import SwiftUI

struct NewPostView: View {
    @State private var title: String = ""
    @State private var selectedCategory: String = "Category"
    @State private var postContent: String = ""
    let categories = ["Category", "Tech", "Lifestyle", "News", "Other"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Title Field
                TextField("Title", text: $title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
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
                TextEditor(text: $postContent)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .foregroundColor(postContent.isEmpty ? .gray : .primary)
                    .onTapGesture {
                        if postContent == "Write Something..." {
                            postContent = ""
                        }
                    }
                
                // Bottom Toolbar
                HStack(spacing: 20) {
                    Button(action: {
                        // Add image action
                    }) {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Add link action
                    }) {
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Formatting action
                    }) {
                        Image(systemName: "textformat")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Submit post action
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
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
