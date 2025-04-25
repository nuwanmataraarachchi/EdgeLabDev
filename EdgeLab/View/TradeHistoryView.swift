//
//  TradeHistoryView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct TradeHistoryView: View {
    var body: some View {
        VStack {
            Text("Trade History View")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .navigationBarTitle("Trade History", displayMode: .inline)
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView()
    }
}
