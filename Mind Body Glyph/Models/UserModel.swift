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
        self.soundEnabled = true
        self.hapticsEnabled = true
    }
    
    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalGamesWon) / Double(totalGamesPlayed)
    }
}

// MARK: - User Statistics
struct UserStatistics: Codable {
    var gameSessions: [GameSession]
    var achievements: [Achievement]
    var dailyQuests: [DailyQuest]
    
    init() {
        self.gameSessions = []
        self.achievements = UserStatistics.createDefaultAchievements()
        self.dailyQuests = []
    }
    
    static func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Steps", description: "Complete your first game", icon: "star.fill", points: 10),
            Achievement(title: "Novice", description: "Win 10 games", icon: "flame.fill", points: 50),
            Achievement(title: "Professional", description: "Win 50 games", icon: "crown.fill", points: 200),
            Achievement(title: "Master", description: "Win 100 games", icon: "trophy.fill", points: 500),
            Achievement(title: "Speed Demon", description: "Complete a puzzle in under 30 seconds", icon: "bolt.fill", points: 300),
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

