//
//  CommunityView.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import SwiftUI

struct CommunityView: View {
    @State private var isShowingNewPost = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("No Article to Show")
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                    
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
                
                // NavigationLink for NewPostView
                NavigationLink(
                    destination: NewPostView(),
                    isActive: $isShowingNewPost
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Community")
            .navigationBarItems(leading: Button(action: {
                // Back button action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
