import SwiftUI

struct Trade: Identifiable, Equatable {
    let id = UUID()
    var date: String
    var asset: String
    var direction: String
    var outcome: String
    var gain: Double
    var notes: String
}

struct TradeHistoryView: View {
    @State private var trades: [Trade] = [
        Trade(date: "2025-04-23", asset: "ETHUSDT", direction: "Long", outcome: "Win", gain: 2.4, notes: "Good entry after news."),
        Trade(date: "2025-04-22", asset: "EURUSD", direction: "Short", outcome: "Loss", gain: -1.3, notes: "Stop hunt."),
        Trade(date: "2025-04-21", asset: "BTCUSD", direction: "Long", outcome: "BreakEven", gain: 0.0, notes: "Missed TP."),
        Trade(date: "2025-04-20", asset: "GBPJPY", direction: "Short", outcome: "Win", gain: 3.1, notes: "Perfect liquidity sweep."),
        // Add more data as needed for pagination
    ]
    
    @State private var editingTrade: Trade?
    @State private var editedNotes: String = ""
    
    // Pagination state
    @State private var currentPage: Int = 1
    @State private var tradesPerPage: Int = 5

    // Pagination Computed Properties
    private var paginatedTrades: [Trade] {
        let startIndex = (currentPage - 1) * tradesPerPage
        let endIndex = min(startIndex + tradesPerPage, trades.count)
        return Array(trades[startIndex..<endIndex])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trade History")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(paginatedTrades) { trade in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date: \(trade.date)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Pair: \(trade.asset)")
                                Text("Type: \(trade.direction)")
                                Text("Outcome: \(trade.outcome)")
                                Text("Gain: \(String(format: "%.2f", trade.gain))%")
                                    .foregroundColor(trade.gain >= 0 ? .green : .red)
                                Text("Notes: \(trade.notes)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                // Smaller buttons
                                Button(action: {
                                    editingTrade = trade
                                    editedNotes = trade.notes
                                }) {
                                    Text("Edit")
                                        .font(.caption2) // Smaller font size
                                        .padding(6) // Smaller padding
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }

                                Button(action: {
                                    deleteTrade(trade)
                                }) {
                                    Text("Delete")
                                        .font(.caption2) // Smaller font size
                                        .padding(6) // Smaller padding
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // Pagination controls
                    HStack {
                        Button(action: loadPreviousPage) {
                            Text("Previous")
                                .padding(6) // Smaller padding
                                .background(currentPage > 1 ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.caption2) // Smaller font
                        }
                        
                        Spacer()
                        
                        Button(action: loadNextPage) {
                            Text("Next")
                                .padding(6) // Smaller padding
                                .background(currentPage * tradesPerPage < trades.count ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.caption2) // Smaller font
                        }
                    }
                    .padding()
                }
            }

            // Show History Calendar Button
            Button(action: {
                // Navigate to TradeHistoryCalendarView
            }) {
                Text("Show History Calendar")
                    .font(.title3) // Smaller font size
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(8) // Smaller padding
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
        .navigationBarTitle("Trade History", displayMode: .inline)
        .sheet(item: $editingTrade) { trade in
            EditNotesView(trade: trade, editedNotes: $editedNotes, saveAction: {
                updateTradeNotes(for: trade, with: editedNotes)
            })
        }
    }
    
    private func deleteTrade(_ trade: Trade) {
        if let index = trades.firstIndex(of: trade) {
            trades.remove(at: index)
        }
    }
    
    private func updateTradeNotes(for trade: Trade, with notes: String) {
        if let index = trades.firstIndex(of: trade) {
            trades[index].notes = notes
        }
        editingTrade = nil
    }
    
    private func loadPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
        }
    }
    
    private func loadNextPage() {
        if currentPage * tradesPerPage < trades.count {
            currentPage += 1
        }
    }
}

struct EditNotesView: View {
    let trade: Trade
    @Binding var editedNotes: String
    var saveAction: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $editedNotes)
                    .padding()
                    .frame(height: 200)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding()
                
                Button(action: {
                    saveAction()
                }) {
                    Text("Save Notes")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Edit Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView()
    }
}
