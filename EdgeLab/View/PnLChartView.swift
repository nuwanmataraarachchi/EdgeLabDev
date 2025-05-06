// PnLChartView.swift
// EdgeLab
//
// Created by Nuwan Mataraarachchi on 2025-05-04.
// PnLChartView.swift
// PnLChartView.swift
// EdgeLab
//
// Created by Nuwan Mataraarachchi on 2025-05-04.

import SwiftUI
import Charts

struct PnLChartView: View {
    @ObservedObject var viewModel: PnLChartViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Accumulative P&L")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)

            // Chart displaying the accumulated data
            Chart {
                ForEach(viewModel.accumulatedData) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Accumulated Gain/Loss", item.gainLoss)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                    .symbol(Circle())
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text(shortMonthFormatter.string(from: dateValue))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(12)
    }

    private var shortMonthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
}

struct PnLChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = [
            PnLData(date: Date(), gainLoss: 0),
            PnLData(date: Date().addingTimeInterval(86400), gainLoss: 50),
            PnLData(date: Date().addingTimeInterval(86400 * 2), gainLoss: 30)
        ]
        let viewModel = PnLChartViewModel()
        viewModel.accumulatedData = sampleData

        return PnLChartView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
