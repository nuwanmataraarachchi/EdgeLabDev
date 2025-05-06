//
//  ArticleDetailView.swift
//  EdgeLab
//
//  Created by user270106 on 5/5/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @State private var newComment: String = ""
    @State private var showingActionSheet = false
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    
    init(article: ArticleModel) {
        _viewModel = StateObject(wrappedValue: ArticleDetailViewModel(article: article))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Article Header
                    Text(viewModel.article.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("by \(viewModel.article.authorName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(viewModel.article.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Thumbnail (if available)
                    if let imageUrl = viewModel.article.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                                .frame(height: 200)
                                .tint(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Article Content
                    Text(viewModel.article.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Likes Section
                    HStack {
                        Button(action: {
                            viewModel.toggleLike()
                        }) {
                            Image(systemName: viewModel.article.likedByCurrentUser ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.article.likedByCurrentUser ? .red : .gray)
                            Text("\(viewModel.article.likes) Likes")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(viewModel.article.views) Views")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Comments Section
                    Divider()
                        .background(Color.gray)
                    Text("Comments (\(viewModel.article.comments.count))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Comment Input
                    HStack {
                        TextField("Add a comment...", text: $newComment)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Button(action: {
                            if !newComment.isEmpty {
                                viewModel.addComment(content: newComment)
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Display Comments
                    ForEach(viewModel.article.comments) { comment in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(comment.authorName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(comment.content)
                                .font(.body)
                                .foregroundColor(.white)
                            Text(comment.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isCurrentUserAuthor {
                        Button(action: {
                            showingActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .confirmationDialog("Article Options", isPresented: $showingActionSheet) {
                Button("Edit Article") {
                    showingEditView = true
                }
                Button("Delete Article", role: .destructive) {
                    viewModel.deleteArticle {
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(isPresented: $showingEditView) {
                EditArticleView(article: $viewModel.article)
            }
            .onAppear {
                viewModel.incrementViews()
            }
        }
    }
}

// Placeholder for EditArticleView
struct EditArticleView: View {
    @Binding var article: ArticleModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    
    init(article: Binding<ArticleModel>) {
        self._article = article
        self._title = State(initialValue: article.wrappedValue.title)
        self._content = State(initialValue: article.wrappedValue.content)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title").foregroundColor(.white)) {
                    TextField("Title", text: $title)
                        .foregroundColor(.white)
                        .listRowBackground(Color.gray.opacity(0.2))
                }
                Section(header: Text("Content").foregroundColor(.white)) {
                    TextEditor(text: $content)
                        .foregroundColor(.white)
                        .frame(height: 200)
                        .listRowBackground(Color.gray.opacity(0.2))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .foregroundColor(.white)
            .navigationTitle("Edit Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        self.article.title = title
                        self.article.content = content
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let article = ArticleModel(
            id: "1",
            title: "Sample Article",
            content: "This is a sample article content.",
            category: "Tech",
            authorId: "user1",
            authorName: "Test User",
            date: Date(),
            comments: [],
            likes: 5,
            views: 10,
            likedBy: [],
            viewedBy: [],
            imageUrl: nil
        )
        NavigationStack {
            ArticleDetailView(article: article)
        }
    }
}
