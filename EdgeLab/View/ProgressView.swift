//
//  ProgressView.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("Weekly Progress")
                        .font(.headline)
                    
                    Text("No Data to Show")
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                    
                    Spacer()
                }
            }
            .navigationTitle("My Progress")
            .navigationBarItems(leading: Button(action: {
                // Back button action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
