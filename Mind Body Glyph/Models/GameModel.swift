//
//  GameModel.swift
//  Mind Body Glyph
//

import Foundation

// MARK: - Puzzle Types
enum PuzzleType: String, Codable, CaseIterable {
    case glyph = "Glyph"
    case pattern = "Pattern"
    case sequence = "Sequence"
    case memory = "Memory"
}

// MARK: - Difficulty Levels
enum DifficultyLevel: Int, Codable {
    case easy = 1
    case medium = 2
    case hard = 3
    case expert = 4
    
    var name: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
    
    var columns: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 4
        case .expert: return 5
        }
    }
    
    var rows: Int {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        case .expert: return 4
        }
    }
    
    var totalCells: Int {
        return columns * rows
    }
}

// MARK: - Glyph Cell
struct GlyphCell: Identifiable, Equatable {
    let id = UUID()
    var symbol: String
    var isRevealed: Bool
    var isMatched: Bool
    var position: Int
    
    init(symbol: String, position: Int) {
        self.symbol = symbol
        self.isRevealed = false
        self.isMatched = false
        self.position = position
    }
}

// MARK: - Game State
enum GameState {
    case ready
    case playing
    case paused
    case completed
    case failed
}

// MARK: - Game Session
struct GameSession: Codable, Identifiable {
    let id: UUID
    var score: Int
    var level: Int
    var movesCount: Int
    var timeElapsed: TimeInterval
    var puzzleType: PuzzleType
    var difficulty: DifficultyLevel
    var completedAt: Date?
    
    init(puzzleType: PuzzleType, difficulty: DifficultyLevel) {
        self.id = UUID()
        self.score = 0
        self.level = 1
        self.movesCount = 0
        self.timeElapsed = 0
        self.puzzleType = puzzleType
        self.difficulty = difficulty
        self.completedAt = nil
    }
}

// MARK: - Daily Quest
struct DailyQuest: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetValue: Int
    var currentValue: Int
    var isCompleted: Bool
    var questDate: Date
    var rewardPoints: Int
    var questType: QuestType
    
    enum QuestType: String, Codable {
        case completePuzzles = "complete_puzzles"
        case achieveScore = "achieve_score"
        case playTime = "play_time"
        case perfectMoves = "perfect_moves"
        case healthSteps = "health_steps"
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    init(type: QuestType, date: Date = Date()) {
        self.id = UUID()
        self.questType = type
        self.questDate = date
        self.currentValue = 0
        self.isCompleted = false
        
        switch type {
        case .completePuzzles:
            self.title = "Puzzle Master"
            self.description = "Complete 5 puzzles"
            self.targetValue = 5
            self.rewardPoints = 100
        case .achieveScore:
            self.title = "Score Hunter"
            self.description = "Earn 1000 points"
            self.targetValue = 1000
            self.rewardPoints = 150
        case .playTime:
            self.title = "Mind Marathon"
            self.description = "Play for 30 minutes"
            self.targetValue = 30
            self.rewardPoints = 80
        case .perfectMoves:
            self.title = "Perfect Game"
            self.description = "Complete puzzle with minimum moves"
            self.targetValue = 1
            self.rewardPoints = 200
        case .healthSteps:
            self.title = "Healthy Path"
            self.description = "Walk 5000 steps"
            self.targetValue = 5000
            self.rewardPoints = 120
        }
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var points: Int
    
    init(title: String, description: String, icon: String, points: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = false
        self.unlockedDate = nil
        self.points = points
    }
}

