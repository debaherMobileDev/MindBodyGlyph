//
//  ContentView.swift
//  Mind Body Glyph
//
//  Created by Simon Bakhanets on 04.01.2026.
//

//
//  ContentView.swift
//  Mind Body Glyph
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dataService = DataService()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    dataService: dataService
                )
            }
        }
        .onAppear {
            setupApp()
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            GameView(dataService: dataService)
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            DailyQuestsView(dataService: dataService)
                .tabItem {
                    Label("Quests", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(1)
            
            SettingsView(
                viewModel: SettingsViewModel(dataService: dataService),
                hasCompletedOnboarding: $hasCompletedOnboarding
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .accentColor(Color(hex: "F3B700"))
    }
    
    private func setupApp() {
        // Update daily quests
        var statistics = dataService.loadUserStatistics()
        dataService.updateDailyQuests(statistics: &statistics)
    }
}

// MARK: - Daily Quests View

struct DailyQuestsView: View {
    @StateObject var dataService: DataService
    @State private var statistics: UserStatistics
    
    init(dataService: DataService) {
        _dataService = StateObject(wrappedValue: dataService)
        _statistics = State(initialValue: dataService.loadUserStatistics())
    }
    
    var body: some View {
        ZStack {
            Color(hex: "040F07")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Quests")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Complete tasks and earn rewards")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Quests
                    if statistics.dailyQuests.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "F3B700").opacity(0.5))
                            
                            Text("Start playing to\nreceive quests!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(statistics.dailyQuests) { quest in
                                QuestCard(quest: quest)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            statistics = dataService.loadUserStatistics()
        }
    }
}

#Preview {
    ContentView()
}
