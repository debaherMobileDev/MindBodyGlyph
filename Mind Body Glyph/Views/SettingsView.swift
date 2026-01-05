//
//  SettingsView.swift
//  Mind Body Glyph
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "040F07")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerView
                    
                    // Profile Section
                    profileSection
                    
                    // Statistics Section
                    statisticsSection
                    
                    // Daily Quests
                    dailyQuestsSection
                    
                    // Achievements
                    achievementsSection
                    
                    // Settings
                    settingsSection
                    
                    // Danger Zone
                    dangerZoneSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAccount()
                hasCompletedOnboarding = false
            }
        } message: {
            Text("All your data will be permanently deleted. You will return to the welcome screen.")
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "F3B700"))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.profile.username)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Level \(viewModel.profile.highestLevel)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "F3B700"))
                        Text("\(viewModel.totalPoints) points")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "F3B700"))
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                StatRow(icon: "gamecontroller.fill", title: "Games Played", value: "\(viewModel.profile.totalGamesPlayed)")
                StatRow(icon: "trophy.fill", title: "Games Won", value: "\(viewModel.profile.totalGamesWon)")
                StatRow(icon: "percent", title: "Win Rate", value: String(format: "%.1f%%", viewModel.profile.winRate * 100))
                StatRow(icon: "flame.fill", title: "Total Score", value: "\(viewModel.profile.totalScore)")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Daily Quests Section
    
    private var dailyQuestsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Daily Quests")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.completedQuestsToday)/\(viewModel.statistics.dailyQuests.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "F3B700"))
            }
            
            if viewModel.statistics.dailyQuests.isEmpty {
                Text("Start playing to receive quests!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.statistics.dailyQuests) { quest in
                        QuestCard(quest: quest)
                    }
                }
            }
        }
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.unlockedAchievementsCount)/\(viewModel.statistics.achievements.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "F3B700"))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.statistics.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Preferences")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound",
                    isOn: $viewModel.profile.soundEnabled
                )
                .onChange(of: viewModel.profile.soundEnabled) { _ in
                    viewModel.saveProfile()
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.leading, 50)
                
                SettingToggleRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Haptics",
                    isOn: $viewModel.profile.hapticsEnabled
                )
                .onChange(of: viewModel.profile.hapticsEnabled) { _ in
                    viewModel.saveProfile()
                }
                
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Danger Zone
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Danger Zone")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.red)
            
            Button(action: {
                viewModel.showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                    
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
                .foregroundColor(.red)
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(15)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "F3B700"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct QuestCard: View {
    let quest: DailyQuest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(quest.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(quest.description)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color(hex: "F3B700"))
                        .frame(width: geometry.size.width * quest.progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("\(quest.currentValue) / \(quest.targetValue)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("\(quest.rewardPoints)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(hex: "F3B700"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.icon)
                .font(.system(size: 32))
                .foregroundColor(achievement.isUnlocked ? Color(hex: "F3B700") : Color.white.opacity(0.3))
            
            Text(achievement.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                Text("\(achievement.points)")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(achievement.isUnlocked ? Color(hex: "F3B700") : Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(achievement.isUnlocked ? 0.15 : 0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? Color(hex: "F3B700").opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "F3B700"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "F3B700"))
        }
    }
}

