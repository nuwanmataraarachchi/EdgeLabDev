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
                        TextField("Enter Asset", text: $asset)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Date")
                            .font(.caption)
                        DatePicker("Select Date", selection: $date, displayedComponents: .date)
                            .onChange(of: date) { newDate in
                                day = getDayFromDate(date: newDate)
                            }

                        Text("Day")
                            .font(.caption)
                        Text(day.isEmpty ? "Select Date First" : day)
                            .foregroundColor(day.isEmpty ? .gray : .primary)
                    }

                    Group {
                        Toggle("Are you trading in a session?", isOn: $isSessionTrading)
                            .font(.caption)

                        if isSessionTrading {
                            Text("Session")
                                .font(.caption)
                            Picker("Select Session", selection: $session) {
                                ForEach(sessions, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            // If not trading in session, default session to "N/A"
                            Text("Session: N/A")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .onAppear {
                                    session = "N/A"
                                }
                        }

                        Text("Direction")
                            .font(.caption)
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
                        TextField("Enter Risk", text: $risk)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("RR (Risk/Reward)")
                            .font(.caption)
                        TextField("Enter RR", text: $rr)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Group {
                        Text("Grade")
                            .font(.caption)
                        Picker("Select Grade", selection: $grade) {
                            ForEach(grades, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        Text("Entry Criteria")
                            .font(.caption)
                        TextEditor(text: $entryCriteria)
                            .frame(height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5)))
                    }

                    Group {
                        Text("Outcome")
                            .font(.caption)
                        HStack(spacing: 8) {
                            Button(action: { outcome = "Win" }) {
                                Text("Win")
                                    .font(.caption2)
                                    .padding(6)
                                    .frame(maxWidth: .infinity)
                                    .background(outcome == "Win" ? Color.green : Color.gray.opacity(0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }

                            Button(action: { outcome = "Loss" }) {
                                Text("Loss")
                                    .font(.caption2)
                                    .padding(6)
                                    .frame(maxWidth: .infinity)
                                    .background(outcome == "Loss" ? Color.red : Color.gray.opacity(0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }

                            Button(action: { outcome = "BE" }) {
                                Text("Breakeven")
                                    .font(.caption2)
                                    .padding(6)
                                    .frame(maxWidth: .infinity)
                                    .background(outcome == "BE" ? Color.blue : Color.gray.opacity(0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }

                    Group {
                        Text("Chart View URL")
                            .font(.caption)
                        TextField("Enter Chart View URL", text: $chartViewURL)
                            .keyboardType(.URL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Notes")
                            .font(.caption)
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5)))
                    }

                    Button(action: {
                        // Save logic
                        print("Trade Saved")
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("New Trade Entry")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func getDayFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

struct TradeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeEntryView()
    }
}
