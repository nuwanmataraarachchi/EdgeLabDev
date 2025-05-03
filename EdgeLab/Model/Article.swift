//
//  Article.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation

// Comment Struct
struct Comment: Identifiable {
    let id: UUID
    let content: String
    let author: User
    let date: Date
    
    init(id: UUID = UUID(), content: String, author: User, date: Date = Date()) {
        self.id = id
        self.content = content
        self.author = author
        self.date = date
    }
}

// Article Class
class Article: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var content: String
    let author: User
    let date: Date
    @Published private(set) var comments: [Comment]
    
    init(id: UUID = UUID(), title: String, content: String, author: User, date: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.author = author
        self.date = date
        self.comments = []
    }
    
    func addComment(comment: Comment) {
        comments.append(comment)
    }
    
    func getComments() -> [Comment] {
        return comments
    }
}
