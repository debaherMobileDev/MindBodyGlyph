//
//  OnboardingView.swift
//  Mind Body Glyph
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    @StateObject var dataService: DataService
    @StateObject var healthKitService: HealthKitService
    
    var body: some View {
        ZStack {
            Color(hex: "040F07")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, viewModel: viewModel, isLastPage: index == viewModel.pages.count - 1)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(viewModel.currentPage == index ? Color(hex: "F3B700") : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: viewModel.currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                    Button(action: {
                        viewModel.previousPage()
                    }) {
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "F3B700"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "F3B700").opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    if viewModel.isLastPage {
                        completeOnboarding()
                    } else {
                        viewModel.nextPage()
                    }
                }) {
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "040F07"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "F3B700"))
                        .cornerRadius(12)
                }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        viewModel.completeOnboarding(dataService: dataService)
        
        if viewModel.enableHealthKit {
            healthKitService.requestAuthorization { success, _ in
                if success {
                    healthKitService.startObservingSteps()
                }
            }
        }
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @ObservedObject var viewModel: OnboardingViewModel
    let isLastPage: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .padding(.top, 60)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            // Additional content for last page
            if isLastPage {
                VStack(spacing: 20) {
                    // Username Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your name (optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("Player", text: $viewModel.username)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    // HealthKit Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable activity tracking")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("Connect HealthKit for motivation")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.enableHealthKit)
                            .labelsHidden()
                            .tint(Color(hex: "F3B700"))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }
            
            Spacer()
        }
    }
}

