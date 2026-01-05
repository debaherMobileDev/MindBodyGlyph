//
//  GameView.swift
//  Mind Body Glyph
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @StateObject var dataService: DataService
    @StateObject var healthKitService: HealthKitService
    @State private var showPauseMenu = false
    
    init(dataService: DataService, healthKitService: HealthKitService) {
        _dataService = StateObject(wrappedValue: dataService)
        _healthKitService = StateObject(wrappedValue: healthKitService)
        
        let profile = dataService.loadUserProfile()
        _viewModel = StateObject(wrappedValue: GameViewModel(
            puzzleType: .glyph,
            difficulty: profile.preferredDifficulty
        ))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "040F07")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Game Stats
                statsView
                
                // Game Grid
                if viewModel.gameState == .ready {
                    readyStateView
                } else {
                    gameGridView
                }
                
                Spacer()
            }
            .padding()
            
            // Pause Menu Overlay
            if showPauseMenu {
                pauseMenuOverlay
            }
        }
        .alert("Puzzle Solved! 🎉", isPresented: $viewModel.showCompletionAlert) {
            Button("Next Level") {
                viewModel.nextLevel()
                updateStatistics()
            }
            Button("Main Menu") {
                viewModel.resetGame()
            }
        } message: {
            Text("Level: \(viewModel.level)\nScore: \(viewModel.score)\nMoves: \(viewModel.moves)")
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Text("Mind Body Glyph")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "F3B700"))
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.pauseGame()
                    showPauseMenu = true
                }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "F3B700"))
                }
                .opacity(viewModel.gameState == .ready ? 0 : 1)
                
                Button(action: {
                    viewModel.resetGame()
                }) {
                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "F3B700"))
                }
                .opacity(viewModel.gameState == .ready ? 0 : 1)
            }
        }
    }
    
    // MARK: - Stats View
    
    private var statsView: some View {
        HStack(spacing: 15) {
            StatCard(title: "Level", value: "\(viewModel.level)", icon: "star.fill")
            StatCard(title: "Score", value: "\(viewModel.score)", icon: "flame.fill")
            StatCard(title: "Moves", value: "\(viewModel.moves)", icon: "arrow.left.arrow.right")
            StatCard(title: "Time", value: timeString(from: viewModel.timeElapsed), icon: "clock.fill")
        }
    }
    
    // MARK: - Ready State View
    
    private var readyStateView: some View {
        VStack(spacing: 30) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "F3B700"))
            
            Text("Ready for a new puzzle?")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.startNewGame()
            }) {
                Text("Start Game")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "040F07"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "F3B700"))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Game Grid View
    
    private var gameGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: viewModel.columns)
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.cells) { cell in
                CellView(cell: cell)
                    .onTapGesture {
                        viewModel.cellTapped(cell)
                    }
            }
        }
        .padding()
    }
    
    // MARK: - Pause Menu Overlay
    
    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "F3B700"))
                
                Text("Game Paused")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Button(action: {
                        showPauseMenu = false
                        viewModel.resumeGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                            Text("Resume Game")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "040F07"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "F3B700"))
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        showPauseMenu = false
                        viewModel.resetGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20))
                            Text("Restart Level")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        showPauseMenu = false
                        updateStatistics()
                        viewModel.resetGame()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 20))
                            Text("Exit to Main Menu")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func updateStatistics() {
        var profile = dataService.loadUserProfile()
        var statistics = dataService.loadUserStatistics()
        
        profile.totalGamesPlayed += 1
        if viewModel.gameState == .completed {
            profile.totalGamesWon += 1
        }
        profile.totalScore += viewModel.score
        profile.highestLevel = max(profile.highestLevel, viewModel.level)
        profile.lastPlayedAt = Date()
        
        dataService.addGameSession(viewModel.currentSession, to: &statistics)
        dataService.updateQuestProgress(statistics: &statistics, questType: .completePuzzles, value: 1)
        dataService.updateQuestProgress(statistics: &statistics, questType: .achieveScore, value: viewModel.score)
        
        statistics.checkAndUnlockAchievements(profile: profile)
        
        dataService.saveUserProfile(profile)
        dataService.saveUserStatistics(statistics)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "F3B700"))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Cell View

struct CellView: View {
    let cell: GlyphCell
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(cell.isMatched ? Color.green.opacity(0.3) : Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cell.isRevealed ? Color(hex: "F3B700") : Color.clear, lineWidth: 2)
                )
            
            if cell.isRevealed || cell.isMatched {
                Text(cell.symbol)
                    .font(.system(size: 32))
                    .transition(.scale)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.spring(), value: cell.isRevealed)
        .animation(.spring(), value: cell.isMatched)
    }
}

