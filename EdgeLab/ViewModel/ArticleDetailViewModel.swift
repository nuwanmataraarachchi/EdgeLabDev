//
//  ArticleDetailViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 5/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ArticleDetailViewModel: ObservableObject {
    @Published var article: ArticleModel
    private let db = Firestore.firestore()
    
    init(article: ArticleModel) {
        self.article = article
    }
    
    func incrementViews() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        if article.viewedBy.contains(userId) { return }
        
        article.views += 1
        article.viewedBy.append(userId)
        
        db.collection("articles").document(article.id).updateData([
            "views": article.views,
            "viewedBy": article.viewedBy
        ])
    }
    
    func toggleLike() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if article.likedBy.contains(userId) {
            article.likes -= 1
            article.likedBy.removeAll { $0 == userId }
        } else {
            article.likes += 1
            article.likedBy.append(userId)
        }
        
        db.collection("articles").document(article.id).updateData([
            "likes": article.likes,
            "likedBy": article.likedBy
        ])
    }
    
    func addComment(content: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        let comment = CommentModel(
            id: UUID().uuidString,
            content: content,
            authorId: user.uid,
            authorName: user.displayName ?? "Unknown",
            date: Date()
        )
        
        article.comments.append(comment)
        
        db.collection("articles").document(article.id).updateData([
            "comments": FieldValue.arrayUnion([[
                "id": comment.id,
                "content": comment.content,
                "authorId": comment.authorId,
                "authorName": comment.authorName,
                "date": Timestamp(date: comment.date)
            ]])
        ])
    }
}
