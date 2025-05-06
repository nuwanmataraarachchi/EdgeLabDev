//
//  PsychologicInsight.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//
import Foundation

struct EmotionTag: Identifiable {
    let id: UUID
    let name: String
    let timestamp: Date
    
    init(id: UUID = UUID(), name: String, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}

class PsychologicInsight: Identifiable, ObservableObject {
    let id: UUID
    @Published var insight: String
    @Published var recommendation: String
    @Published private(set) var trades: [Trade]
    
    init(id: UUID = UUID(), insight: String, recommendation: String, trades: [Trade] = []) {
        self.id = id
        self.insight = insight
        self.recommendation = recommendation
        self.trades = trades
    }
}

struct PsychologicalTrainingScore: Identifiable {
    let id: UUID
    let emotionalControl: Double
    let riskManagement: Double
    let tradingDiscipline: Double
    let learningProgress: Double
    let patternRecognition: Double
    let timestamp: Date
    
    var overallScore: Double {
        return (emotionalControl + riskManagement + tradingDiscipline + learningProgress + patternRecognition) / 5.0
    }
    
    init(id: UUID = UUID(),
         emotionalControl: Double,
         riskManagement: Double,
         tradingDiscipline: Double,
         learningProgress: Double,
         patternRecognition: Double,
         timestamp: Date = Date()) {
        self.id = id
        self.emotionalControl = emotionalControl
        self.riskManagement = riskManagement
        self.tradingDiscipline = tradingDiscipline
        self.learningProgress = learningProgress
        self.patternRecognition = patternRecognition
        self.timestamp = timestamp
    }
}

class PsychologicalTrainingManager: ObservableObject {
    @Published var currentScore: PsychologicalTrainingScore?
    @Published var scoreHistory: [PsychologicalTrainingScore] = []
    
    func calculateEmotionalControl(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0.0 }
        
        var score = 0.0
        let totalTrades = Double(trades.count)
        
        let planAdherence = trades.filter { $0.entryCriteria.isEmpty == false }.count
        score += (Double(planAdherence) / totalTrades) * 40
        
        let lossTrades = trades.filter { $0.outcome.lowercased() == "loss" }
        let consecutiveLosses = calculateConsecutiveLosses(trades: trades)
        let lossScore = max(0, 30 - (Double(consecutiveLosses) * 5))
        score += lossScore
        
        let winTrades = trades.filter { $0.outcome.lowercased() == "win" }
        let winRate = Double(winTrades.count) / totalTrades
        let emotionalStability = abs(winRate - 0.5)
        score += (1 - emotionalStability) * 30
        
        return min(100, max(0, score))
    }
    
    func calculateRiskManagement(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0.0 }
        
        var score = 0.0
        let totalTrades = Double(trades.count)
        
        let validRiskTrades = trades.filter {
            guard let risk = Double($0.risk) else { return false }
            return risk > 0 && risk <= 2
        }.count
        score += (Double(validRiskTrades) / totalTrades) * 40
        
        let riskValues = trades.compactMap { Double($0.risk) }
        let averageRisk = riskValues.reduce(0, +) / Double(riskValues.count)
        let riskDeviation = riskValues.map { abs($0 - averageRisk) }.reduce(0, +) / Double(riskValues.count)
        let consistencyScore = max(0, 30 - (riskDeviation * 10))
        score += consistencyScore
        
        let validRRTrades = trades.filter {
            guard let rr = Double($0.rr) else { return false }
            return rr >= 1.0
        }.count
        score += (Double(validRRTrades) / totalTrades) * 30
        
