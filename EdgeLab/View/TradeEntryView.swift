//
//  TradeEntryView.swift
//  EdgeLab
//
//  Created by Nuwan Mataraarachchi on 2025-04-24.
//

import SwiftUI

struct TradeEntryView: View {
    @State private var asset: String = ""
    @State private var date: Date = Date()
    @State private var day: String = ""
    @State private var session: String = "N/A"
    @State private var isSessionTrading: Bool = false
    @State private var direction: String = "Long"
    @State private var risk: String = ""
    @State private var rr: String = ""
    @State private var entryCriteria: String = ""
    @State private var grade: String = "A"
    @State private var outcome: String = "Win"
    @State private var chartViewURL: String = ""
    @State private var notes: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    @ObservedObject private var viewModel = TradeEntryViewModel()

    let sessions = ["Asian", "London", "NewYork"]
    let directions = ["Long", "Short"]
    let grades = ["A+", "A", "B+", "B", "C+", "C", "C-"]
    let outcomes = ["Win", "Loss", "BE"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Asset")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextField("Enter Asset", text: $asset)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)

                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.primary)
                        DatePicker("Select Date", selection: $date, displayedComponents: .date)
                            .onChange(of: date) { newDate in
                                day = getDayFromDate(date: newDate)
                            }

                        Text("Day")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Text(day.isEmpty ? "Select Date First" : day)
                            .foregroundColor(day.isEmpty ? .gray : .primary)
                    }

                    Group {
                        Toggle("Are you trading in a session?", isOn: $isSessionTrading)
                            .font(.caption)

                        if isSessionTrading {
                            Text("Session")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Picker("Select Session", selection: $session) {
                                ForEach(sessions, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            Text("Session: N/A")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .onAppear {
                                    session = "N/A"
                                }
                        }

                        Text("Direction")
                            .font(.caption)
                            .foregroundColor(.primary)
                        HStack {
                            ForEach(directions, id: \.self) { option in
                                Button(action: {
                                    direction = option
                                }) {
                                    Text(option)
                                        .font(.caption)
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(direction == option ? (option == "Long" ? Color.green : Color.red) : Color.gray.opacity(0.4))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }

                    Group {
                        Text("Risk")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextField("Enter Risk", text: $risk)
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)

                        Text("RR (Risk/Reward)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextField("Enter RR", text: $rr)
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)
                    }

                    Group {
                        Text("Grade")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Picker("Select Grade", selection: $grade) {
                            ForEach(grades, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        Text("Entry Criteria")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextEditor(text: $entryCriteria)
                            .frame(height: 80)
                            .padding(4)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)
                    }

                    Group {
                        Text("Outcome")
                            .font(.caption)
                            .foregroundColor(.primary)
                        HStack(spacing: 8) {
                            ForEach(outcomes, id: \.self) { result in
                                Button(action: { outcome = result }) {
                                    Text(result == "BE" ? "Breakeven" : result)
                                        .font(.caption2)
                                        .padding(6)
                                        .frame(maxWidth: .infinity)
                                        .background(outcome == result ? colorForOutcome(result) : Color.gray.opacity(0.4))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                            }
                        }

                        Text("Chart View URL")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextField("Paste Chart URL", text: $chartViewURL)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)

                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.primary)
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .padding(4)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)
                    }

                    Button(action: saveTrade) {
                        Text("Save Trade")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("New Trade")
            .background(Color(UIColor.systemBackground)) // adapts to dark/light
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Save Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .preferredColorScheme(.dark) // Force dark mode
    }

    private func getDayFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func saveTrade() {
        let trade = TradeModel(
            asset: asset,
            date: date,
            day: day,
            session: session,
            isSessionTrading: isSessionTrading,
            direction: direction,
            risk: risk,
            rr: rr,
            entryCriteria: entryCriteria,
            grade: grade,
            outcome: outcome,
            chartViewURL: chartViewURL,
            notes: notes
        )

        viewModel.saveTrade(trade: trade) { result in
            switch result {
            case .success:
                alertMessage = "Trade saved successfully!"
                resetFields()
            case .failure(let error):
                alertMessage = "Failed to save trade: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }

    private func resetFields() {
        asset = ""
        date = Date()
        day = ""
        session = "N/A"
        isSessionTrading = false
        direction = "Long"
        risk = ""
        rr = ""
        entryCriteria = ""
        grade = "A"
        outcome = "Win"
        chartViewURL = ""
        notes = ""
    }

    private func colorForOutcome(_ outcome: String) -> Color {
        switch outcome {
        case "Win": return .green
        case "Loss": return .red
        case "BE": return .blue
        default: return .gray
        }
    }
}

struct TradeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeEntryView()
    }
}
