//
//  SettingsViewModel.swift
//  Mind Body Glyph
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var statistics: UserStatistics
    @Published var showDeleteConfirmation = false
    
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        self.profile = dataService.loadUserProfile()
        self.statistics = dataService.loadUserStatistics()
    }
    
    func loadData() {
        profile = dataService.loadUserProfile()
        statistics = dataService.loadUserStatistics()
    }
    
    func saveProfile() {
        dataService.saveUserProfile(profile)
    }
    
    func updateUsername(_ newName: String) {
        profile.username = newName
        saveProfile()
    }
    
    func updatePreferredDifficulty(_ difficulty: DifficultyLevel) {
        profile.preferredDifficulty = difficulty
        saveProfile()
    }
    
    func toggleSound() {
        profile.soundEnabled.toggle()
        saveProfile()
    }
    
    func toggleHaptics() {
        profile.hapticsEnabled.toggle()
        saveProfile()
    }
    
    func deleteAccount() {
        dataService.resetAllData()
        profile = UserProfile()
        statistics = UserStatistics()
    }
    
    var totalPoints: Int {
        profile.totalScore + statistics.achievements.filter { $0.isUnlocked }.reduce(0) { $0 + $1.points }
    }
    
    var unlockedAchievementsCount: Int {
        statistics.achievements.filter { $0.isUnlocked }.count
    }
    
    var completedQuestsToday: Int {
        statistics.dailyQuests.filter { $0.isCompleted }.count
    }
}

