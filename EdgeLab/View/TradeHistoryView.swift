import SwiftUI

struct TradeHistoryView: View {
    @StateObject private var viewModel = TradeListViewModel()
    @State private var editingTrade: Trade?
    @State private var editedNotes: String = ""

    @State private var currentPage: Int = 1
    @State private var tradesPerPage: Int = 5

    @State private var showCalendarView = false

    private var paginatedTrades: [Trade] {
        let startIndex = (currentPage - 1) * tradesPerPage
        let endIndex = min(startIndex + tradesPerPage, viewModel.trades.count)
        if startIndex < endIndex {
            return Array(viewModel.trades[startIndex..<endIndex])
        }
        return []
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Trade History")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(paginatedTrades) { trade in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Date: \(trade.date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Pair: \(trade.asset)")
                                        .foregroundColor(.primary)
                                    Text("Type: \(trade.direction)")
                                        .foregroundColor(.primary)
                                    Text("Outcome: \(trade.outcome)")
                                        .foregroundColor(.primary)
                                    Text("Gain: \(String(format: "%.2f", trade.gain))%")
                                        .foregroundColor(trade.gain >= 0 ? .green : .red)
                                    Text("Notes: \(trade.notes)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(spacing: 8) {
                                    Button(action: {
                                        editingTrade = trade
                                        editedNotes = trade.notes
                                    }) {
                                        Text("Edit")
                                            .font(.caption2)
                                            .padding(6)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }

                                    Button(action: {
                                        viewModel.deleteTrade(trade)
                                    }) {
                                        Text("Delete")
                                            .font(.caption2)
                                            .padding(6)
                                            .background(Color.red.opacity(0.2))
                                            .foregroundColor(.red)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }

                        HStack {
                            Button(action: loadPreviousPage) {
                                Text("Previous")
                                    .padding(6)
                                    .background(currentPage > 1 ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .font(.caption2)
                            }

                            Spacer()

                            Button(action: loadNextPage) {
                                Text("Next")
                                    .padding(6)
                                    .background(currentPage * tradesPerPage < viewModel.trades.count ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .font(.caption2)
                            }
                        }
                        .padding()
                    }
                }

                NavigationLink(destination: TradeHistoryCalendarView(), isActive: $showCalendarView) {
                    EmptyView()
                }

                Button(action: {
                    showCalendarView = true
                }) {
                    Text("Show History Calendar")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationBarTitle("Trade History", displayMode: .inline)
            .sheet(item: $editingTrade) { trade in
                EditNotesView(trade: trade, editedNotes: $editedNotes, saveAction: {
                    viewModel.updateNotes(for: trade, with: editedNotes)
                    editingTrade = nil
                })
            }
            .onAppear {
                viewModel.fetchTrades()
            }
        }
    }

    private func loadPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
        }
    }

    private func loadNextPage() {
        if currentPage * tradesPerPage < viewModel.trades.count {
            currentPage += 1
        }
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode Only")
    }
}
