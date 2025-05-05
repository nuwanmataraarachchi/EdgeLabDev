//
//  CommunityView.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var isShowingNewPost = false
    @State private var selectedArticle: ArticleModel?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Community Articles Section
                    VStack(alignment: .center) {
                        Text("Community")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        if viewModel.othersArticles.isEmpty {
                            Text("No Article to Show")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 0)
                                        .frame(height: 200)
                                )
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(viewModel.othersArticles) { article in
                                        ArticleTile(article: article)
                                            .onTapGesture {
                                                selectedArticle = article
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height / 3)
                    
                    // Your Articles Section
                    VStack(alignment: .leading) {
                        Text("Your Articles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.userArticles.isEmpty {
                            HStack(spacing: 10) {
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 150, height: 100)
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 150, height: 100)
                            }
                            .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.userArticles.prefix(2)) { article in
                                        ArticleTile(article: article)
                                            .onTapGesture {
                                                selectedArticle = article
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height / 3)
                    
                    Spacer()
                }
                
                // Floating Plus Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingNewPost = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                
                // Navigation Links
                NavigationLink(
                    destination: NewPostView(),
                    isActive: $isShowingNewPost
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: selectedArticle.map { ArticleDetailView(article: $0) },
                    isActive: Binding(
                        get: { selectedArticle != nil },
                        set: { if !$0 { selectedArticle = nil } }
                    )
                ) {
                    EmptyView()
                }
            }
            .navigationBarItems(leading: Button(action: {
                // Back button action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
        }
    }
}

// Article Tile Component
struct ArticleTile: View {
    let article: ArticleModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Thumbnail (if available)
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 100)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 100)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 100)
                    .cornerRadius(8)
                    .overlay(
                        Text("No Image")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            }
            
            // Title
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
                .frame(width: 150)
            
            // Stats
            HStack(spacing: 10) {
                Label("\(article.likes)", systemImage: "heart")
                    .font(.caption)
                    .foregroundColor(.gray)
                Label("\(article.views)", systemImage: "eye")
                    .font(.caption)
                    .foregroundColor(.gray)
                Label("\(article.comments.count)", systemImage: "bubble.left")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 150)
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
