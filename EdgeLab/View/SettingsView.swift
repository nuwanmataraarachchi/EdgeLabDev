//
//  SettingsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
