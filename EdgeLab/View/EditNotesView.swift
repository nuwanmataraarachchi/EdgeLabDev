//
//  EditNotesView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-03.
//


import SwiftUI

struct EditNotesView: View {
    let trade: Trade
    @Binding var editedNotes: String
    let saveAction: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Notes for Trade on \(trade.date)")
                    .font(.headline)

                TextEditor(text: $editedNotes)
                    .padding()
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                Spacer()

                Button(action: {
                    saveAction()
                }) {
                    Text("Save Notes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Edit Notes")
            .navigationBarItems(trailing: Button("Cancel") {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            })
        }
    }
}
