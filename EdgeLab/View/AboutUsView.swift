//
//  AboutUsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-05-07.
//


import SwiftUI

struct AboutUsView: View {
    @State private var showLetters: [Bool] = Array(repeating: false, count: 7)
    let logoText = Array("EDGELAB")
    let animationDuration = 0.4  // Slightly faster

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // EDGELAB Animated Header
                HStack(spacing: 0) {
                    ForEach(0..<logoText.count, id: \.self) { index in
                        Text(String(logoText[index]))
                            .foregroundColor(index < 4 ? .white : .blue)
                            .font(.system(size: 34, weight: .black, design: .default))
                            .opacity(showLetters[index] ? 1 : 0)
                            .offset(y: showLetters[index] ? 0 : 10)
                            .animation(.easeOut(duration: animationDuration).delay(Double(index) * 0.07), value: showLetters[index])
                    }
                }
                .onAppear {
                    startLoopingAnimation()
                }

                Text("Automated Trading Journal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                SectionCard(title: "Our Vision", content:
                    "EdgeLab empowers traders by providing real-time analytics, automated journaling, and performance metrics to help optimize your strategy — whether you're trading Forex, Crypto, Stocks, or Commodities."
                )
                .frame(maxWidth: 600)

                SectionCard(title: "Developed By", content:
                    """
                    • Nuwan Mataraarachchi  
                    • H.M.C.V. Thennakoon
                    """
                )
                .frame(maxWidth: 600)

                SectionCard(title: "App Version", content: "1.0.0")
                    .frame(maxWidth: 600)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("About Us")
    }

    private func startLoopingAnimation() {
        Timer.scheduledTimer(withTimeInterval: animationDuration * Double(logoText.count) + 1.2, repeats: true) { _ in
            for i in 0..<logoText.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                    withAnimation {
                        showLetters[i] = true
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * Double(logoText.count) + 0.6) {
                withAnimation {
                    showLetters = Array(repeating: false, count: 7)
                }
            }
        }
    }
}

struct SectionCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(content)
                .foregroundColor(.gray)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground).opacity(0.15))
        )
    }
}

#Preview {
    NavigationView {
        AboutUsView()
            .preferredColorScheme(.dark)
    }
}
