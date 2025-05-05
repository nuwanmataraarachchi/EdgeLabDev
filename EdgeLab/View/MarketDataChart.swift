//
//  MarketDataChart.swift
//  EdgeLab
//
//  Created by user270106 on 5/6/25.
//

import SwiftUI
import Charts

struct MarketDataChart: View {
    let stockData: [StockData]
    let symbol: String
    
    var body: some View {
        VStack {
            Text("\(symbol) Price Trend")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            Chart(stockData) { data in
                LineMark(
                    x: .value("Time", data.timestamp),
                    y: .value("Price", data.price)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis {
                AxisMarks(format: Date.FormatStyle().hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits))
            }
            .chartYAxis {
                AxisMarks(format: Decimal.FormatStyle().precision(.fractionLength(2)))
            }
            .frame(height: 150)
        }
        .padding(.horizontal)
    }
}

struct MarketDataChart_Previews: PreviewProvider {
    static var previews: some View {
        MarketDataChart(
            stockData: [
                StockData(symbol: "AAPL", price: 174.52, timestamp: Date()),
                StockData(symbol: "AAPL", price: 174.60, timestamp: Date().addingTimeInterval(60))
            ],
            symbol: "AAPL"
        )
    }
}
