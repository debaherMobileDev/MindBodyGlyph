//
//  GameViewModel.swift
//  Mind Body Glyph
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var currentSession: GameSession
    @Published var cells: [GlyphCell] = []
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var moves: Int = 0
    @Published var selectedCells: [GlyphCell] = []
    @Published var showCompletionAlert = false
    @Published var timeElapsed: TimeInterval = 0
    
    private var timer: Timer?
    private let glyphSymbols = ["🌟", "🔥", "💎", "🌙", "⚡️", "🌊", "🍃", "☀️", "🌈", "✨", "🎯", "🎨", "🎭", "🎪", "🎬", "🎸", "🎺", "🎹"]
    
    var difficulty: DifficultyLevel {
        currentSession.difficulty
    }
    
    var columns: Int {
        difficulty.columns
    }
    
    var rows: Int {
        difficulty.rows
    }
    
    var optimalMoves: Int {
        difficulty.totalCells / 2
    }
    
    init(puzzleType: PuzzleType = .glyph, difficulty: DifficultyLevel = .easy) {
        self.currentSession = GameSession(puzzleType: puzzleType, difficulty: difficulty)
        self.level = 1
    }
    
    // MARK: - Game Control
    
    func startNewGame() {
        gameState = .playing
        score = currentSession.score
        level = currentSession.level
        moves = 0
        timeElapsed = 0
        selectedCells = []
        generatePuzzle()
        startTimer()
    }
    
    func pauseGame() {
        gameState = .paused
        stopTimer()
    }
    
    func resumeGame() {
        gameState = .playing
        startTimer()
    }
    
    func resetGame() {
        gameState = .ready
        stopTimer()
        currentSession = GameSession(puzzleType: currentSession.puzzleType, difficulty: currentSession.difficulty)
        score = 0
        level = 1
        moves = 0
        timeElapsed = 0
        cells = []
        selectedCells = []
    }
    
    // MARK: - Puzzle Generation
    
    private func generatePuzzle() {
        cells.removeAll()
        let totalCells = difficulty.totalCells
        let pairCount = totalCells / 2
        
        var symbols: [String] = []
        for i in 0..<pairCount {
            let symbol = glyphSymbols[i % glyphSymbols.count]
            symbols.append(symbol)
            symbols.append(symbol)
        }
        
        // Add one more if odd number
        if totalCells % 2 != 0 {
            symbols.append(glyphSymbols[pairCount % glyphSymbols.count])
        }
        
        symbols.shuffle()
        
        for (index, symbol) in symbols.enumerated() {
            cells.append(GlyphCell(symbol: symbol, position: index))
        }
    }
    
    // MARK: - Game Logic
    
    func cellTapped(_ cell: GlyphCell) {
        guard gameState == .playing else { return }
        guard !cell.isMatched else { return }
        guard selectedCells.count < 2 else { return }
        guard !selectedCells.contains(where: { $0.id == cell.id }) else { return }
        
        // Reveal cell
        if let index = cells.firstIndex(where: { $0.id == cell.id }) {
            cells[index].isRevealed = true
            selectedCells.append(cells[index])
            
            if selectedCells.count == 2 {
                moves += 1
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard selectedCells.count == 2 else { return }
        
        let first = selectedCells[0]
        let second = selectedCells[1]
        
        if first.symbol == second.symbol {
            // Match found
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                
                if let index1 = self.cells.firstIndex(where: { $0.id == first.id }) {
                    self.cells[index1].isMatched = true
                }
                if let index2 = self.cells.firstIndex(where: { $0.id == second.id }) {
                    self.cells[index2].isMatched = true
                }
                
                self.score += self.calculateScore()
                self.selectedCells.removeAll()
                
                self.checkForCompletion()
            }
        } else {
            // No match
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                
                if let index1 = self.cells.firstIndex(where: { $0.id == first.id }) {
                    self.cells[index1].isRevealed = false
                }
                if let index2 = self.cells.firstIndex(where: { $0.id == second.id }) {
                    self.cells[index2].isRevealed = false
                }
                
                self.selectedCells.removeAll()
            }
        }
    }
    
    private func calculateScore() -> Int {
        let baseScore = 10 * difficulty.rawValue
        let timeBonus = max(0, 100 - Int(timeElapsed))
        let moveBonus = moves <= optimalMoves ? 50 : 0
        return baseScore + timeBonus + moveBonus
    }
    
    private func checkForCompletion() {
        let allMatched = cells.allSatisfy { $0.isMatched }
        
        if allMatched {
            gameState = .completed
            currentSession.score = score
            currentSession.movesCount = moves
            currentSession.timeElapsed = timeElapsed
            currentSession.completedAt = Date()
            stopTimer()
            showCompletionAlert = true
        }
    }
    
    func nextLevel() {
        level += 1
        moves = 0
        timeElapsed = 0
        selectedCells = []
        
        // Increase difficulty every 3 levels
        if level % 3 == 0 && difficulty.rawValue < DifficultyLevel.expert.rawValue {
            currentSession.difficulty = DifficultyLevel(rawValue: difficulty.rawValue + 1) ?? difficulty
        }
        
        currentSession.level = level
        generatePuzzle()
        gameState = .playing
        startTimer()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopTimer()
    }
}

