//
//  NewPostViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 5/4/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class NewPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedCategory: String = "Category"
    @Published var postContent: String = ""
    @Published var errorMessage: String? = nil
    @Published var isPostCreated: Bool = false
    @Published var selectedImage: UIImage? = nil
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func createPost() {
        errorMessage = nil
        
        // Validate title word count
        let titleWords = title.split(separator: " ").count
        if titleWords > 20 {
            errorMessage = "Title cannot exceed 20 words."
            return
        }
        
        // Validate input
        if title.isEmpty || postContent.isEmpty || selectedCategory == "Category" {
            errorMessage = "Please fill in all fields and select a valid category."
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be signed in to create a post."
            return
        }
        
        // Prepare article data
        let articleId = UUID().uuidString
        var articleData: [String: Any] = [
            "id": articleId,
            "title": title,
            "content": postContent,
            "category": selectedCategory,
            "authorId": user.uid,
            "authorName": user.displayName ?? "Unknown",
            "date": Timestamp(date: Date()),
            "comments": []
        ]
        
        // Handle image upload if an image is selected
        if let image = selectedImage {
            uploadImage(image: image, articleId: articleId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let imageUrl):
                    articleData["imageUrl"] = imageUrl
                    self.saveArticle(articleData: articleData)
                case .failure(let error):
                    self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                }
            }
        } else {
            // No image selected, save article directly
            saveArticle(articleData: articleData)
        }
    }
    
    private func uploadImage(image: UIImage, articleId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
            return
        }
        
        let storageRef = storage.reference().child("article_images/\(articleId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"])))
                }
            }
        }
    }
    
    private func saveArticle(articleData: [String: Any]) {
        db.collection("articles").document(articleData["id"] as! String).setData(articleData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Failed to save article: \(error.localizedDescription)"
                return
            }
            
            self.isPostCreated = true
        }
    }
    
    func clearImage() {
        selectedImage = nil
    }
    
    func clearForm() {
        title = ""
        selectedCategory = "Category"
        postContent = ""
        selectedImage = nil
    }
}
