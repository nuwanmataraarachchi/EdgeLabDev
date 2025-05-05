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
    
    init(article: ArticleModel) {
        _viewModel = StateObject(wrappedValue: ArticleDetailViewModel(article: article))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Article Header
                Text(viewModel.article.title)
                    .font(.title)
                    .fontWeight(.bold)
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
                    }
                    .padding(.horizontal)
                }
                
                // Article Content
                Text(viewModel.article.content)
                    .font(.body)
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
                Text("Comments (\(viewModel.article.comments.count))")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Comment Input
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        if !newComment.isEmpty {
                            viewModel.addComment(content: newComment)
                            newComment = ""
                        }
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Display Comments
                ForEach(viewModel.article.comments) { comment in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(comment.authorName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(comment.content)
                            .font(.body)
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
        .navigationBarItems(leading: Button(action: {
            // Dismiss action handled by NavigationLink in parent view
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
        })
        .onAppear {
            viewModel.incrementViews()
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
        NavigationView {
            ArticleDetailView(article: article)
        }
    }
}
