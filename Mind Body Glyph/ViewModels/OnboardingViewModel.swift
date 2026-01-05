//
//  OnboardingViewModel.swift
//  Mind Body Glyph
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var username = ""
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to\nMind Body Glyph",
            description: "A unique puzzle game that develops your mind with challenging memory puzzles",
            imageName: "brain.head.profile",
            color: Color(hex: "F3B700")
        ),
        OnboardingPage(
            title: "Solve Puzzles",
            description: "Match pairs of glyphs in this memory-matching game. Adaptive difficulty adjusts to your level",
            imageName: "puzzlepiece.extension.fill",
            color: Color(hex: "F3B700")
        ),
        OnboardingPage(
            title: "Track Progress",
            description: "Complete daily quests, earn achievements, and compete with yourself to improve",
            imageName: "chart.line.uptrend.xyaxis",
            color: Color(hex: "F3B700")
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func completeOnboarding(dataService: DataService) {
        var profile = dataService.loadUserProfile()
        if !username.isEmpty {
            profile.username = username
        }
        dataService.saveUserProfile(profile)
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

