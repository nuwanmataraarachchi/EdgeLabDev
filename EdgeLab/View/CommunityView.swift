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
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .center) {
                        Text("Browse trading insights, strategies, and experiences shared by fellow traders in the community.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Text("Community")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if viewModel.othersArticles.isEmpty {
                            Text("No Article to Show")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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

                    VStack(alignment: .leading) {
                        Text("Your Articles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        if viewModel.userArticles.isEmpty {
                           Text("No Article to Show")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .frame(height: 200)
                                )
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
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
                
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
        }
    }
}

// Article Tile Component
struct ArticleTile: View {
    let article: ArticleModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                        .tint(.white)
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
                .foregroundColor(.white)
            
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
