//
//  DataService.swift
//  Mind Body Glyph
//

import Foundation

class DataService: ObservableObject {
    private let userProfileKey = "userProfile"
    private let userStatisticsKey = "userStatistics"
    
    // MARK: - User Profile Management
    
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return UserProfile()
    }
    
    // MARK: - User Statistics Management
    
    func saveUserStatistics(_ statistics: UserStatistics) {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: userStatisticsKey)
        }
    }
    
    func loadUserStatistics() -> UserStatistics {
        if let data = UserDefaults.standard.data(forKey: userStatisticsKey),
           let statistics = try? JSONDecoder().decode(UserStatistics.self, from: data) {
            return statistics
        }
        return UserStatistics()
    }
    
    // MARK: - Game Session Management
    
    func addGameSession(_ session: GameSession, to statistics: inout UserStatistics) {
        statistics.gameSessions.append(session)
        saveUserStatistics(statistics)
    }
    
    func getRecentSessions(from statistics: UserStatistics, limit: Int = 10) -> [GameSession] {
        return Array(statistics.gameSessions.suffix(limit))
    }
    
    // MARK: - Daily Quest Management
    
    func generateDailyQuests() -> [DailyQuest] {
        let today = Calendar.current.startOfDay(for: Date())
        return [
            DailyQuest(type: .completePuzzles, date: today),
            DailyQuest(type: .achieveScore, date: today),
            DailyQuest(type: .playTime, date: today)
        ]
    }
    
    func updateDailyQuests(statistics: inout UserStatistics) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Remove old quests
        statistics.dailyQuests.removeAll { quest in
            !Calendar.current.isDate(quest.questDate, inSameDayAs: today)
        }
        
        // Generate new quests if needed
        if statistics.dailyQuests.isEmpty {
            statistics.dailyQuests = generateDailyQuests()
        }
        
        saveUserStatistics(statistics)
    }
    
    func updateQuestProgress(statistics: inout UserStatistics, questType: DailyQuest.QuestType, value: Int) {
        if let index = statistics.dailyQuests.firstIndex(where: { $0.questType == questType }) {
            statistics.dailyQuests[index].currentValue += value
            
            if statistics.dailyQuests[index].currentValue >= statistics.dailyQuests[index].targetValue {
                statistics.dailyQuests[index].isCompleted = true
            }
        }
        saveUserStatistics(statistics)
    }
    
    // MARK: - Achievement Management
    
    func unlockAchievement(id: UUID, in statistics: inout UserStatistics) {
        if let index = statistics.achievements.firstIndex(where: { $0.id == id }) {
            statistics.achievements[index].isUnlocked = true
            statistics.achievements[index].unlockedDate = Date()
            saveUserStatistics(statistics)
        }
    }
    
    func getUnlockedAchievements(from statistics: UserStatistics) -> [Achievement] {
        return statistics.achievements.filter { $0.isUnlocked }
    }
    
    // MARK: - Data Reset
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        UserDefaults.standard.removeObject(forKey: userStatisticsKey)
        UserDefaults.standard.synchronize()
    }
    
}

