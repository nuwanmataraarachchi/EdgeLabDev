//
//  AnalyticsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//
import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Text("Analytics View")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .navigationBarTitle("Analytics", displayMode: .inline)
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}