        return min(100, max(0, score))
    }
    
    func calculateTradingDiscipline(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0.0 }
        
        var score = 0.0
        let totalTrades = Double(trades.count)
        
        let validEntryTrades = trades.filter { !$0.entryCriteria.isEmpty }.count
        score += (Double(validEntryTrades) / totalTrades) * 40
        
        let journaledTrades = trades.filter { !$0.notes.isEmpty }.count
        score += (Double(journaledTrades) / totalTrades) * 30
        
        let gradeScores = trades.compactMap { grade -> Double? in
            switch grade.grade {
            case "A+": return 30
            case "A": return 25
            case "B+": return 20
            case "B": return 15
            case "C+": return 10
            case "C": return 5
            case "C-": return 0
            default: return nil
            }
        }
        let averageGradeScore = gradeScores.reduce(0, +) / Double(gradeScores.count)
        score += averageGradeScore
        
        return min(100, max(0, score))
    }
    
    func calculateLearningProgress(trades: [Trade]) -> Double {
        guard trades.count >= 10 else { return 0.0 }
        
        var score = 0.0
        
        let recentTrades = Array(trades.suffix(10))
        let olderTrades = Array(trades.prefix(trades.count - 10))
        
        let recentWinRate = calculateWinRate(trades: recentTrades)
        let olderWinRate = calculateWinRate(trades: olderTrades)
        let winRateImprovement = max(0, recentWinRate - olderWinRate)
        score += winRateImprovement * 40
        
        let recentMistakes = calculateMistakes(trades: recentTrades)
        let olderMistakes = calculateMistakes(trades: olderTrades)
        let mistakeReduction = max(0, olderMistakes - recentMistakes)
        score += mistakeReduction * 30
        
        let conceptImplementation = calculateConceptImplementation(trades: trades)
        score += conceptImplementation * 30
        
        return min(100, max(0, score))
    }
    
    func calculatePatternRecognition(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0.0 }
        
        var score = 0.0
        let totalTrades = Double(trades.count)
        
        let patternTrades = trades.filter { $0.entryCriteria.contains("pattern") }
        let successfulPatternTrades = patternTrades.filter { $0.outcome.lowercased() == "win" }
        score += (Double(successfulPatternTrades.count) / Double(patternTrades.count)) * 40
        
        let patternSuccessRate = Double(successfulPatternTrades.count) / totalTrades
        score += patternSuccessRate * 30
        
        let documentedPatterns = trades.filter {
            $0.notes.contains("pattern") || $0.entryCriteria.contains("pattern")
        }.count
        score += (Double(documentedPatterns) / totalTrades) * 30
        
        return min(100, max(0, score))
    }
    
    private func calculateConsecutiveLosses(trades: [Trade]) -> Int {
        var maxConsecutive = 0
        var currentConsecutive = 0
        
        for trade in trades {
            if trade.outcome.lowercased() == "loss" {
                currentConsecutive += 1
                maxConsecutive = max(maxConsecutive, currentConsecutive)
            } else {
                currentConsecutive = 0
            }
        }
        
        return maxConsecutive
    }
    
    private func calculateWinRate(trades: [Trade]) -> Double {
        let winTrades = trades.filter { $0.outcome.lowercased() == "win" }
        return Double(winTrades.count) / Double(trades.count)
    }
    
    private func calculateMistakes(trades: [Trade]) -> Double {
        let mistakeIndicators = [
            "no stop loss",
            "overtrading",
            "revenge trading",
            "fomo",
            "impulsive"
        ]
        
        let mistakeCount = trades.filter { trade in
            mistakeIndicators.contains { indicator in
                trade.notes.lowercased().contains(indicator)
            }
        }.count
        
        return Double(mistakeCount) / Double(trades.count)
    }
    
    private func calculateConceptImplementation(trades: [Trade]) -> Double {
        let concepts = [
            "risk management",
            "technical analysis",
            "fundamental analysis",
            "market structure",
            "price action"
        ]
        
        let conceptCount = trades.filter { trade in
            concepts.contains { concept in
                trade.notes.lowercased().contains(concept) ||
                trade.entryCriteria.lowercased().contains(concept)
            }
        }.count
        
        return Double(conceptCount) / Double(trades.count)
    }
    
    func updateScores(trades: [Trade]) {
        let newScore = PsychologicalTrainingScore(
            emotionalControl: calculateEmotionalControl(trades: trades),
            riskManagement: calculateRiskManagement(trades: trades),
            tradingDiscipline: calculateTradingDiscipline(trades: trades),
            learningProgress: calculateLearningProgress(trades: trades),
            patternRecognition: calculatePatternRecognition(trades: trades)
        )
        
        currentScore = newScore
        scoreHistory.append(newScore)
    }
}
