//
//  WeeklyPerformanceView.swift
//  EdgeLab
//
//  Created by user270106 on 5/5/25.
//

import SwiftUI

struct WeeklyPerformanceView: View {
    @StateObject private var report = WeeklyReport(weekStart: Date())
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Weekly Performance")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Stats Section
                    HStack(spacing: 15) {
                        StatCard(title: "Win Rate", value: "\(String(format: "%.1f", report.winRate))%", color: .green)
                        StatCard(title: "Net P&L", value: "\(String(format: "%.2f", report.profitLoss))", color: report.profitLoss >= 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                    
                    // Chart Section
                    VStack(alignment: .leading, spacing: 10) {
                        if let errorMessage = report.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else {
                            WeeklyPnLChart(dailyPnL: report.dailyPnL)
                                .frame(height: 350)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarItems(leading: Button(action: {
                // Back button action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// Weekly P&L Chart Component
struct WeeklyPnLChart: View {
    let dailyPnL: [String: Double]
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        GeometryReader { geometry in
            let maxPnL = dailyPnL.values.map { abs($0) }.max() ?? 1.0
            let chartHeight = geometry.size.height - 40 // Leave space for labels
            let zeroPosition = chartHeight / 2 // Middle of the chart for zero line
            let yAxisStep = maxPnL / 4 // For Y-axis labels (4 steps above/below zero)
            
            ZStack {
                // Y-Axis Labels and Grid Lines
                VStack {
                    ForEach(-4...4, id: \.self) { step in
                        if step != 0 { // Skip zero line (drawn separately)
                            HStack {
                                Text(String(format: "%.1f", Double(step) * yAxisStep))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 40, alignment: .trailing)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                            }
                            .offset(y: -CGFloat(step) * (chartHeight / 8))
                        }
                    }
                }
                
                // Zero Line (Dashed)
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1)
                            .overlay(
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 1)
                                    .padding(.horizontal, 1)
                            )
                    )
                    .offset(y: zeroPosition - chartHeight / 2)
                
                // Bars and Labels
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        VStack {
                            Spacer()
                            ZStack(alignment: .center) {
                                if let pnL = dailyPnL[day], pnL != 0 {
                                    // Bar
                                    Rectangle()
                                        .fill(pnL >= 0 ? Color.green : Color.red)
                                        .frame(width: 30, height: CGFloat(abs(pnL) / maxPnL) * (chartHeight / 2))
                                        .offset(y: pnL >= 0 ? -CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) : CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4))
                                    
                                    // P&L Label with Background
                                    Text(String(format: "%.1f", pnL))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(pnL >= 0 ? Color.green : Color.red)
                                        .cornerRadius(3)
                                        .offset(y: pnL >= 0 ? -CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) - 20 : CGFloat(abs(pnL) / maxPnL) * (chartHeight / 4) + 20)
                                }
                            }
                            Spacer()
                            // Day Label
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .offset(x: 40) // Offset to make space for Y-axis labels
            }
            .frame(height: chartHeight)
        }
    }
}

struct WeeklyPerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyPerformanceView()
    }
}
