//
//  TradeHistoryView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//
import SwiftUI

struct TradeHistoryView: View {
    // Sample hardcoded data
    let trades = [
        ("2025-04-23", "ETHUSDT", "Long", "Win", 2.4),
        ("2025-04-22", "EURUSD", "Short", "Loss", -1.3),
        ("2025-04-21", "BTCUSD", "Long", "BreakEven", 0.0),
        ("2025-04-20", "GBPJPY", "Short", "Win", 3.1)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trade History")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(trades.indices, id: \.self) { index in
                        let trade = trades[index]
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date: \(trade.0)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Pair: \(trade.1)")
                                Text("Type: \(trade.2)")
                                Text("Outcome: \(trade.3)")
                                Text("Gain: \(String(format: "%.2f", trade.4))%")
                                    .foregroundColor(trade.4 >= 0 ? .green : .red)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Button("Edit") {
                                    // Placeholder
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                Button("Delete") {
                                    // Placeholder
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top)
        .navigationBarTitle("Trade History", displayMode: .inline)
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView()
    }
}
