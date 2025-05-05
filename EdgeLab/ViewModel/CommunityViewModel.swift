//
//  CommunityViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 5/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class CommunityViewModel: ObservableObject {
    @Published var othersArticles: [ArticleModel] = []
    @Published var userArticles: [ArticleModel] = []
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        fetchArticles()
    }
    
    func fetchArticles() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to view articles."
            return
        }
        
        db.collection("articles").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Failed to fetch articles: \(error.localizedDescription)"
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No articles found."
                return
            }
            
            let articles = documents.compactMap { doc -> ArticleModel? in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let title = data["title"] as? String,
                      let content = data["content"] as? String,
                      let category = data["category"] as? String,
                      let authorId = data["authorId"] as? String,
                      let authorName = data["authorName"] as? String,
                      let dateTimestamp = data["date"] as? Timestamp,
                      let commentsData = data["comments"] as? [[String: Any]] else {
                    return nil
                }
                
                let comments = commentsData.compactMap { commentData -> CommentModel? in
                    guard let id = commentData["id"] as? String,
                          let content = commentData["content"] as? String,
                          let authorId = commentData["authorId"] as? String,
                          let authorName = commentData["authorName"] as? String,
                          let dateTimestamp = commentData["date"] as? Timestamp else {
                        return nil
                    }
                    return CommentModel(id: id, content: content, authorId: authorId, authorName: authorName, date: dateTimestamp.dateValue())
                }
                
                let likes = data["likes"] as? Int ?? 0
                let views = data["views"] as? Int ?? 0
                let likedBy = data["likedBy"] as? [String] ?? []
                let viewedBy = data["viewedBy"] as? [String] ?? []
                let imageUrl = data["imageUrl"] as? String
                
                return ArticleModel(
                    id: id,
                    title: title,
                    content: content,
                    category: category,
                    authorId: authorId,
                    authorName: authorName,
                    date: dateTimestamp.dateValue(),
                    comments: comments,
                    likes: likes,
                    views: views,
                    likedBy: likedBy,
                    viewedBy: viewedBy,
                    imageUrl: imageUrl
                )
            }
            
            self.othersArticles = articles.filter { $0.authorId != userId }
            self.userArticles = articles.filter { $0.authorId == userId }
        }
    }
}
