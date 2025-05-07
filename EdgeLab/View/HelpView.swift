//
//  HelpView.swift
//  EdgeLab
//
//  Created by user270106 on 5/7/25.
//

import SwiftUI
import Combine

// Model for FAQ Item
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// ViewModel for Help and Info Screen
class HelpViewModel: ObservableObject {
    @Published var faqItems: [FAQItem] = [
        FAQItem(question: "How do I add a trade?", answer: "Navigate to the Trade History section, tap 'Add Trade', and enter details like entry price, exit price, and emotional tags."),
        FAQItem(question: "What is the psychological analysis feature?", answer: "This feature analyzes emotional tags you assign to trades to provide insights into your trading behavior, such as identifying impulsive decisions."),
        FAQItem(question: "How do I view my weekly performance?", answer: "Go to the Dashoboard to see a weekly summary view button and when you click on that the you can see a analysis of your win rate, risk/reward ratio, and total gains."),
        FAQItem(question: "Can I use EdgeLab offline?", answer: "Yes, trades are stored locally using CoreData, allowing you to log and view trades without an internet connection.")
    ]
    
    @Published var appFeatures: [String] = [
        "Automatic trade logging and organization",
        "Real-time analytics with win rate and risk/reward ratio",
        "Psychological insights based on emotional tags",
        "Community interaction for sharing articles",
    ]
    
    @Published var contactInfo: String = "For support, email us at nuwanm.info@gmail.com"
}

// Help and Info View
struct HelpView: View {
    @StateObject private var viewModel = HelpViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App Features")
                    .foregroundColor(.accentColor)
                    .font(.headline)) {
                    ForEach(viewModel.appFeatures, id: \.self) { feature in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(feature)
                                .foregroundColor(.white)
                                .font(.body)
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                Section(header: Text("Frequently Asked Questions")
                    .foregroundColor(.accentColor)
                    .font(.headline)) {
                    ForEach(viewModel.faqItems) { faq in
                        DisclosureGroup {
                            Text(faq.answer)
                                .foregroundColor(.gray)
                                .font(.body)
                                .padding(.top, 4)
                        } label: {
                            Text(faq.question)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
                
                Section(header: Text("Contact Us")
                    .foregroundColor(.accentColor)
                    .font(.headline)) {
                    Text(viewModel.contactInfo)
                        .foregroundColor(.white)
                        .font(.body)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.black)
            .navigationTitle("Help & Info")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        .accentColor(.cyan)
    }
}

// Preview
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .preferredColorScheme(.dark)
    }
}
