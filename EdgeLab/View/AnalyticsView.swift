import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var viewModel = AnalyticsViewModel()

    // Dummy data for the line chart
    private let pnlData: [(date: Date, pnl: Double)] = [
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 23))!, pnl: -500),
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 25))!, pnl: 200),
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 27))!, pnl: 800),
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 1))!, pnl: 300),
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 5))!, pnl: 1200),
        (date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 9))!, pnl: 600)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                statRows
                pnlSection
                recentTrades
                Spacer()
            }
            .padding()
            .background(Color.black)
            .cornerRadius(12)
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchAnalyticsData()
        }
    }

    private var header: some View {
        Text("Analytics View")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top)
            .foregroundColor(.white)
    }

    private var statRows: some View {
        VStack(spacing: 12) {
            HStack {
                StatBlock(title: "Win Rate", value: String(format: "%.2f", viewModel.winRate), icon: "percent")
                StatBlock(title: "Total Trades", value: "\(viewModel.totalTrades)", icon: "number")
                StatBlock(title: "Avg Profit", value: String(format: "%.2f", viewModel.avgProfit), icon: "dollarsign.circle")
            }
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Overall Gain")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "arrow.triangle.turn.up.right.circle")
                            .foregroundColor(.white)
                    }
                    Text(formattedGain(viewModel.overallGain))
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.overallGain >= 0 ? .green : .red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)

                StatBlock(title: "Losses", value: "\(viewModel.losses)", icon: "chart.bar.xaxis")
                StatBlock(title: "Risk/Reward", value: String(format: "%.2f", viewModel.riskReward), icon: "info.circle")
            }
        }
    }

    private func formattedGain(_ gain: Double) -> String {
        if gain >= 0 {
            return String(format: "+%.0f%%", gain)
        } else {
            return String(format: "%.0f%%", gain)
        }
    }

    private var pnlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Accumulative P&L")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: SessionAnalyticsView()) {
                    HStack(spacing: 4) {
                        Text("Session Based Analysis")
                        Image(systemName: "arrow.right")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Chart {
                ForEach(pnlData, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("P&L", item.pnl)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 120)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.gray.opacity(0.5))
                    AxisTick(stroke: StrokeStyle(lineWidth: 2))
                        .foregroundStyle(.white)
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day(), anchor: .bottom)
                        .foregroundStyle(.white)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.gray.opacity(0.5))
                    AxisTick(stroke: StrokeStyle(lineWidth: 2))
                        .foregroundStyle(.white)
                    AxisValueLabel(anchor: .leading)
                        .foregroundStyle(.white)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.black.opacity(0.1))
                    .border(Color.gray.opacity(0.3), width: 1)
            }

            HStack {
                Text("Jan 23, 24")
                Spacer()
                Text("Feb 09, 24")
            }
            .foregroundColor(.gray)
            .font(.caption)
        }
    }

    private var recentTrades: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Last Five Trades")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Text("Asset")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 120, alignment: .leading)
                Spacer()
                Text("Outcome")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .leading)
            }
            .padding(.bottom, 2)

            ForEach(viewModel.lastTrades.prefix(5), id: \.self) { trade in
                HStack {
                    Text(trade.asset)
                        .foregroundColor(.gray)
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Text(trade.date)
                        .foregroundColor(.gray)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    Text(trade.type)
                        .fontWeight(.bold)
                        .foregroundColor(colorForType(trade.type))
                        .frame(width: 80, alignment: .leading)
                }
            }
        }
    }

    private func colorForType(_ type: String) -> Color {
        switch type {
        case "W":
            return .green
        case "L":
            return .red
        case "BE":
            return .blue
        default:
            return .gray
        }
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
        .frame(maxWidth: .infinity, minHeight: 100)
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

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AnalyticsView()
                .preferredColorScheme(.dark)
        }
    }
}
