import SwiftUI
import Charts

struct PsychologicalTrainingView: View {
    @StateObject private var trainingManager = PsychologicalTrainingManager()
    @State private var selectedTimeFrame: TimeFrame = .week
    @Environment(\.colorScheme) private var colorScheme
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredScores: [PsychologicalTrainingScore] {
        let calendar = Calendar.current
        let now = Date()
        
        return trainingManager.scoreHistory.filter { score in
            switch selectedTimeFrame {
            case .week:
                return calendar.isDate(score.timestamp, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(score.timestamp, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(score.timestamp, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if let currentScore = trainingManager.currentScore {
                    OverallScoreCard(score: currentScore)
                }
                
                if let currentScore = trainingManager.currentScore {
                    MetricsGrid(score: currentScore)
                }
                
                if !filteredScores.isEmpty {
                    ScoreHistoryChart(scores: filteredScores)
                }
                
                if let currentScore = trainingManager.currentScore {
                    RecommendationsSection(score: currentScore)
                }
            }
            .padding()
        }
        .navigationTitle("Psychological Training")
        .preferredColorScheme(.dark)
    }
}

struct OverallScoreCard: View {
    let score: PsychologicalTrainingScore
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Text("Overall Training Score")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(score.overallScore / 100.0))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(scoreColor(score: score.overallScore))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: score.overallScore)
                
                VStack {
                    Text("\(Int(score.overallScore))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                    Text("out of 100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func scoreColor(score: Double) -> Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        case 70..<90: return .yellow
        default: return .green
        }
    }
}

struct MetricsGrid: View {
    let score: PsychologicalTrainingScore
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            DataCard(title: "Emotional Control", score: score.emotionalControl)
            DataCard(title: "Risk Management", score: score.riskManagement)
            DataCard(title: "Trading Discipline", score: score.tradingDiscipline)
            DataCard(title: "Learning Progress", score: score.learningProgress)
            DataCard(title: "Pattern Recognition", score: score.patternRecognition)
        }
    }
}

struct DataCard: View {
    let title: String
    let score: Double
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(score))")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            
            ProgressView(value: score, total: 100)
                .tint(scoreColor(score: score))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    private func scoreColor(score: Double) -> Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        case 70..<90: return .yellow
        default: return .green
        }
    }
}

struct ScoreHistoryChart: View {
    let scores: [PsychologicalTrainingScore]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Score History")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 5)
            
            Chart {
                ForEach(scores) { score in
                    LineMark(
                        x: .value("Date", score.timestamp),
                        y: .value("Score", score.overallScore)
                    )
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Date", score.timestamp),
                        y: .value("Score", score.overallScore)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct RecommendationsSection: View {
    let score: PsychologicalTrainingScore
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recommendations")
                .font(.headline)
                .foregroundColor(.primary)
            
            if score.emotionalControl < 70 {
                RecommendationCard(
                    title: "Emotional Control",
                    description: getEmotionalControlRecommendation(score: score.emotionalControl)
                )
            }
            
            if score.riskManagement < 70 {
                RecommendationCard(
                    title: "Risk Management",
                    description: getRiskManagementRecommendation(score: score.riskManagement)
                )
            }
            
            if score.tradingDiscipline < 70 {
                RecommendationCard(
                    title: "Trading Discipline",
                    description: getTradingDisciplineRecommendation(score: score.tradingDiscipline)
                )
            }
            
            if score.learningProgress < 70 {
                RecommendationCard(
                    title: "Learning Progress",
                    description: getLearningProgressRecommendation(score: score.learningProgress)
                )
            }
            
            if score.patternRecognition < 70 {
                RecommendationCard(
                    title: "Pattern Recognition",
                    description: getPatternRecognitionRecommendation(score: score.patternRecognition)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func getEmotionalControlRecommendation(score: Double) -> String {
        if score < 40 {
            return "Focus on developing emotional awareness. Practice mindfulness before trading sessions and maintain a detailed trading journal to track emotional responses. Consider taking short breaks between trades."
        } else {
            return "Continue maintaining emotional balance. Consider adding meditation to your pre-trading routine and review your journal entries weekly to identify emotional patterns."
        }
    }
    
    private func getRiskManagementRecommendation(score: Double) -> String {
        if score < 40 {
            return "Strictly adhere to your risk management rules. Never risk more than 1% per trade and ensure all trades have a minimum 1:1 risk-reward ratio. Review your position sizing strategy."
        } else {
            return "Maintain your current risk management practices. Consider fine-tuning your position sizing based on market volatility and your win rate."
        }
    }
    
    private func getTradingDisciplineRecommendation(score: Double) -> String {
        if score < 40 {
            return "Create and follow a strict trading checklist. Document every trade with detailed entry/exit criteria and review your trading plan daily. Focus on consistency over frequency."
        } else {
            return "Continue following your trading plan. Consider adding more detailed documentation to your trade journal and review your checklist regularly."
        }
    }
    
    private func getLearningProgressRecommendation(score: Double) -> String {
        if score < 40 {
            return "Focus on learning one trading concept at a time. Review your losing trades to identify patterns and mistakes. Consider joining a trading community for additional insights."
        } else {
            return "Continue expanding your knowledge. Consider learning advanced trading concepts and sharing your insights with other traders."
        }
    }
    
    private func getPatternRecognitionRecommendation(score: Double) -> String {
        if score < 40 {
            return "Start documenting common chart patterns you observe. Practice identifying patterns on historical charts before trading. Focus on 2-3 reliable patterns initially."
        } else {
            return "Continue documenting and analyzing patterns. Consider developing your own pattern recognition system and backtesting it on historical data."
        }
    }
}

struct RecommendationCard: View {
    let title: String
    let description: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct PsychologicalTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        PsychologicalTrainingView()
    }
}
