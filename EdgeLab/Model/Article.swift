//
//  Article.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation
import FirebaseAuth

struct ArticleModel: Identifiable {
    let id: String
    var title: String
    var content: String
    let category: String
    let authorId: String
    let authorName: String
    let date: Date
    var comments: [CommentModel]
    var likes: Int
    var views: Int
    var likedBy: [String]
    var viewedBy: [String]
    let imageUrl: String?
    
    var likedByCurrentUser: Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        return likedBy.contains(userId)
    }
}

struct CommentModel: Identifiable {
    let id: String
    let content: String
    let authorId: String
    let authorName: String
    let date: Date
}
