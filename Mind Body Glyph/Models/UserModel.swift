//
//  UserModel.swift
//  Mind Body Glyph
//

import Foundation

// MARK: - User Profile
struct UserProfile: Codable {
    var username: String
    var totalScore: Int
    var totalGamesPlayed: Int
    var totalGamesWon: Int
    var highestLevel: Int
    var createdAt: Date
    var lastPlayedAt: Date?
    var preferredDifficulty: DifficultyLevel
    var healthKitEnabled: Bool
    var dailyGoalSteps: Int
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    
    init(username: String = "Player") {
        self.username = username
        self.totalScore = 0
        self.totalGamesPlayed = 0
        self.totalGamesWon = 0
        self.highestLevel = 1
        self.createdAt = Date()
        self.lastPlayedAt = nil
        self.preferredDifficulty = .easy
        self.healthKitEnabled = false
        self.dailyGoalSteps = 5000
        self.soundEnabled = true
        self.hapticsEnabled = true
    }
    
    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalGamesWon) / Double(totalGamesPlayed)
    }
}

// MARK: - Health Stats
struct HealthStats: Codable {
    var dailySteps: Int
    var weeklySteps: Int
    var monthlySteps: Int
    var lastUpdated: Date
    var healthBarLevel: Double // 0.0 to 1.0
    
    init() {
        self.dailySteps = 0
        self.weeklySteps = 0
        self.monthlySteps = 0
        self.lastUpdated = Date()
        self.healthBarLevel = 0.5
    }
    
    mutating func updateHealthBar(steps: Int, goal: Int) {
        guard goal > 0 else {
            healthBarLevel = 0.5
            return
        }
        healthBarLevel = min(Double(steps) / Double(goal), 1.0)
    }
}

// MARK: - User Statistics
struct UserStatistics: Codable {
    var gameSessions: [GameSession]
    var achievements: [Achievement]
    var dailyQuests: [DailyQuest]
    var healthStats: HealthStats
    
    init() {
        self.gameSessions = []
        self.achievements = UserStatistics.createDefaultAchievements()
        self.dailyQuests = []
        self.healthStats = HealthStats()
    }
    
    static func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Steps", description: "Complete your first game", icon: "star.fill", points: 10),
            Achievement(title: "Novice", description: "Win 10 games", icon: "flame.fill", points: 50),
            Achievement(title: "Professional", description: "Win 50 games", icon: "crown.fill", points: 200),
            Achievement(title: "Master", description: "Win 100 games", icon: "trophy.fill", points: 500),
            Achievement(title: "Health Guru", description: "Reach step goal for 7 days straight", icon: "heart.fill", points: 300),
            Achievement(title: "Point Collector", description: "Earn 10000 points", icon: "sparkles", points: 400),
        ]
    }
    
    mutating func checkAndUnlockAchievements(profile: UserProfile) {
        // First Steps
        if profile.totalGamesPlayed >= 1 && !achievements[0].isUnlocked {
            achievements[0].isUnlocked = true
            achievements[0].unlockedDate = Date()
        }
        
        // Novice
        if profile.totalGamesWon >= 10 && !achievements[1].isUnlocked {
            achievements[1].isUnlocked = true
            achievements[1].unlockedDate = Date()
        }
        
        // Professional
        if profile.totalGamesWon >= 50 && !achievements[2].isUnlocked {
            achievements[2].isUnlocked = true
            achievements[2].unlockedDate = Date()
        }
        
        // Master
        if profile.totalGamesWon >= 100 && !achievements[3].isUnlocked {
            achievements[3].isUnlocked = true
            achievements[3].unlockedDate = Date()
        }
        
        // Points Collector
        if profile.totalScore >= 10000 && !achievements[5].isUnlocked {
            achievements[5].isUnlocked = true
            achievements[5].unlockedDate = Date()
        }
    }
}

