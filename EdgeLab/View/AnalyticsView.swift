//
//  AnalyticsView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.


import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Analytics View")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .foregroundColor(.white)
            
            // Stats Rows
            VStack(spacing: 12) {
                HStack {
                    StatBlock(title: "Win Rate", value: "60%", icon: "percent")
                    StatBlock(title: "Total Trades", value: "150", icon: "number")
                    StatBlock(title: "Avg Profit", value: "$498.90", icon: "dollarsign.circle")
                }
                
                HStack {
                    StatBlock(title: "Session Win Rate", value: "75%", icon: "clock.arrow.circlepath")
                    StatBlock(title: "Losses", value: "50", icon: "chart.bar.xaxis")
                    StatBlock(title: "Risk/Reward", value: "1:3.5", icon: "info.circle")
                }
            }
            
            // Placeholder for Accumulative P&L (Graph)
            VStack(alignment: .leading) {
                Text("Accumulative P&L")
                    .font(.headline)
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 120)
                    .overlay(
                        Text("Graph Placeholder\n$4K → -$2K")
                            .foregroundColor(.gray)
                    )
                
                HStack {
                    Text("Jan 23, 24")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Feb 09, 24")
                        .foregroundColor(.gray)
                }
                .font(.caption)
            }
            
            // Last Trades Preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Last Five Trades")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(sampleTrades.prefix(5), id: \.self) { trade in
                    HStack {
                        Text(trade.type)
                            .fontWeight(.bold)
                            .foregroundColor(trade.type == "L" ? .green : .red)
                        Text(trade.asset)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(trade.date)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(trade.pl)
                            .foregroundColor(trade.pl.contains("-") ? .red : .green)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
        .cornerRadius(12)
        .navigationBarTitle("Analytics", displayMode: .inline)
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
    }
}

struct TradePreview: Hashable {
    let type: String
    let asset: String
    let date: String
    let pl: String
}

let sampleTrades: [TradePreview] = [
    TradePreview(type: "[L]", asset: "INJ", date: "Feb 09, 24", pl: "+$805.61"),
    TradePreview(type: "[S]", asset: "RUNE", date: "Feb 05, 24", pl: "-$953.17"),
    TradePreview(type: "[S]", asset: "AVAX", date: "Jan 28, 24", pl: "-$306.44"),
    TradePreview(type: "[L]", asset: "SOL", date: "Jan 27, 24", pl: "+$1,306.00"),
    TradePreview(type: "[L]", asset: "ALGO", date: "Jan 23, 24", pl: "-$263.85"),
]

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .preferredColorScheme(.dark)
    }
}
