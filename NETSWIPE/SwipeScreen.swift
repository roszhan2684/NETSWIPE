////////
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  Hybrid version — loads MongoDB profiles + fake demo users (CSV or auto-generated), with caching
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////    
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////    
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    
//////    var body: some View {
//////        ZStack {
//////            // 🔮 Background Gradient
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////            
//////            VStack(spacing: 16) {
//////                // Header
//////                Text("NETSWIPE")
//////                    .font(.custom("Baskerville", size: 34))
//////                    .bold()
//////                    .foregroundColor(.white)
//////                    .padding(.top, 12)
//////                
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////                        Button("Retry") {
//////                            fetchProfiles()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////                    
//////                    Spacer()
//////                    
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear {
//////            profiles = loadProfilesFromCache()
//////            fetchProfiles()
//////        }
//////    }
//////    
//////    // MARK: - Card Section
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    fetchProfiles()
//////                    likedProfiles.removeAll()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////            } else {
//////                ForEach(profiles.indices, id: \.self) { index in
//////                    let profile = profiles[index]
//////                    let isTopCard = index == profiles.indices.last
//////                    
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            if isTopCard {
//////                                profiles.remove(at: index)
//////                                if profiles.isEmpty {
//////                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                        showCompletion = true
//////                                    }
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                        },
//////                        onMatch: { matched in
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        )
//////                    )
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(index))
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .left }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////            
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .right }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Fetch Profiles (Backend + CSV)
//////    private func fetchProfiles() {
//////        isLoading = true
//////        errorMessage = ""
//////        
//////        // Load fake users from CSV (or auto-generate if not found)
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////        
//////        // Backend API call
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////        
//////        NetworkManager.shared.getRequest(endpoint: endpoint) { (result: Result<ProfileResponse, Error>) in
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////                    profiles = backendProfiles + fakeUsers
//////                    saveProfilesToCache(profiles)
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake profiles (total \(profiles.count))")
//////                    isLoading = false
//////                    
//////                case .failure(let error):
//////                    // Offline fallback
//////                    profiles = loadProfilesFromCache()
//////                    if profiles.isEmpty {
//////                        profiles = fakeUsers
//////                        errorMessage = "Loaded demo users (backend unavailable)"
//////                    }
//////                    isLoading = false
//////                    print("⚠️ Using fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Local Cache Helpers
//////    private func saveProfilesToCache(_ profiles: [Profile]) {
//////        do {
//////            let data = try JSONEncoder().encode(profiles)
//////            UserDefaults.standard.set(data, forKey: "cachedProfiles")
//////        } catch {
//////            print("⚠️ Cache save error:", error.localizedDescription)
//////        }
//////    }
//////
//////    private func loadProfilesFromCache() -> [Profile] {
//////        guard let data = UserDefaults.standard.data(forKey: "cachedProfiles") else { return [] }
//////        do {
//////            let cached = try JSONDecoder().decode([Profile].self, from: data)
//////            print("💾 Loaded \(cached.count) profiles from cache")
//////            return cached
//////        } catch {
//////            print("⚠️ Cache load error:", error.localizedDescription)
//////            return []
//////        }
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
//////
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  Hybrid version — loads MongoDB profiles + fake demo users (CSV or auto-generated), with caching
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////    
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////    
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    
//////    // 👤 Profile sheet toggle
//////    @State private var showProfileSheet: Bool = false
//////    
//////    var body: some View {
//////        ZStack {
//////            // 🔮 Background Gradient
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////            
//////            VStack(spacing: 16) {
//////                // MARK: - Header with Profile Button
//////                ZStack {
//////                    Text("NETSWIPE")
//////                        .font(.custom("Baskerville", size: 34))
//////                        .bold()
//////                        .foregroundColor(.white)
//////                        .padding(.top, 12)
//////                    
//////                    HStack {
//////                        Spacer()
//////                        Button {
//////                            showProfileSheet = true
//////                        } label: {
//////                            Image(systemName: "person.crop.circle.fill")
//////                                .font(.system(size: 26, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(8)
//////                                .background(Color.white.opacity(0.18))
//////                                .clipShape(Circle())
//////                                .shadow(radius: 4)
//////                        }
//////                        .padding(.top, 8)
//////                    }
//////                    .padding(.horizontal)
//////                }
//////                
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////                        Button("Retry") {
//////                            fetchProfiles()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////                    
//////                    Spacer()
//////                    
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear {
//////            profiles = loadProfilesFromCache()
//////            fetchProfiles()
//////        }
//////        // 👤 Profile sheet
//////        .sheet(isPresented: $showProfileSheet) {
//////            if let current = authViewModel.profile {
//////                // Full profile screen with internal Edit Profile flow
//////                ProfileView(profile: current)
//////                    .environmentObject(authViewModel)
//////            } else {
//////                VStack(spacing: 12) {
//////                    Text("No profile loaded")
//////                        .font(.headline)
//////                    Text("Log in or complete your profile to see details here.")
//////                        .font(.subheadline)
//////                        .foregroundColor(.secondary)
//////                }
//////                .padding()
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Card Section
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    fetchProfiles()
//////                    likedProfiles.removeAll()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////            } else {
//////                ForEach(profiles.indices, id: \.self) { index in
//////                    let profile = profiles[index]
//////                    let isTopCard = index == profiles.indices.last
//////                    
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            if isTopCard {
//////                                profiles.remove(at: index)
//////                                if profiles.isEmpty {
//////                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                        showCompletion = true
//////                                    }
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                        },
//////                        onMatch: { matched in
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        )
//////                    )
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(index))
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .left }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////            
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .right }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Fetch Profiles (Backend + CSV)
//////    private func fetchProfiles() {
//////        isLoading = true
//////        errorMessage = ""
//////        
//////        // Load fake users from CSV (or auto-generate if not found)
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////        
//////        // Backend API call
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////        
//////        NetworkManager.shared.getRequest(endpoint: endpoint) { (result: Result<ProfileResponse, Error>) in
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////                    profiles = backendProfiles + fakeUsers
//////                    saveProfilesToCache(profiles)
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake profiles (total \(profiles.count))")
//////                    isLoading = false
//////                    
//////                case .failure(let error):
//////                    // Offline fallback
//////                    profiles = loadProfilesFromCache()
//////                    if profiles.isEmpty {
//////                        profiles = fakeUsers
//////                        errorMessage = "Loaded demo users (backend unavailable)"
//////                    }
//////                    isLoading = false
//////                    print("⚠️ Using fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Local Cache Helpers
//////    private func saveProfilesToCache(_ profiles: [Profile]) {
//////        do {
//////            let data = try JSONEncoder().encode(profiles)
//////            UserDefaults.standard.set(data, forKey: "cachedProfiles")
//////        } catch {
//////            print("⚠️ Cache save error:", error.localizedDescription)
//////        }
//////    }
//////
//////    private func loadProfilesFromCache() -> [Profile] {
//////        guard let data = UserDefaults.standard.data(forKey: "cachedProfiles") else { return [] }
//////        do {
//////            let cached = try JSONDecoder().decode([Profile].self, from: data)
//////            print("💾 Loaded \(cached.count) profiles from cache")
//////            return cached
//////        } catch {
//////            print("⚠️ Cache load error:", error.localizedDescription)
//////            return []
//////        }
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  Hybrid version — loads MongoDB profiles + fake demo users (CSV or auto-generated), with caching
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////    
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////    
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    @State private var hasLoadedProfiles: Bool = false      // ✅ NEW
//////    
//////    // 👤 Profile sheet toggle
//////    @State private var showProfileSheet: Bool = false
//////    
//////    var body: some View {
//////        ZStack {
//////            // 🔮 Background Gradient
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////            
//////            VStack(spacing: 16) {
//////                // MARK: - Header with Profile Button
//////                ZStack {
//////                    Text("NETSWIPE")
//////                        .font(.custom("Baskerville", size: 34))
//////                        .bold()
//////                        .foregroundColor(.white)
//////                        .padding(.top, 12)
//////                    
//////                    HStack {
//////                        Spacer()
//////                        Button {
//////                            showProfileSheet = true
//////                        } label: {
//////                            Image(systemName: "person.crop.circle.fill")
//////                                .font(.system(size: 26, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(8)
//////                                .background(Color.white.opacity(0.18))
//////                                .clipShape(Circle())
//////                                .shadow(radius: 4)
//////                        }
//////                        .padding(.top, 8)
//////                    }
//////                    .padding(.horizontal)
//////                }
//////                
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////                        Button("Retry") {
//////                            hasLoadedProfiles = false   // 🔁 allow reload
//////                            startLoading()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////                    
//////                    Spacer()
//////                    
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear {
//////            startLoading()
//////        }
//////        // 👤 Profile sheet
//////        .sheet(isPresented: $showProfileSheet) {
//////            if let current = authViewModel.profile {
//////                ProfileView(profile: current)
//////                    .environmentObject(authViewModel)
//////            } else {
//////                VStack(spacing: 12) {
//////                    Text("No profile loaded")
//////                        .font(.headline)
//////                    Text("Log in or complete your profile to see details here.")
//////                        .font(.subheadline)
//////                        .foregroundColor(.secondary)
//////                }
//////                .padding()
//////            }
//////        }
//////    }
//////    
//////    /// ✅ Run only once per app session (unless Retry tapped)
//////    private func startLoading() {
//////        guard !hasLoadedProfiles else { return }
//////        hasLoadedProfiles = true
//////        isLoading = true
//////        errorMessage = ""
//////        
//////        let cached = loadProfilesFromCache()
//////        if !cached.isEmpty {
//////            profiles = cached
//////            isLoading = false
//////        }
//////        
//////        // Also try backend in background
//////        fetchProfiles()
//////    }
//////    
//////    // MARK: - Card Section (one-behind-one with subtle depth)
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    hasLoadedProfiles = false
//////                    startLoading()
//////                    likedProfiles.removeAll()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////            } else {
//////                ForEach(profiles.indices, id: \.self) { index in
//////                    let profile = profiles[index]
//////                    let isTopCard = index == profiles.count - 1
//////                    let positionFromTop = (profiles.count - 1) - index
//////                    let maxDepth = 2
//////                    let depth = min(positionFromTop, maxDepth)
//////                    
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            if isTopCard {
//////                                profiles.remove(at: index)
//////                                saveProfilesToCache(profiles)
//////                                
//////                                if profiles.isEmpty {
//////                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                        showCompletion = true
//////                                    }
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                        },
//////                        onMatch: { matched in
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        )
//////                    )
//////                    .offset(y: CGFloat(depth * 12))        // subtle vertical stack
//////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(index))
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .left }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////            
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .right }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Fetch Profiles (Backend + CSV)
//////    private func fetchProfiles() {
//////        // Load fake users from CSV (or auto-generate if not found)
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////        
//////        // Backend API call
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////        
//////        NetworkManager.shared.getRequest(endpoint: endpoint) { (result: Result<ProfileResponse, Error>) in
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////                    
//////                    // ✅ 3) Backend profiles always on top of stack
//////                    profiles = fakeUsers + backendProfiles
//////                    saveProfilesToCache(profiles)
//////                    
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake profiles (total \(profiles.count))")
//////                    isLoading = false
//////                    
//////                case .failure(let error):
//////                    // Offline fallback
//////                    let cached = loadProfilesFromCache()
//////                    if !cached.isEmpty {
//////                        profiles = cached
//////                    } else {
//////                        profiles = fakeUsers
//////                        errorMessage = "Loaded demo users (backend unavailable)"
//////                    }
//////                    isLoading = false
//////                    print("⚠️ Using fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Local Cache Helpers
//////    private func saveProfilesToCache(_ profiles: [Profile]) {
//////        do {
//////            let data = try JSONEncoder().encode(profiles)
//////            UserDefaults.standard.set(data, forKey: "cachedProfiles")
//////        } catch {
//////            print("⚠️ Cache save error:", error.localizedDescription)
//////        }
//////    }
//////
//////    private func loadProfilesFromCache() -> [Profile] {
//////        guard let data = UserDefaults.standard.data(forKey: "cachedProfiles") else { return [] }
//////        do {
//////            let cached = try JSONDecoder().decode([Profile].self, from: data)
//////            print("💾 Loaded \(cached.count) profiles from cache")
//////            return cached
//////        } catch {
//////            print("⚠️ Cache load error:", error.localizedDescription)
//////            return []
//////        }
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
//////
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  Hybrid version — loads MongoDB profiles + fake demo users (CSV), NO heavy UserDefaults caching
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////    
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////    
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    @State private var hasLoadedProfiles: Bool = false      // ✅ prevents reloading on tab switch
//////    
//////    // 👤 Profile sheet toggle
//////    @State private var showProfileSheet: Bool = false
//////    
//////    var body: some View {
//////        ZStack {
//////            // 🔮 Background Gradient
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////            
//////            VStack(spacing: 16) {
//////                // MARK: - Header with Profile Button
//////                ZStack {
//////                    Text("NETSWIPE")
//////                        .font(.custom("Baskerville", size: 34))
//////                        .bold()
//////                        .foregroundColor(.white)
//////                        .padding(.top, 12)
//////                    
//////                    HStack {
//////                        Spacer()
//////                        Button {
//////                            showProfileSheet = true
//////                        } label: {
//////                            Image(systemName: "person.crop.circle.fill")
//////                                .font(.system(size: 26, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(8)
//////                                .background(Color.white.opacity(0.18))
//////                                .clipShape(Circle())
//////                                .shadow(radius: 4)
//////                        }
//////                        .padding(.top, 8)
//////                    }
//////                    .padding(.horizontal)
//////                }
//////                
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////                        Button("Retry") {
//////                            hasLoadedProfiles = false   // 🔁 allow reload
//////                            startLoading()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////                    
//////                    Spacer()
//////                    
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear {
//////            startLoading()
//////        }
//////        // 👤 Profile sheet
//////        .sheet(isPresented: $showProfileSheet) {
//////            if let current = authViewModel.profile {
//////                ProfileView(profile: current)
//////                    .environmentObject(authViewModel)
//////            } else {
//////                VStack(spacing: 12) {
//////                    Text("No profile loaded")
//////                        .font(.headline)
//////                    Text("Log in or complete your profile to see details here.")
//////                        .font(.subheadline)
//////                        .foregroundColor(.secondary)
//////                }
//////                .padding()
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Initial load (only once per session unless Retry tapped)
//////    private func startLoading() {
//////        guard !hasLoadedProfiles else { return }
//////        hasLoadedProfiles = true
//////        isLoading = true
//////        errorMessage = ""
//////        
//////        // Directly fetch from backend + CSV (no big UserDefaults cache)
//////        fetchProfiles()
//////    }
//////    
//////    // MARK: - Card Section (stacked one-behind-one)
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    // Reset so we can load a fresh deck again
//////                    hasLoadedProfiles = false
//////                    startLoading()
//////                    likedProfiles.removeAll()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////            } else {
//////                // Enumerate so we have a stable id and safe index
//////                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
//////                    let isTopCard = enumeratedIndex == profiles.count - 1
//////                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
//////                    let maxDepth = 2
//////                    let depth = min(positionFromTop, maxDepth)
//////                    
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            // Remove by id to avoid index-out-of-range
//////                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
//////                                swipeTrigger = .none
//////                                return
//////                            }
//////                            
//////                            if isTopCard {
//////                                profiles.remove(at: removeIndex)
//////                                
//////                                if profiles.isEmpty {
//////                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                        showCompletion = true
//////                                    }
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                        },
//////                        onMatch: { matched in
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        ),
//////                        canDrag: isTopCard        // ✅ only top card is draggable
//////                    )
//////                    .offset(y: CGFloat(depth * 12))          // subtle depth stack
//////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(enumeratedIndex))
//////                }
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .left }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////            
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .right }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////    
//////    // MARK: - Fetch Profiles (Backend + CSV)
//////    private func fetchProfiles() {
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////        
//////        // Backend API call
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////        
//////        NetworkManager.shared.getRequest(endpoint: endpoint) { (result: Result<ProfileResponse, Error>) in
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////                    
//////                    // ✅ Backend profiles always **on top** of the stack
//////                    // (last in array = top card)
//////                    profiles = fakeUsers + backendProfiles
//////                    
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake profiles (total \(profiles.count))")
//////                    isLoading = false
//////                    
//////                case .failure(let error):
//////                    // Fallback: just fake users
//////                    profiles = fakeUsers
//////                    errorMessage = "Loaded demo users (backend unavailable)"
//////                    isLoading = false
//////                    print("⚠️ Using fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  Hybrid version — loads MongoDB profiles + fake demo users (CSV)
////////  NO heavy UserDefaults caching
////////  ✅ Sends swipes to backend (like/dislike)
////////  ✅ Interest-based recommendation ordering
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    @State private var hasLoadedProfiles: Bool = false
//////
//////    // ✅ Track which cards were swiped RIGHT
//////    // so onRemove can infer left vs right safely
//////    @State private var likedIdBuffer: Set<String> = []
//////
//////    // 👤 Profile sheet toggle
//////    @State private var showProfileSheet: Bool = false
//////
//////    var body: some View {
//////        ZStack {
//////            // 🔮 Background Gradient
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////
//////            VStack(spacing: 16) {
//////
//////                // MARK: - Header with Profile Button
//////                ZStack {
//////                    Text("NETSWIPE")
//////                        .font(.custom("Baskerville", size: 34))
//////                        .bold()
//////                        .foregroundColor(.white)
//////                        .padding(.top, 12)
//////
//////                    HStack {
//////                        Spacer()
//////                        Button {
//////                            showProfileSheet = true
//////                        } label: {
//////                            Image(systemName: "person.crop.circle.fill")
//////                                .font(.system(size: 26, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(8)
//////                                .background(Color.white.opacity(0.18))
//////                                .clipShape(Circle())
//////                                .shadow(radius: 4)
//////                        }
//////                        .padding(.top, 8)
//////                    }
//////                    .padding(.horizontal)
//////                }
//////
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////
//////                        Button("Retry") {
//////                            hasLoadedProfiles = false
//////                            startLoading()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////
//////                    Spacer()
//////
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear { startLoading() }
//////
//////        // 👤 Profile sheet
//////        .sheet(isPresented: $showProfileSheet) {
//////            if let current = authViewModel.profile {
//////                ProfileView(profile: current)
//////                    .environmentObject(authViewModel)
//////            } else {
//////                VStack(spacing: 12) {
//////                    Text("No profile loaded")
//////                        .font(.headline)
//////                    Text("Log in or complete your profile to see details here.")
//////                        .font(.subheadline)
//////                        .foregroundColor(.secondary)
//////                }
//////                .padding()
//////            }
//////        }
//////    }
//////
//////    // MARK: - Initial load (only once per session unless Retry tapped)
//////    private func startLoading() {
//////        guard !hasLoadedProfiles else { return }
//////        hasLoadedProfiles = true
//////        isLoading = true
//////        errorMessage = ""
//////
//////        fetchProfiles()
//////    }
//////
//////    // MARK: - Recommendation: sort by interest similarity
//////    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
//////        guard let currentInterests = authViewModel.profile?.interests,
//////              !currentInterests.isEmpty else {
//////            return all
//////        }
//////
//////        let baseSet = Set(
//////            currentInterests.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
//////        )
//////
//////        func score(for profile: Profile) -> Int {
//////            let theirSet = Set(
//////                (profile.interests ?? [])
//////                    .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
//////            )
//////            return baseSet.intersection(theirSet).count
//////        }
//////
//////        // higher score should appear later → top card
//////        return all.sorted { a, b in
//////            score(for: a) < score(for: b)
//////        }
//////    }
//////
//////    // MARK: - Card Section (stacked one-behind-one)
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    hasLoadedProfiles = false
//////                    startLoading()
//////                    likedProfiles.removeAll()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////
//////            } else {
//////                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
//////                    let isTopCard = enumeratedIndex == profiles.count - 1
//////                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
//////                    let maxDepth = 2
//////                    let depth = min(positionFromTop, maxDepth)
//////
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            guard isTopCard else { return }
//////
//////                            // infer direction:
//////                            let wasLike = likedIdBuffer.contains(profile.id)
//////
//////                            // send dislike if NOT liked
//////                            if !wasLike {
//////                                authViewModel.sendSwipe(to: profile.id, like: false) { _ in }
//////                            } else {
//////                                likedIdBuffer.remove(profile.id)
//////                            }
//////
//////                            // remove card safely
//////                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
//////                                swipeTrigger = .none
//////                                return
//////                            }
//////
//////                            profiles.remove(at: removeIndex)
//////
//////                            if profiles.isEmpty {
//////                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                    showCompletion = true
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                        },
//////                        onMatch: { matched in
//////                            // 1) mark this as a RIGHT swipe before removal happens
//////                            likedIdBuffer.insert(matched.id)
//////
//////                            // 2) local liked list (for liked tab)
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////
//////                            // 3) tell backend it was a LIKE
//////                            authViewModel.sendSwipe(to: matched.id, like: true) { didMatch in
//////                                if didMatch {
//////                                    print("🎉 Mutual match with \(matched.displayName)")
//////                                    // optional: you can show match UI here later
//////                                }
//////                            }
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        ),
//////                        canDrag: isTopCard
//////                    )
//////                    .offset(y: CGFloat(depth * 12))
//////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(enumeratedIndex))
//////                }
//////            }
//////        }
//////    }
//////
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////
//////            // 👎 Dislike
//////            Button {
//////                if swipeTrigger == .none {
//////                    swipeTrigger = .left
//////                }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////
//////            // 👍 Like
//////            Button {
//////                if swipeTrigger == .none {
//////                    swipeTrigger = .right
//////                }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////
//////    // MARK: - Fetch Profiles (Backend + CSV)
//////    private func fetchProfiles() {
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////
//////        NetworkManager.shared.getRequest(endpoint: endpoint) { (result: Result<ProfileResponse, Error>) in
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////
//////                    // ✅ Backend should be on top (last = top card)
//////                    let combined = fakeUsers + backendProfiles
//////
//////                    // ✅ Apply recommendation sorting
//////                    profiles = sortProfilesForCurrentUser(combined)
//////
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake profiles (total \(profiles.count))")
//////                    isLoading = false
//////
//////                case .failure(let error):
//////                    profiles = sortProfilesForCurrentUser(fakeUsers)
//////                    errorMessage = "Loaded demo users (backend unavailable)"
//////                    isLoading = false
//////                    print("⚠️ Using fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
//////
////////  SwipeScreen.swift
////////  NetSwipe
////////
////////  ✅ Persists swiped + liked IDs (lightweight UserDefaults)
////////  ✅ Filters already-swiped profiles on load
////////  ✅ Reloads deck only when Restart Swiping is tapped
////////  ✅ Sends swipes to backend ONLY for real Mongo IDs
////////  ✅ Interest-based recommendation ordering
////////
//////
//////import SwiftUI
//////
//////struct SwipeScreen: View {
//////    @EnvironmentObject var authViewModel: AuthViewModel
//////
//////    @Binding var profiles: [Profile]
//////    @Binding var likedProfiles: [Profile]
//////    @Binding var swipeTrigger: SwipeDirection
//////    @Binding var matchedProfile: Profile?
//////    @Binding var showCompletion: Bool
//////
//////    // MARK: - Local State
//////    @State private var isLoading: Bool = true
//////    @State private var errorMessage: String = ""
//////    @State private var hasLoadedProfiles: Bool = false
//////
//////    // Track RIGHT swipes before removal
//////    @State private var likedIdBuffer: Set<String> = []
//////
//////    // 👤 Profile sheet toggle
//////    @State private var showProfileSheet: Bool = false
//////
//////    // ✅ lightweight persisted IDs
//////    @AppStorage("swipedProfileIds") private var swipedProfileIdsData: Data = Data()
//////    @AppStorage("likedProfileIds") private var likedProfileIdsData: Data = Data()
//////
//////    // ✅ restart trigger (incremented from LikedUsersView)
//////    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//////
//////    var body: some View {
//////        ZStack {
//////            RadialGradient(
//////                gradient: Gradient(colors: [
//////                    Color(red: 0.6, green: 0.3, blue: 0.8),
//////                    Color(red: 0.15, green: 0.0, blue: 0.25)
//////                ]),
//////                center: .center,
//////                startRadius: 100,
//////                endRadius: 600
//////            )
//////            .ignoresSafeArea()
//////
//////            VStack(spacing: 16) {
//////
//////                // Header
//////                ZStack {
//////                    Text("NETSWIPE")
//////                        .font(.custom("Baskerville", size: 34))
//////                        .bold()
//////                        .foregroundColor(.white)
//////                        .padding(.top, 12)
//////
//////                    HStack {
//////                        Spacer()
//////                        Button { showProfileSheet = true } label: {
//////                            Image(systemName: "person.crop.circle.fill")
//////                                .font(.system(size: 26, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(8)
//////                                .background(Color.white.opacity(0.18))
//////                                .clipShape(Circle())
//////                                .shadow(radius: 4)
//////                        }
//////                        .padding(.top, 8)
//////                    }
//////                    .padding(.horizontal)
//////                }
//////
//////                if isLoading {
//////                    Spacer()
//////                    ProgressView("Loading profiles...")
//////                        .foregroundColor(.white)
//////                    Spacer()
//////
//////                } else if !errorMessage.isEmpty {
//////                    Spacer()
//////                    VStack(spacing: 12) {
//////                        Image(systemName: "xmark.circle.fill")
//////                            .foregroundColor(.red)
//////                            .font(.system(size: 40))
//////                        Text("Failed to load profiles.")
//////                            .foregroundColor(.white)
//////                            .font(.headline)
//////                        Text(errorMessage)
//////                            .foregroundColor(.white.opacity(0.8))
//////                            .font(.subheadline)
//////                            .multilineTextAlignment(.center)
//////                            .padding(.horizontal)
//////
//////                        Button("Retry") {
//////                            hasLoadedProfiles = false
//////                            startLoading()
//////                        }
//////                        .padding(.top, 4)
//////                        .buttonStyle(.borderedProminent)
//////                        .tint(.purple)
//////                    }
//////                    Spacer()
//////
//////                } else {
//////                    cardSection
//////                        .frame(height: 500)
//////                        .padding(.top, 10)
//////
//////                    Spacer()
//////
//////                    if !profiles.isEmpty {
//////                        swipeButtonBar
//////                            .padding(.bottom, 40)
//////                    }
//////                }
//////            }
//////            .padding(.horizontal)
//////        }
//////        .onAppear { startLoading() }
//////
//////        // ✅ when Restart Swiping is tapped, reload a fresh deck
//////        .onChange(of: restartSwipingNonce) { _ in
//////            likedIdBuffer.removeAll()
//////            hasLoadedProfiles = false
//////            startLoading()
//////        }
//////
//////        .sheet(isPresented: $showProfileSheet) {
//////            if let current = authViewModel.profile {
//////                ProfileView(profile: current)
//////                    .environmentObject(authViewModel)
//////            } else {
//////                VStack(spacing: 12) {
//////                    Text("No profile loaded")
//////                        .font(.headline)
//////                    Text("Log in or complete your profile to see details here.")
//////                        .font(.subheadline)
//////                        .foregroundColor(.secondary)
//////                }
//////                .padding()
//////            }
//////        }
//////    }
//////
//////    // MARK: - Initial load
//////    private func startLoading() {
//////        guard !hasLoadedProfiles else { return }
//////        hasLoadedProfiles = true
//////        isLoading = true
//////        errorMessage = ""
//////
//////        fetchProfiles()
//////    }
//////
//////    // MARK: - Recommendation by interests
//////    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
//////        guard let currentInterests = authViewModel.profile?.interests,
//////              !currentInterests.isEmpty else {
//////            return all
//////        }
//////
//////        let baseSet = Set(currentInterests.map {
//////            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//////        })
//////
//////        func score(for profile: Profile) -> Int {
//////            let theirSet = Set((profile.interests ?? []).map {
//////                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//////            })
//////            return baseSet.intersection(theirSet).count
//////        }
//////
//////        return all.sorted { a, b in
//////            score(for: a) < score(for: b)
//////        }
//////    }
//////
//////    // MARK: - Card Section
//////    private var cardSection: some View {
//////        ZStack {
//////            if profiles.isEmpty {
//////                CompletionScreen {
//////                    // only restart if user explicitly wants to,
//////                    // so here we DO NOT clear persisted IDs.
//////                    hasLoadedProfiles = false
//////                    startLoading()
//////                    showCompletion = false
//////                }
//////                .transition(.opacity.combined(with: .scale))
//////
//////            } else {
//////                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
//////                    let isTopCard = enumeratedIndex == profiles.count - 1
//////                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
//////                    let depth = min(positionFromTop, 2)
//////
//////                    SwipeCard(
//////                        profile: profile,
//////                        onRemove: {
//////                            guard isTopCard else { return }
//////
//////                            let wasLike = likedIdBuffer.contains(profile.id)
//////
//////                            // ✅ persist swipe
//////                            persistSwipe(id: profile.id, like: wasLike)
//////
//////                            // ✅ send to backend only if real Mongo _id
//////                            if isMongoId(profile.id) {
//////                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
//////                            }
//////
//////                            // remove card
//////                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
//////                                swipeTrigger = .none
//////                                return
//////                            }
//////
//////                            profiles.remove(at: removeIndex)
//////
//////                            if profiles.isEmpty {
//////                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//////                                    showCompletion = true
//////                                }
//////                            }
//////                            swipeTrigger = .none
//////                            likedIdBuffer.remove(profile.id)
//////                        },
//////                        onMatch: { matched in
//////                            // RIGHT swipe buffer
//////                            likedIdBuffer.insert(matched.id)
//////
//////                            // local liked list for tab UI
//////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//////                                likedProfiles.append(matched)
//////                            }
//////                            matchedProfile = matched
//////                        },
//////                        swipeTrigger: Binding(
//////                            get: { isTopCard ? swipeTrigger : .none },
//////                            set: { newValue in
//////                                if isTopCard { swipeTrigger = newValue }
//////                            }
//////                        ),
//////                        canDrag: isTopCard
//////                    )
//////                    .offset(y: CGFloat(depth * 12))
//////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//////                    .zIndex(Double(enumeratedIndex))
//////                }
//////            }
//////        }
//////    }
//////
//////    // MARK: - Swipe Buttons
//////    private var swipeButtonBar: some View {
//////        HStack(spacing: 50) {
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .left }
//////            } label: {
//////                Image(systemName: "xmark.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.white)
//////                    .shadow(radius: 6)
//////            }
//////
//////            Button {
//////                if swipeTrigger == .none { swipeTrigger = .right }
//////            } label: {
//////                Image(systemName: "heart.circle.fill")
//////                    .font(.system(size: 50))
//////                    .foregroundColor(.red)
//////                    .shadow(radius: 6)
//////            }
//////        }
//////    }
//////
//////    // MARK: - Fetch Profiles
//////    private func fetchProfiles() {
//////        let fakeUsers = FakeUserLoader.loadCSV()
//////
//////        var endpoint = "/profile"
//////        if let currentId = authViewModel.profile?.id {
//////            endpoint += "?excludeUserId=\(currentId)"
//////        }
//////
//////        NetworkManager.shared.getRequest(endpoint: endpoint) {
//////            (result: Result<ProfileResponse, Error>) in
//////
//////            DispatchQueue.main.async {
//////                switch result {
//////                case .success(let response):
//////                    let backendProfiles = response.users ?? []
//////                    let combined = fakeUsers + backendProfiles
//////
//////                    // ✅ restore likedProfiles from persisted IDs
//////                    restoreLikedProfiles(from: combined)
//////
//////                    // ✅ filter already-swiped
//////                    let swiped = loadSwipedIds()
//////                    let notSwiped = combined.filter { !swiped.contains($0.id) }
//////
//////                    profiles = sortProfilesForCurrentUser(notSwiped)
//////                    isLoading = false
//////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(combined.count)), remaining \(profiles.count)")
//////
//////                case .failure(let error):
//////                    restoreLikedProfiles(from: fakeUsers)
//////                    let swiped = loadSwipedIds()
//////                    let notSwiped = fakeUsers.filter { !swiped.contains($0.id) }
//////                    profiles = sortProfilesForCurrentUser(notSwiped)
//////                    errorMessage = "Loaded demo users (backend unavailable)"
//////                    isLoading = false
//////                    print("⚠️ Fallback profiles:", error.localizedDescription)
//////                }
//////            }
//////        }
//////    }
//////
//////    // MARK: - Persistence helpers
//////    private func loadSwipedIds() -> Set<String> {
//////        guard !swipedProfileIdsData.isEmpty,
//////              let arr = try? JSONDecoder().decode([String].self, from: swipedProfileIdsData)
//////        else { return [] }
//////        return Set(arr)
//////    }
//////
//////    private func loadLikedIds() -> Set<String> {
//////        guard !likedProfileIdsData.isEmpty,
//////              let arr = try? JSONDecoder().decode([String].self, from: likedProfileIdsData)
//////        else { return [] }
//////        return Set(arr)
//////    }
//////
//////    private func saveSwipedIds(_ set: Set<String>) {
//////        if let data = try? JSONEncoder().encode(Array(set)) {
//////            swipedProfileIdsData = data
//////        }
//////    }
//////
//////    private func saveLikedIds(_ set: Set<String>) {
//////        if let data = try? JSONEncoder().encode(Array(set)) {
//////            likedProfileIdsData = data
//////        }
//////    }
//////
//////    private func persistSwipe(id: String, like: Bool) {
//////        var swiped = loadSwipedIds()
//////        swiped.insert(id)
//////        saveSwipedIds(swiped)
//////
//////        if like {
//////            var liked = loadLikedIds()
//////            liked.insert(id)
//////            saveLikedIds(liked)
//////        }
//////    }
//////
//////    private func restoreLikedProfiles(from all: [Profile]) {
//////        let likedIds = loadLikedIds()
//////        guard !likedIds.isEmpty else { return }
//////
//////        let restored = all.filter { likedIds.contains($0.id) }
//////        if likedProfiles.isEmpty {
//////            likedProfiles = restored
//////        } else {
//////            for p in restored where !likedProfiles.contains(where: { $0.id == p.id }) {
//////                likedProfiles.append(p)
//////            }
//////        }
//////    }
//////
//////    // ✅ avoid backend CastError for fake UUID ids
//////    private func isMongoId(_ id: String) -> Bool {
//////        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
//////    }
//////}
//////
//////// MARK: - Preview
//////#Preview {
//////    SwipeScreen(
//////        profiles: .constant(sampleProfiles),
//////        likedProfiles: .constant([]),
//////        swipeTrigger: .constant(.none),
//////        matchedProfile: .constant(nil),
//////        showCompletion: .constant(false)
//////    )
//////    .environmentObject(AuthViewModel())
//////}
//////  SwipeScreen.swift
//////  NetSwipe
//////
//////  ✅ Persists swiped + liked IDs PER USER (UserDefaults)
//////  ✅ Filters already-swiped profiles on load
//////  ✅ Reloads deck only when Restart Swiping is tapped
//////  ✅ Sends swipes to backend ONLY for real Mongo IDs
//////  ✅ Interest-based recommendation ordering
//////
////
////import SwiftUI
////
////struct SwipeScreen: View {
////    @EnvironmentObject var authViewModel: AuthViewModel
////
////    @Binding var profiles: [Profile]
////    @Binding var likedProfiles: [Profile]
////    @Binding var swipeTrigger: SwipeDirection
////    @Binding var matchedProfile: Profile?
////    @Binding var showCompletion: Bool
////
////    // MARK: - Local State
////    @State private var isLoading: Bool = true
////    @State private var errorMessage: String = ""
////    @State private var hasLoadedProfiles: Bool = false
////
////    // Track RIGHT swipes before removal
////    @State private var likedIdBuffer: Set<String> = []
////
////    // 👤 Profile sheet toggle
////    @State private var showProfileSheet: Bool = false
////
////    // ✅ restart trigger (incremented from LikedUsersView)
////    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
////
////    var body: some View {
////        ZStack {
////            RadialGradient(
////                gradient: Gradient(colors: [
////                    Color(red: 0.6, green: 0.3, blue: 0.8),
////                    Color(red: 0.15, green: 0.0, blue: 0.25)
////                ]),
////                center: .center,
////                startRadius: 100,
////                endRadius: 600
////            )
////            .ignoresSafeArea()
////
////            VStack(spacing: 16) {
////
////                // Header
////                ZStack {
////                    Text("NETSWIPE")
////                        .font(.custom("Baskerville", size: 34))
////                        .bold()
////                        .foregroundColor(.white)
////                        .padding(.top, 12)
////
////                    HStack {
////                        Spacer()
////                        Button { showProfileSheet = true } label: {
////                            Image(systemName: "person.crop.circle.fill")
////                                .font(.system(size: 26, weight: .semibold))
////                                .foregroundColor(.white)
////                                .padding(8)
////                                .background(Color.white.opacity(0.18))
////                                .clipShape(Circle())
////                                .shadow(radius: 4)
////                        }
////                        .padding(.top, 8)
////                    }
////                    .padding(.horizontal)
////                }
////
////                if isLoading {
////                    Spacer()
////                    ProgressView("Loading profiles...")
////                        .foregroundColor(.white)
////                    Spacer()
////
////                } else if !errorMessage.isEmpty {
////                    Spacer()
////                    VStack(spacing: 12) {
////                        Image(systemName: "xmark.circle.fill")
////                            .foregroundColor(.red)
////                            .font(.system(size: 40))
////                        Text("Failed to load profiles.")
////                            .foregroundColor(.white)
////                            .font(.headline)
////                        Text(errorMessage)
////                            .foregroundColor(.white.opacity(0.8))
////                            .font(.subheadline)
////                            .multilineTextAlignment(.center)
////                            .padding(.horizontal)
////
////                        Button("Retry") {
////                            hasLoadedProfiles = false
////                            startLoading()
////                        }
////                        .padding(.top, 4)
////                        .buttonStyle(.borderedProminent)
////                        .tint(.purple)
////                    }
////                    Spacer()
////
////                } else {
////                    cardSection
////                        .frame(height: 500)
////                        .padding(.top, 10)
////
////                    Spacer()
////
////                    if !profiles.isEmpty {
////                        swipeButtonBar
////                            .padding(.bottom, 40)
////                    }
////                }
////            }
////            .padding(.horizontal)
////        }
////        .onAppear { startLoading() }
////
////        // ✅ when Restart Swiping is tapped, reload a fresh deck
////        .onChange(of: restartSwipingNonce) { _ in
////            likedIdBuffer.removeAll()
////            hasLoadedProfiles = false
////            startLoading()
////        }
////
////        .sheet(isPresented: $showProfileSheet) {
////            if let current = authViewModel.profile {
////                ProfileView(profile: current)
////                    .environmentObject(authViewModel)
////            } else {
////                VStack(spacing: 12) {
////                    Text("No profile loaded")
////                        .font(.headline)
////                    Text("Log in or complete your profile to see details here.")
////                        .font(.subheadline)
////                        .foregroundColor(.secondary)
////                }
////                .padding()
////            }
////        }
////    }
////
////    // MARK: - Initial load
////    private func startLoading() {
////        guard !hasLoadedProfiles else { return }
////        hasLoadedProfiles = true
////        isLoading = true
////        errorMessage = ""
////
////        fetchProfiles()
////    }
////
////    // MARK: - Recommendation by interests
////    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
////        guard let currentInterests = authViewModel.profile?.interests,
////              !currentInterests.isEmpty else {
////            return all
////        }
////
////        let baseSet = Set(currentInterests.map {
////            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
////        })
////
////        func score(for profile: Profile) -> Int {
////            let theirSet = Set((profile.interests ?? []).map {
////                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
////            })
////            return baseSet.intersection(theirSet).count
////        }
////
////        return all.sorted { a, b in
////            score(for: a) < score(for: b)
////        }
////    }
////
////    // MARK: - Card Section
////    private var cardSection: some View {
////        ZStack {
////            if profiles.isEmpty {
////                CompletionScreen {
////                    // only restart if user explicitly wants to,
////                    // so here we DO NOT clear persisted IDs.
////                    hasLoadedProfiles = false
////                    startLoading()
////                    showCompletion = false
////                }
////                .transition(.opacity.combined(with: .scale))
////
////            } else {
////                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
////                    let isTopCard = enumeratedIndex == profiles.count - 1
////                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
////                    let depth = min(positionFromTop, 2)
////
////                    SwipeCard(
////                        profile: profile,
////                        onRemove: {
////                            guard isTopCard else { return }
////
////                            let wasLike = likedIdBuffer.contains(profile.id)
////
////                            // ✅ persist swipe PER USER
////                            persistSwipe(id: profile.id, like: wasLike)
////
////                            // ✅ send to backend only if real Mongo _id
////                            if isMongoId(profile.id) {
////                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
////                            }
////
////                            // remove card
////                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
////                                swipeTrigger = .none
////                                return
////                            }
////
////                            profiles.remove(at: removeIndex)
////
////                            if profiles.isEmpty {
////                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
////                                    showCompletion = true
////                                }
////                            }
////                            swipeTrigger = .none
////                            likedIdBuffer.remove(profile.id)
////                        },
////                        onMatch: { matched in
////                            // RIGHT swipe buffer
////                            likedIdBuffer.insert(matched.id)
////
////                            // local liked list for tab UI
////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
////                                likedProfiles.append(matched)
////                            }
////                            matchedProfile = matched
////                        },
////                        swipeTrigger: Binding(
////                            get: { isTopCard ? swipeTrigger : .none },
////                            set: { newValue in
////                                if isTopCard { swipeTrigger = newValue }
////                            }
////                        ),
////                        canDrag: isTopCard
////                    )
////                    .offset(y: CGFloat(depth * 12))
////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
////                    .zIndex(Double(enumeratedIndex))
////                }
////            }
////        }
////    }
////
////    // MARK: - Swipe Buttons
////    private var swipeButtonBar: some View {
////        HStack(spacing: 50) {
////            Button {
////                if swipeTrigger == .none { swipeTrigger = .left }
////            } label: {
////                Image(systemName: "xmark.circle.fill")
////                    .font(.system(size: 50))
////                    .foregroundColor(.white)
////                    .shadow(radius: 6)
////            }
////
////            Button {
////                if swipeTrigger == .none { swipeTrigger = .right }
////            } label: {
////                Image(systemName: "heart.circle.fill")
////                    .font(.system(size: 50))
////                    .foregroundColor(.red)
////                    .shadow(radius: 6)
////            }
////        }
////    }
////
////    // MARK: - Fetch Profiles
////    private func fetchProfiles() {
////        let fakeUsers = FakeUserLoader.loadCSV()
////
////        var endpoint = "/profile"
////        if let currentId = authViewModel.profile?.id {
////            endpoint += "?excludeUserId=\(currentId)"
////        }
////
////        NetworkManager.shared.getRequest(endpoint: endpoint) {
////            (result: Result<ProfileResponse, Error>) in
////
////            DispatchQueue.main.async {
////                switch result {
////                case .success(let response):
////                    let backendProfiles = response.users ?? []
////                    let combined = fakeUsers + backendProfiles
////
////                    // ✅ restore likedProfiles PER USER
////                    restoreLikedProfiles(from: combined)
////
////                    // ✅ filter already-swiped PER USER
////                    let swiped = loadSwipedIds()
////                    let notSwiped = combined.filter { !swiped.contains($0.id) }
////
////                    profiles = sortProfilesForCurrentUser(notSwiped)
////                    isLoading = false
////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(combined.count)), remaining \(profiles.count)")
////
////                case .failure(let error):
////                    restoreLikedProfiles(from: fakeUsers)
////
////                    let swiped = loadSwipedIds()
////                    let notSwiped = fakeUsers.filter { !swiped.contains($0.id) }
////
////                    profiles = sortProfilesForCurrentUser(notSwiped)
////                    errorMessage = "Loaded demo users (backend unavailable)"
////                    isLoading = false
////                    print("⚠️ Fallback profiles:", error.localizedDescription)
////                }
////            }
////        }
////    }
////
////    // MARK: - Per-user keys
////    private func swipedKey() -> String {
////        let uid = authViewModel.userId ?? "guest"
////        return "swipedProfileIds_\(uid)"
////    }
////
////    private func likedKey() -> String {
////        let uid = authViewModel.userId ?? "guest"
////        return "likedProfileIds_\(uid)"
////    }
////
////    // MARK: - Persistence helpers (PER USER)
////    private func loadSwipedIds() -> Set<String> {
////        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
////              !data.isEmpty,
////              let arr = try? JSONDecoder().decode([String].self, from: data)
////        else { return [] }
////        return Set(arr)
////    }
////
////    private func loadLikedIds() -> Set<String> {
////        guard let data = UserDefaults.standard.data(forKey: likedKey()),
////              !data.isEmpty,
////              let arr = try? JSONDecoder().decode([String].self, from: data)
////        else { return [] }
////        return Set(arr)
////    }
////
////    private func saveSwipedIds(_ set: Set<String>) {
////        if let data = try? JSONEncoder().encode(Array(set)) {
////            UserDefaults.standard.set(data, forKey: swipedKey())
////        }
////    }
////
////    private func saveLikedIds(_ set: Set<String>) {
////        if let data = try? JSONEncoder().encode(Array(set)) {
////            UserDefaults.standard.set(data, forKey: likedKey())
////        }
////    }
////
////    private func persistSwipe(id: String, like: Bool) {
////        var swiped = loadSwipedIds()
////        swiped.insert(id)
////        saveSwipedIds(swiped)
////
////        if like {
////            var liked = loadLikedIds()
////            liked.insert(id)
////            saveLikedIds(liked)
////        }
////    }
////
////    private func restoreLikedProfiles(from all: [Profile]) {
////        let likedIds = loadLikedIds()
////
////        // ✅ always rebuild likedProfiles for CURRENT user only
////        let restored = all.filter { likedIds.contains($0.id) }
////        likedProfiles = restored
////    }
////
////    // ✅ avoid backend CastError for fake UUID ids
////    private func isMongoId(_ id: String) -> Bool {
////        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    SwipeScreen(
////        profiles: .constant(sampleProfiles),
////        likedProfiles: .constant([]),
////        swipeTrigger: .constant(.none),
////        matchedProfile: .constant(nil),
////        showCompletion: .constant(false)
////    )
////    .environmentObject(AuthViewModel())
////}
//////  SwipeScreen.swift
//////  NetSwipe
//////
//////  ✅ Persists swiped + liked IDs PER USER (UserDefaults)
//////  ✅ Filters already-swiped profiles on load
//////  ✅ Reloads deck only when Restart Swiping is tapped
//////  ✅ Sends swipes to backend ONLY for real Mongo IDs
//////  ✅ Interest-based recommendation ordering
//////
////
////import SwiftUI
////
////struct SwipeScreen: View {
////    @EnvironmentObject var authViewModel: AuthViewModel
////
////    @Binding var profiles: [Profile]
////    @Binding var likedProfiles: [Profile]
////    @Binding var swipeTrigger: SwipeDirection
////    @Binding var matchedProfile: Profile?
////    @Binding var showCompletion: Bool
////
////    // MARK: - Local State
////    @State private var isLoading: Bool = true
////    @State private var errorMessage: String = ""
////    @State private var hasLoadedProfiles: Bool = false
////
////    // Track RIGHT swipes before removal
////    @State private var likedIdBuffer: Set<String> = []
////
////    // 👤 Profile sheet toggle
////    @State private var showProfileSheet: Bool = false
////
////    // ✅ restart trigger (incremented from LikedUsersView)
////    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
////
////    var body: some View {
////        ZStack {
////            RadialGradient(
////                gradient: Gradient(colors: [
////                    Color(red: 0.6, green: 0.3, blue: 0.8),
////                    Color(red: 0.15, green: 0.0, blue: 0.25)
////                ]),
////                center: .center,
////                startRadius: 100,
////                endRadius: 600
////            )
////            .ignoresSafeArea()
////
////            VStack(spacing: 16) {
////
////                // Header
////                ZStack {
////                    Text("NETSWIPE")
////                        .font(.custom("Baskerville", size: 34))
////                        .bold()
////                        .foregroundColor(.white)
////                        .padding(.top, 12)
////
////                    HStack {
////                        Spacer()
////                        Button { showProfileSheet = true } label: {
////                            Image(systemName: "person.crop.circle.fill")
////                                .font(.system(size: 26, weight: .semibold))
////                                .foregroundColor(.white)
////                                .padding(8)
////                                .background(Color.white.opacity(0.18))
////                                .clipShape(Circle())
////                                .shadow(radius: 4)
////                        }
////                        .padding(.top, 8)
////                    }
////                    .padding(.horizontal)
////                }
////
////                if isLoading {
////                    Spacer()
////                    ProgressView("Loading profiles...")
////                        .foregroundColor(.white)
////                    Spacer()
////
////                } else if !errorMessage.isEmpty {
////                    Spacer()
////                    VStack(spacing: 12) {
////                        Image(systemName: "xmark.circle.fill")
////                            .foregroundColor(.red)
////                            .font(.system(size: 40))
////                        Text("Failed to load profiles.")
////                            .foregroundColor(.white)
////                            .font(.headline)
////                        Text(errorMessage)
////                            .foregroundColor(.white.opacity(0.8))
////                            .font(.subheadline)
////                            .multilineTextAlignment(.center)
////                            .padding(.horizontal)
////
////                        Button("Retry") {
////                            hasLoadedProfiles = false
////                            startLoading()
////                        }
////                        .padding(.top, 4)
////                        .buttonStyle(.borderedProminent)
////                        .tint(.purple)
////                    }
////                    Spacer()
////
////                } else {
////                    cardSection
////                        .frame(height: 500)
////                        .padding(.top, 10)
////
////                    Spacer()
////
////                    if !profiles.isEmpty {
////                        swipeButtonBar
////                            .padding(.bottom, 40)
////                    }
////                }
////            }
////            .padding(.horizontal)
////        }
////        .onAppear { startLoading() }
////
////        // ✅ when Restart Swiping is tapped from Liked tab,
////        // clear local state + reload a fresh deck.
////        .onChange(of: restartSwipingNonce) { _ in
////            likedIdBuffer.removeAll()
////            hasLoadedProfiles = false
////
////            // fully clear current deck / liked list so we don't reuse
////            // any mutated in-memory profiles (helps avoid broken images)
////            profiles.removeAll()
////            likedProfiles.removeAll()
////
////            isLoading = true
////            errorMessage = ""
////            startLoading()
////        }
////
////        .sheet(isPresented: $showProfileSheet) {
////            if let current = authViewModel.profile {
////                ProfileView(profile: current)
////                    .environmentObject(authViewModel)
////            } else {
////                VStack(spacing: 12) {
////                    Text("No profile loaded")
////                        .font(.headline)
////                    Text("Log in or complete your profile to see details here.")
////                        .font(.subheadline)
////                        .foregroundColor(.secondary)
////                }
////                .padding()
////            }
////        }
////    }
////
////    // MARK: - Initial load
////    private func startLoading() {
////        guard !hasLoadedProfiles else { return }
////        hasLoadedProfiles = true
////        isLoading = true
////        errorMessage = ""
////
////        fetchProfiles()
////    }
////
////    // MARK: - Recommendation by interests
////    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
////        guard let currentInterests = authViewModel.profile?.interests,
////              !currentInterests.isEmpty else {
////            return all
////        }
////
////        let baseSet = Set(currentInterests.map {
////            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
////        })
////
////        func score(for profile: Profile) -> Int {
////            let theirSet = Set((profile.interests ?? []).map {
////                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
////            })
////            return baseSet.intersection(theirSet).count
////        }
////
////        // higher score (more shared interests) should come first
////        return all.sorted { a, b in
////            score(for: a) > score(for: b)
////        }
////    }
////
////    // MARK: - Card Section
////    private var cardSection: some View {
////        ZStack {
////            if profiles.isEmpty {
////                CompletionScreen {
////                    // "Try again" from completion does NOT clear persisted IDs;
////                    // user needs explicit Restart for a true reset.
////                    hasLoadedProfiles = false
////                    startLoading()
////                    showCompletion = false
////                }
////                .transition(.opacity.combined(with: .scale))
////
////            } else {
////                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
////                    let isTopCard = enumeratedIndex == profiles.count - 1
////                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
////                    let depth = min(positionFromTop, 2)
////
////                    SwipeCard(
////                        profile: profile,
////                        onRemove: {
////                            guard isTopCard else { return }
////
////                            let wasLike = likedIdBuffer.contains(profile.id)
////
////                            // ✅ persist swipe PER USER
////                            persistSwipe(id: profile.id, like: wasLike)
////
////                            // ✅ send to backend only if real Mongo _id
////                            if isMongoId(profile.id) {
////                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
////                            }
////
////                            // remove card
////                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
////                                swipeTrigger = .none
////                                return
////                            }
////
////                            profiles.remove(at: removeIndex)
////
////                            if profiles.isEmpty {
////                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
////                                    showCompletion = true
////                                }
////                            }
////                            swipeTrigger = .none
////                            likedIdBuffer.remove(profile.id)
////                        },
////                        onMatch: { matched in
////                            // RIGHT swipe buffer
////                            likedIdBuffer.insert(matched.id)
////
////                            // local liked list for tab UI
////                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
////                                likedProfiles.append(matched)
////                            }
////                            matchedProfile = matched
////                        },
////                        swipeTrigger: Binding(
////                            get: { isTopCard ? swipeTrigger : .none },
////                            set: { newValue in
////                                if isTopCard { swipeTrigger = newValue }
////                            }
////                        ),
////                        canDrag: isTopCard
////                    )
////                    .offset(y: CGFloat(depth * 12))
////                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
////                    .zIndex(Double(enumeratedIndex))
////                }
////            }
////        }
////    }
////
////    // MARK: - Swipe Buttons
////    private var swipeButtonBar: some View {
////        HStack(spacing: 50) {
////            Button {
////                if swipeTrigger == .none { swipeTrigger = .left }
////            } label: {
////                Image(systemName: "xmark.circle.fill")
////                    .font(.system(size: 50))
////                    .foregroundColor(.white)
////                    .shadow(radius: 6)
////            }
////
////            Button {
////                if swipeTrigger == .none { swipeTrigger = .right }
////            } label: {
////                Image(systemName: "heart.circle.fill")
////                    .font(.system(size: 50))
////                    .foregroundColor(.red)
////                    .shadow(radius: 6)
////            }
////        }
////    }
////
////    // MARK: - Fetch Profiles
////    private func fetchProfiles() {
////        let fakeUsers = FakeUserLoader.loadCSV()
////
////        var endpoint = "/profile"
////        if let currentId = authViewModel.profile?.id, !currentId.isEmpty {
////            endpoint += "?excludeUserId=\(currentId)"
////        }
////
////        NetworkManager.shared.getRequest(endpoint: endpoint) {
////            (result: Result<ProfileResponse, Error>) in
////
////            DispatchQueue.main.async {
////                switch result {
////                case .success(let response):
////                    let backendProfiles = response.users ?? []
////                    let combined = fakeUsers + backendProfiles
////
////                    // ✅ restore likedProfiles PER USER
////                    restoreLikedProfiles(from: combined)
////
////                    // ✅ filter already-swiped PER USER
////                    let swiped = loadSwipedIds()
////                    let notSwiped = combined.filter { !swiped.contains($0.id) }
////
////                    profiles = sortProfilesForCurrentUser(notSwiped)
////                    isLoading = false
////                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(combined.count)), remaining \(profiles.count)")
////
////                case .failure(let error):
////                    // fallback purely to fake users
////                    restoreLikedProfiles(from: fakeUsers)
////
////                    let swiped = loadSwipedIds()
////                    let notSwiped = fakeUsers.filter { !swiped.contains($0.id) }
////
////                    profiles = sortProfilesForCurrentUser(notSwiped)
////                    errorMessage = "Loaded demo users (backend unavailable)"
////                    isLoading = false
////                    print("⚠️ Fallback profiles:", error.localizedDescription)
////                }
////            }
////        }
////    }
////
////    // MARK: - Per-user keys
////    private func swipedKey() -> String {
////        let uid = authViewModel.userId ?? "guest"
////        return "swipedProfileIds_\(uid)"
////    }
////
////    private func likedKey() -> String {
////        let uid = authViewModel.userId ?? "guest"
////        return "likedProfileIds_\(uid)"
////    }
////
////    // MARK: - Persistence helpers (PER USER)
////    private func loadSwipedIds() -> Set<String> {
////        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
////              !data.isEmpty,
////              let arr = try? JSONDecoder().decode([String].self, from: data)
////        else { return [] }
////        return Set(arr)
////    }
////
////    private func loadLikedIds() -> Set<String> {
////        guard let data = UserDefaults.standard.data(forKey: likedKey()),
////              !data.isEmpty,
////              let arr = try? JSONDecoder().decode([String].self, from: data)
////        else { return [] }
////        return Set(arr)
////    }
////
////    private func saveSwipedIds(_ set: Set<String>) {
////        if let data = try? JSONEncoder().encode(Array(set)) {
////            UserDefaults.standard.set(data, forKey: swipedKey())
////        }
////    }
////
////    private func saveLikedIds(_ set: Set<String>) {
////        if let data = try? JSONEncoder().encode(Array(set)) {
////            UserDefaults.standard.set(data, forKey: likedKey())
////        }
////    }
////
////    private func persistSwipe(id: String, like: Bool) {
////        var swiped = loadSwipedIds()
////        swiped.insert(id)
////        saveSwipedIds(swiped)
////
////        if like {
////            var liked = loadLikedIds()
////            liked.insert(id)
////            saveLikedIds(liked)
////        }
////    }
////
////    private func restoreLikedProfiles(from all: [Profile]) {
////        let likedIds = loadLikedIds()
////
////        // ✅ always rebuild likedProfiles for CURRENT user only
////        let restored = all.filter { likedIds.contains($0.id) }
////        likedProfiles = restored
////    }
////
////    // ✅ avoid backend CastError for fake UUID ids
////    private func isMongoId(_ id: String) -> Bool {
////        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    SwipeScreen(
////        profiles: .constant(sampleProfiles),
////        likedProfiles: .constant([]),
////        swipeTrigger: .constant(.none),
////        matchedProfile: .constant(nil),
////        showCompletion: .constant(false)
////    )
////    .environmentObject(AuthViewModel())
////}
////  SwipeScreen.swift
////  NetSwipe
////
////  ✅ Persists swiped + liked IDs PER USER (UserDefaults)
////  ✅ Filters already-swiped profiles on load
////  ✅ Reloads deck only when Restart Swiping is tapped
////  ✅ Sends swipes to backend ONLY for real Mongo IDs
////  ✅ Interest-based recommendation ordering
////  ✅ Backend profiles are always on top of the deck (ahead of fake/demo)
////
//
//import SwiftUI
//
//struct SwipeScreen: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var profiles: [Profile]
//    @Binding var likedProfiles: [Profile]
//    @Binding var swipeTrigger: SwipeDirection
//    @Binding var matchedProfile: Profile?
//    @Binding var showCompletion: Bool
//
//    // MARK: - Local State
//    @State private var isLoading: Bool = true
//    @State private var errorMessage: String = ""
//    @State private var hasLoadedProfiles: Bool = false
//
//    // Track RIGHT swipes before removal
//    @State private var likedIdBuffer: Set<String> = []
//
//    // 👤 Profile sheet toggle
//    @State private var showProfileSheet: Bool = false
//
//    // ✅ restart trigger (incremented from LikedUsersView)
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    var body: some View {
//        ZStack {
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.6, green: 0.3, blue: 0.8),
//                    Color(red: 0.15, green: 0.0, blue: 0.25)
//                ]),
//                center: .center,
//                startRadius: 100,
//                endRadius: 600
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 16) {
//
//                // Header
//                ZStack {
//                    Text("NETSWIPE")
//                        .font(.custom("Baskerville", size: 34))
//                        .bold()
//                        .foregroundColor(.white)
//                        .padding(.top, 12)
//
//                    HStack {
//                        Spacer()
//                        Button { showProfileSheet = true } label: {
//                            Image(systemName: "person.crop.circle.fill")
//                                .font(.system(size: 26, weight: .semibold))
//                                .foregroundColor(.white)
//                                .padding(8)
//                                .background(Color.white.opacity(0.18))
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                        .padding(.top, 8)
//                    }
//                    .padding(.horizontal)
//                }
//
//                if isLoading {
//                    Spacer()
//                    ProgressView("Loading profiles...")
//                        .foregroundColor(.white)
//                    Spacer()
//
//                } else if !errorMessage.isEmpty {
//                    Spacer()
//                    VStack(spacing: 12) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.red)
//                            .font(.system(size: 40))
//                        Text("Failed to load profiles.")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                        Text(errorMessage)
//                            .foregroundColor(.white.opacity(0.8))
//                            .font(.subheadline)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//
//                        Button("Retry") {
//                            hasLoadedProfiles = false
//                            startLoading()
//                        }
//                        .padding(.top, 4)
//                        .buttonStyle(.borderedProminent)
//                        .tint(.purple)
//                    }
//                    Spacer()
//
//                } else {
//                    cardSection
//                        .frame(height: 500)
//                        .padding(.top, 10)
//
//                    Spacer()
//
//                    if !profiles.isEmpty {
//                        swipeButtonBar
//                            .padding(.bottom, 40)
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//        // 🔁 Force the entire swipe stack (including SwipeCard state + images)
//        // to rebuild whenever restartSwipingNonce changes.
//        .id(restartSwipingNonce)
//        .onAppear { startLoading() }
//
//        // ✅ when Restart Swiping is tapped from Liked tab,
//        // clear local state + reload a fresh deck.
//        .onChange(of: restartSwipingNonce) { _ in
//            likedIdBuffer.removeAll()
//            hasLoadedProfiles = false
//
//            // fully clear current deck / liked list so we don't reuse
//            // any mutated in-memory profiles (helps avoid broken images)
//            profiles.removeAll()
//            likedProfiles.removeAll()
//
//            isLoading = true
//            errorMessage = ""
//            startLoading()
//        }
//
//        .sheet(isPresented: $showProfileSheet) {
//            if let current = authViewModel.profile {
//                ProfileView(profile: current)
//                    .environmentObject(authViewModel)
//            } else {
//                VStack(spacing: 12) {
//                    Text("No profile loaded")
//                        .font(.headline)
//                    Text("Log in or complete your profile to see details here.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//            }
//        }
//    }
//
//    // MARK: - Initial load
//    private func startLoading() {
//        guard !hasLoadedProfiles else { return }
//        hasLoadedProfiles = true
//        isLoading = true
//        errorMessage = ""
//
//        fetchProfiles()
//    }
//
//    // MARK: - Recommendation by interests
//    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
//        guard let currentInterests = authViewModel.profile?.interests,
//              !currentInterests.isEmpty else {
//            return all
//        }
//
//        let baseSet = Set(currentInterests.map {
//            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        })
//
//        func score(for profile: Profile) -> Int {
//            let theirSet = Set((profile.interests ?? []).map {
//                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//            })
//            return baseSet.intersection(theirSet).count
//        }
//
//        // higher score (more shared interests) should come first
//        return all.sorted { a, b in
//            score(for: a) > score(for: b)
//        }
//    }
//
//    // MARK: - Card Section
//    private var cardSection: some View {
//        ZStack {
//            if profiles.isEmpty {
//                CompletionScreen {
//                    // "Try again" from completion does NOT clear persisted IDs;
//                    // user needs explicit Restart for a true reset.
//                    hasLoadedProfiles = false
//                    startLoading()
//                    showCompletion = false
//                }
//                .transition(.opacity.combined(with: .scale))
//
//            } else {
//                // Use index-based identity so SwipeCard's internal @State
//                // doesn't get reused across restarts for the same profile id.
//                ForEach(Array(profiles.enumerated()), id: \.offset) { index, profile in
//                    let isTopCard = index == profiles.count - 1
//                    let positionFromTop = (profiles.count - 1) - index
//                    let depth = min(positionFromTop, 2)
//
//                    SwipeCard(
//                        profile: profile,
//                        onRemove: {
//                            guard isTopCard else { return }
//
//                            let wasLike = likedIdBuffer.contains(profile.id)
//
//                            // ✅ persist swipe PER USER
//                            persistSwipe(id: profile.id, like: wasLike)
//
//                            // ✅ send to backend only if real Mongo _id
//                            if isMongoId(profile.id) {
//                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
//                            }
//
//                            // remove card
//                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
//                                swipeTrigger = .none
//                                return
//                            }
//
//                            profiles.remove(at: removeIndex)
//
//                            if profiles.isEmpty {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                    showCompletion = true
//                                }
//                            }
//                            swipeTrigger = .none
//                            likedIdBuffer.remove(profile.id)
//                        },
//                        onMatch: { matched in
//                            // RIGHT swipe buffer
//                            likedIdBuffer.insert(matched.id)
//
//                            // local liked list for tab UI
//                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//                                likedProfiles.append(matched)
//                            }
//                            matchedProfile = matched
//                        },
//                        swipeTrigger: Binding(
//                            get: { isTopCard ? swipeTrigger : .none },
//                            set: { newValue in
//                                if isTopCard { swipeTrigger = newValue }
//                            }
//                        ),
//                        canDrag: isTopCard
//                    )
//                    .offset(y: CGFloat(depth * 12))
//                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .zIndex(Double(index))
//                }
//            }
//        }
//    }
//
//    // MARK: - Swipe Buttons
//    private var swipeButtonBar: some View {
//        HStack(spacing: 50) {
//            Button {
//                if swipeTrigger == .none { swipeTrigger = .left }
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.white)
//                    .shadow(radius: 6)
//            }
//
//            Button {
//                if swipeTrigger == .none { swipeTrigger = .right }
//            } label: {
//                Image(systemName: "heart.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.red)
//                    .shadow(radius: 6)
//            }
//        }
//    }
//
//    // MARK: - Fetch Profiles
//    private func fetchProfiles() {
//        // Demo / fake profiles (with localImageName etc.)
//        let fakeUsers = FakeUserLoader.loadCSV()
//
//        var endpoint = "/profile"
//        if let currentId = authViewModel.profile?.id, !currentId.isEmpty {
//            endpoint += "?excludeUserId=\(currentId)"
//        }
//
//        NetworkManager.shared.getRequest(endpoint: endpoint) {
//            (result: Result<ProfileResponse, Error>) in
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    let backendProfiles = response.users ?? []
//
//                    // For restoring likes we need full universe
//                    let allCombined = fakeUsers + backendProfiles
//                    restoreLikedProfiles(from: allCombined)
//
//                    // ✅ filter already-swiped PER USER
//                    let swiped = loadSwipedIds()
//
//                    let backendNotSwiped = backendProfiles.filter { !swiped.contains($0.id) }
//                    let fakeNotSwiped    = fakeUsers.filter { !swiped.contains($0.id) }
//
//                    // ✅ sort each group separately by interest score
//                    let backendSorted = sortProfilesForCurrentUser(backendNotSwiped)
//                    let fakeSorted    = sortProfilesForCurrentUser(fakeNotSwiped)
//
//                    // ✅ Backend ALWAYS comes first in the deck; fake/demo after
//                    profiles = backendSorted + fakeSorted
//                    isLoading = false
//
//                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(allCombined.count)), remaining \(profiles.count)")
//
//                case .failure(let error):
//                    // fallback purely to fake users
//                    restoreLikedProfiles(from: fakeUsers)
//
//                    let swiped = loadSwipedIds()
//                    let fakeNotSwiped = fakeUsers.filter { !swiped.contains($0.id) }
//
//                    profiles = sortProfilesForCurrentUser(fakeNotSwiped)
//                    errorMessage = "Loaded demo users (backend unavailable)"
//                    isLoading = false
//
//                    print("⚠️ Fallback profiles:", error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    // MARK: - Per-user keys
//    private func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    private func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Persistence helpers (PER USER)
//    private func loadSwipedIds() -> Set<String> {
//        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
//              !data.isEmpty,
//              let arr = try? JSONDecoder().decode([String].self, from: data)
//        else { return [] }
//        return Set(arr)
//    }
//
//    private func loadLikedIds() -> Set<String> {
//        guard let data = UserDefaults.standard.data(forKey: likedKey()),
//              !data.isEmpty,
//              let arr = try? JSONDecoder().decode([String].self, from: data)
//        else { return [] }
//        return Set(arr)
//    }
//
//    private func saveSwipedIds(_ set: Set<String>) {
//        if let data = try? JSONEncoder().encode(Array(set)) {
//            UserDefaults.standard.set(data, forKey: swipedKey())
//        }
//    }
//
//    private func saveLikedIds(_ set: Set<String>) {
//        if let data = try? JSONEncoder().encode(Array(set)) {
//            UserDefaults.standard.set(data, forKey: likedKey())
//        }
//    }
//
//    private func persistSwipe(id: String, like: Bool) {
//        var swiped = loadSwipedIds()
//        swiped.insert(id)
//        saveSwipedIds(swiped)
//
//        if like {
//            var liked = loadLikedIds()
//            liked.insert(id)
//            saveLikedIds(liked)
//        }
//    }
//
//    private func restoreLikedProfiles(from all: [Profile]) {
//        let likedIds = loadLikedIds()
//
//        // ✅ always rebuild likedProfiles for CURRENT user only
//        let restored = all.filter { likedIds.contains($0.id) }
//        likedProfiles = restored
//    }
//
//    // ✅ avoid backend CastError for fake UUID ids
//    private func isMongoId(_ id: String) -> Bool {
//        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    SwipeScreen(
//        profiles: .constant(sampleProfiles),
//        likedProfiles: .constant([]),
//        swipeTrigger: .constant(.none),
//        matchedProfile: .constant(nil),
//        showCompletion: .constant(false)
//    )
//    .environmentObject(AuthViewModel())
//}
////  SwipeScreen.swift
////  NetSwipe
////
////  ✅ Persists swiped + liked IDs PER USER (UserDefaults)
////  ✅ Filters already-swiped profiles on load
////  ✅ Restart Swiping (in this screen) clears swipes + likes + matches + chats
////  ✅ Sends swipes to backend ONLY for real Mongo IDs
////  ✅ Interest-based recommendation ordering
////  ✅ REAL (backend) profiles are always on TOP of the deck (above fake/demo)
////  ✅ Fake/demo profiles always re-hydrate their images after Restart Swiping
////  ✅ Liked profiles are ordered: real (Mongo) first, then fake/demo
////
//
//import SwiftUI
//import UIKit
//
//struct SwipeScreen: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var profiles: [Profile]
//    @Binding var likedProfiles: [Profile]
//    @Binding var swipeTrigger: SwipeDirection
//    @Binding var matchedProfile: Profile?
//    @Binding var showCompletion: Bool
//
//    // MARK: - Local State
//    @State private var isLoading: Bool = true
//    @State private var errorMessage: String = ""
//    @State private var hasLoadedProfiles: Bool = false
//
//    // Track RIGHT swipes before removal
//    @State private var likedIdBuffer: Set<String> = []
//
//    // Profile sheet toggle
//    @State private var showProfileSheet: Bool = false
//
//    // Restart trigger shared with other views (like LikedUsersView)
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    // Alert for restart confirmation
//    @State private var showRestartAlert: Bool = false
//
//    var body: some View {
//        ZStack {
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.6, green: 0.3, blue: 0.8),
//                    Color(red: 0.15, green: 0.0, blue: 0.25)
//                ]),
//                center: .center,
//                startRadius: 100,
//                endRadius: 600
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 16) {
//
//                // MARK: - Header (Title + Restart + Profile)
//                ZStack {
//                    Text("NETSWIPE")
//                        .font(.custom("Baskerville", size: 34))
//                        .bold()
//                        .foregroundColor(.white)
//                        .padding(.top, 12)
//
//                    HStack {
//                        // Restart button (top-left)
//                        Button {
//                            showRestartAlert = true
//                        } label: {
//                            Image(systemName: "arrow.counterclockwise")
//                                .font(.system(size: 20, weight: .semibold))
//                                .foregroundColor(.white)
//                                .padding(8)
//                                .background(Color.white.opacity(0.18))
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                        .padding(.top, 8)
//
//                        Spacer()
//
//                        // Profile button (top-right)
//                        Button {
//                            showProfileSheet = true
//                        } label: {
//                            Image(systemName: "person.crop.circle.fill")
//                                .font(.system(size: 26, weight: .semibold))
//                                .foregroundColor(.white)
//                                .padding(8)
//                                .background(Color.white.opacity(0.18))
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                        .padding(.top, 8)
//                    }
//                    .padding(.horizontal)
//                }
//
//                // MARK: - Main content
//                if isLoading {
//                    Spacer()
//                    ProgressView("Loading profiles...")
//                        .foregroundColor(.white)
//                    Spacer()
//
//                } else if !errorMessage.isEmpty {
//                    Spacer()
//                    VStack(spacing: 12) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.red)
//                            .font(.system(size: 40))
//                        Text("Failed to load profiles.")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                        Text(errorMessage)
//                            .foregroundColor(.white.opacity(0.8))
//                            .font(.subheadline)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//
//                        Button("Retry") {
//                            hasLoadedProfiles = false
//                            startLoading()
//                        }
//                        .padding(.top, 4)
//                        .buttonStyle(.borderedProminent)
//                        .tint(.purple)
//                    }
//                    Spacer()
//
//                } else {
//                    cardSection
//                        .frame(height: 500)
//                        .padding(.top, 10)
//
//                    Spacer()
//
//                    if !profiles.isEmpty {
//                        swipeButtonBar
//                            .padding(.bottom, 40)
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//        .onAppear { startLoading() }
//
//        // Restart from anywhere that bumps restartSwipingNonce
//        .onChange(of: restartSwipingNonce) { _ in
//            // Clear local transient state
//            likedIdBuffer.removeAll()
//            hasLoadedProfiles = false
//
//            profiles.removeAll()
//            likedProfiles.removeAll()
//            matchedProfile = nil
//            showCompletion = false
//
//            isLoading = true
//            errorMessage = ""
//            startLoading()
//        }
//
//        .sheet(isPresented: $showProfileSheet) {
//            if let current = authViewModel.profile {
//                ProfileView(profile: current)
//                    .environmentObject(authViewModel)
//            } else {
//                VStack(spacing: 12) {
//                    Text("No profile loaded")
//                        .font(.headline)
//                    Text("Log in or complete your profile to see details here.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//            }
//        }
//
//        .alert("Restart Swiping?",
//               isPresented: $showRestartAlert,
//               actions: {
//            Button("Cancel", role: .cancel) { }
//
//            Button("Restart", role: .destructive) {
//                restartAllSwipingFromSwipeScreen()
//            }
//        }, message: {
//            Text("This will clear your swipes, liked profiles, matches, and chat previews for this account and reload a fresh stack of profiles.")
//        })
//    }
//
//    // MARK: - Initial load
//    private func startLoading() {
//        guard !hasLoadedProfiles else { return }
//        hasLoadedProfiles = true
//        isLoading = true
//        errorMessage = ""
//
//        fetchProfiles()
//    }
//
//    // MARK: - Recommendation by interests
//    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
//        guard let currentInterests = authViewModel.profile?.interests,
//              !currentInterests.isEmpty else {
//            return all
//        }
//
//        let baseSet = Set(
//            currentInterests.map {
//                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//            }
//        )
//
//        func score(for profile: Profile) -> Int {
//            let theirSet = Set(
//                (profile.interests ?? []).map {
//                    $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//                }
//            )
//            return baseSet.intersection(theirSet).count
//        }
//
//        // higher score (more shared interests) should come first
//        return all.sorted { a, b in
//            score(for: a) > score(for: b)
//        }
//    }
//
//    // MARK: - Card Section
//    private var cardSection: some View {
//        ZStack {
//            if profiles.isEmpty {
//                CompletionScreen {
//                    // "Try again" from completion just re-fetches remaining / new;
//                    // for a TRUE reset (all profiles back + reset likes / matches / chats),
//                    // user taps Restart in this screen.
//                    hasLoadedProfiles = false
//                    startLoading()
//                    showCompletion = false
//                }
//                .transition(.opacity.combined(with: .scale))
//
//            } else {
//                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
//                    let isTopCard = enumeratedIndex == profiles.count - 1
//                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
//                    let depth = min(positionFromTop, 2)
//
//                    SwipeCard(
//                        profile: profile,
//                        onRemove: {
//                            guard isTopCard else { return }
//
//                            let wasLike = likedIdBuffer.contains(profile.id)
//
//                            // persist swipe PER USER
//                            persistSwipe(id: profile.id, like: wasLike)
//
//                            // send to backend only if real Mongo _id
//                            if isMongoId(profile.id) {
//                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
//                            }
//
//                            // remove card
//                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
//                                swipeTrigger = .none
//                                return
//                            }
//
//                            profiles.remove(at: removeIndex)
//
//                            if profiles.isEmpty {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                    showCompletion = true
//                                }
//                            }
//                            swipeTrigger = .none
//                            likedIdBuffer.remove(profile.id)
//                        },
//                        onMatch: { matched in
//                            // RIGHT swipe buffer
//                            likedIdBuffer.insert(matched.id)
//
//                            // local liked list for tab UI
//                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
//                                likedProfiles.append(matched)
//                            }
//                            matchedProfile = matched
//                        },
//                        swipeTrigger: Binding(
//                            get: { isTopCard ? swipeTrigger : .none },
//                            set: { newValue in
//                                if isTopCard { swipeTrigger = newValue }
//                            }
//                        ),
//                        canDrag: isTopCard
//                    )
//                    .offset(y: CGFloat(depth * 12))
//                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .zIndex(Double(enumeratedIndex))
//                }
//            }
//        }
//    }
//
//    // MARK: - Swipe Buttons
//    private var swipeButtonBar: some View {
//        HStack(spacing: 50) {
//            Button {
//                if swipeTrigger == .none { swipeTrigger = .left }
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.white)
//                    .shadow(radius: 6)
//            }
//
//            Button {
//                if swipeTrigger == .none { swipeTrigger = .right }
//            } label: {
//                Image(systemName: "heart.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.red)
//                    .shadow(radius: 6)
//            }
//        }
//    }
//
//    // MARK: - Fetch Profiles
//    private func fetchProfiles() {
//        // Always re-hydrate fake/demo users so their images are present
//        let fakeUsers = preparedFakeUsers()
//
//        var endpoint = "/profile"
//        if let currentId = authViewModel.profile?.id, !currentId.isEmpty {
//            endpoint += "?excludeUserId=\(currentId)"
//        }
//
//        NetworkManager.shared.getRequest(endpoint: endpoint) {
//            (result: Result<ProfileResponse, Error>) in
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    let backendProfiles = response.users ?? []
//
//                    // Universe for restoring likes: REAL first, then fake
//                    let allCombined = backendProfiles + fakeUsers
//                    restoreLikedProfiles(from: allCombined)
//
//                    // Filter already-swiped PER USER
//                    let swiped = loadSwipedIds()
//
//                    let backendNotSwiped = backendProfiles.filter { !swiped.contains($0.id) }
//                    let fakeNotSwiped    = fakeUsers.filter { !swiped.contains($0.id) }
//
//                    // Sort each group separately by interest score
//                    let backendSorted = sortProfilesForCurrentUser(backendNotSwiped)
//                    let fakeSorted    = sortProfilesForCurrentUser(fakeNotSwiped)
//
//                    // IMPORTANT:
//                    // In a ZStack with ForEach(enumerated),
//                    // the LAST element in `profiles` is drawn on TOP.
//                    //
//                    // So put FAKE first, REAL (backend) last,
//                    // so real profiles are always on top of the deck.
//                    profiles = fakeSorted + backendSorted
//
//                    isLoading = false
//
//                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(allCombined.count)), remaining \(profiles.count)")
//
//                case .failure(let error):
//                    // Fallback purely to fake users (still re-hydrated)
//                    restoreLikedProfiles(from: fakeUsers)
//
//                    let swiped = loadSwipedIds()
//                    let fakeNotSwiped = fakeUsers.filter { !swiped.contains($0.id) }
//
//                    profiles = sortProfilesForCurrentUser(fakeNotSwiped)
//                    errorMessage = "Loaded demo users (backend unavailable)"
//                    isLoading = false
//
//                    print("⚠️ Fallback profiles:", error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    // MARK: - Prepare fake/demo users with images
//    private func preparedFakeUsers() -> [Profile] {
//        let raw = FakeUserLoader.loadCSV()
//
//        return raw.map { original in
//            var p = original
//
//            // If imageData is already set, keep it
//            if p.imageData != nil {
//                return p
//            }
//
//            // 1) Try explicit localImageName from CSV (if your Profile supports it)
//            if let local = p.localImageName,
//               !local.isEmpty,
//               let uiImage = UIImage(named: local),
//               let data = uiImage.jpegData(compressionQuality: 0.9) ?? uiImage.pngData() {
//                p.imageData = data
//                return p
//            }
//
//            // 2) If profilePhoto looks like an asset name (no http / slash)
//            if let photoName = p.profilePhoto,
//               !photoName.isEmpty {
//                let trimmed = photoName.trimmingCharacters(in: .whitespacesAndNewlines)
//                if !trimmed.lowercased().hasPrefix("http"),
//                   !trimmed.contains("/"),
//                   let uiImage = UIImage(named: trimmed),
//                   let data = uiImage.jpegData(compressionQuality: 0.9) ?? uiImage.pngData() {
//                    p.imageData = data
//                    return p
//                }
//            }
//
//            // 3) Otherwise leave imageData nil (card will fall back to placeholder)
//            return p
//        }
//    }
//
//    // MARK: - Per-user keys
//    private func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    private func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Persistence helpers (PER USER)
//    private func loadSwipedIds() -> Set<String> {
//        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
//              !data.isEmpty,
//              let arr = try? JSONDecoder().decode([String].self, from: data)
//        else { return [] }
//        return Set(arr)
//    }
//
//    private func loadLikedIds() -> Set<String> {
//        guard let data = UserDefaults.standard.data(forKey: likedKey()),
//              !data.isEmpty,
//              let arr = try? JSONDecoder().decode([String].self, from: data)
//        else { return [] }
//        return Set(arr)
//    }
//
//    private func saveSwipedIds(_ set: Set<String>) {
//        if let data = try? JSONEncoder().encode(Array(set)) {
//            UserDefaults.standard.set(data, forKey: swipedKey())
//        }
//    }
//
//    private func saveLikedIds(_ set: Set<String>) {
//        if let data = try? JSONEncoder().encode(Array(set)) {
//            UserDefaults.standard.set(data, forKey: likedKey())
//        }
//    }
//
//    private func persistSwipe(id: String, like: Bool) {
//        var swiped = loadSwipedIds()
//        swiped.insert(id)
//        saveSwipedIds(swiped)
//
//        if like {
//            var liked = loadLikedIds()
//            liked.insert(id)
//            saveLikedIds(liked)
//        }
//    }
//
//    // MARK: - Restore liked profiles (REAL first, then fake)
//    private func restoreLikedProfiles(from all: [Profile]) {
//        let likedIds = loadLikedIds()
//        var restored = all.filter { likedIds.contains($0.id) }
//
//        // Real Mongo IDs first, then fake ones
//        restored.sort { lhs, rhs in
//            let lhsReal = isMongoId(lhs.id)
//            let rhsReal = isMongoId(rhs.id)
//
//            if lhsReal == rhsReal {
//                // tie-breaker by name for stable display
//                let lName = lhs.name ?? ""
//                let rName = rhs.name ?? ""
//                return lName.localizedCaseInsensitiveCompare(rName) == .orderedAscending
//            }
//
//            // real first
//            return lhsReal && !rhsReal
//        }
//
//        likedProfiles = restored
//    }
//
//    // Avoid backend CastError for fake UUID ids
//    private func isMongoId(_ id: String) -> Bool {
//        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
//    }
//
//    // MARK: - Restart logic from SwipeScreen
//    private func restartAllSwipingFromSwipeScreen() {
//        // 1) Clear persisted swipe & like IDs for this user
//        UserDefaults.standard.removeObject(forKey: swipedKey())
//        UserDefaults.standard.removeObject(forKey: likedKey())
//
//        // 1b) Also clear any legacy global keys (backward compatibility)
//        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
//        UserDefaults.standard.removeObject(forKey: "likedProfileIds")
//
//        // 2) Ask AuthViewModel to clear matches + chats on backend
//        //    and reset ChatStore + sockets + match suppression
//        authViewModel.applyLocalRestartFromUI()
//
//        // 3) Bump nonce so .onChange(restartSwipingNonce) handles:
//        //    - clearing local profiles / likedProfiles / buffer
//        //    - reloading a fresh deck
//        restartSwipingNonce += 1
//
//        print("♻️ Restart Swiping (SwipeScreen): swipes, likes, matches, chats cleared for this user; fresh deck loading.")
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    SwipeScreen(
//        profiles: .constant(sampleProfiles),
//        likedProfiles: .constant([]),
//        swipeTrigger: .constant(.none),
//        matchedProfile: .constant(nil),
//        showCompletion: .constant(false)
//    )
//    .environmentObject(AuthViewModel())
//}
//  SwipeScreen.swift
//  NetSwipe
//
//  ✅ Persists swiped + liked IDs PER USER (UserDefaults)
//  ✅ Filters already-swiped profiles on load
//  ✅ Restart Swiping (in this screen) clears swipes + likes + matches + chats
//  ✅ Sends swipes to backend ONLY for real Mongo IDs
//  ✅ Interest-based recommendation ordering
//  ✅ REAL (backend) profiles are always on TOP of the deck (above fake/demo)
//  ✅ Fake/demo profiles always re-hydrate their images after Restart Swiping
//  ✅ Liked profiles are ordered: real (Mongo) first, then fake/demo
//

import SwiftUI
import UIKit

struct SwipeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @Binding var profiles: [Profile]
    @Binding var likedProfiles: [Profile]
    @Binding var swipeTrigger: SwipeDirection
    @Binding var matchedProfile: Profile?
    @Binding var showCompletion: Bool

    // MARK: - Local State
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    @State private var hasLoadedProfiles: Bool = false

    // Track RIGHT swipes before removal
    @State private var likedIdBuffer: Set<String> = []

    // Profile sheet toggle
    @State private var showProfileSheet: Bool = false

    // Restart trigger shared with other views (like LikedUsersView)
    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0

    // Alert for restart confirmation
    @State private var showRestartAlert: Bool = false

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.3, blue: 0.8),
                    Color(red: 0.15, green: 0.0, blue: 0.25)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {

                // MARK: - Header (Title + Restart + Profile)
                ZStack {
                    Text("NETSWIPE")
                        .font(.custom("Baskerville", size: 34))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    HStack {
                        // Restart button (top-left)
                        Button {
                            showRestartAlert = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.top, 8)

                        Spacer()

                        // Profile button (top-right)
                        Button {
                            showProfileSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                }

                // MARK: - Main content
                if isLoading {
                    Spacer()
                    ProgressView("Loading profiles...")
                        .foregroundColor(.white)
                    Spacer()

                } else if !errorMessage.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 40))
                        Text("Failed to load profiles.")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            hasLoadedProfiles = false
                            startLoading()
                        }
                        .padding(.top, 4)
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    Spacer()

                } else {
                    cardSection
                        .frame(height: 500)
                        .padding(.top, 10)

                    Spacer()

                    if !profiles.isEmpty {
                        swipeButtonBar
                            .padding(.bottom, 40)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear { startLoading() }

        // Restart from anywhere that bumps restartSwipingNonce
        .onChange(of: restartSwipingNonce) { _ in
            // Clear local transient state
            likedIdBuffer.removeAll()
            hasLoadedProfiles = false

            profiles.removeAll()
            likedProfiles.removeAll()
            matchedProfile = nil
            showCompletion = false

            isLoading = true
            errorMessage = ""
            startLoading()
        }

        // 🔹 When unmatch happens in LikedUsersView, AuthViewModel sets
        // resurrectProfileAfterUnmatch. We listen here and bring that profile
        // back to the TOP of the deck.
        .onChange(of: authViewModel.resurrectProfileAfterUnmatch) { newValue in
            guard let resurrect = newValue else { return }

            // Remove this profile from liked list (in case it was there)
            likedProfiles.removeAll { $0.id == resurrect.id }

            // Remove any existing copy from the deck
            profiles.removeAll { $0.id == resurrect.id }

            // Append at the END → top card in the ZStack
            profiles.append(resurrect)

            // If we were showing completion (no cards), hide it
            showCompletion = false
            isLoading = false

            print("🃏 SwipeScreen resurrected profile at top of deck:", resurrect.id)

            // Clear the signal so this only happens once
            authViewModel.resurrectProfileAfterUnmatch = nil
        }

        .sheet(isPresented: $showProfileSheet) {
            if let current = authViewModel.profile {
                ProfileView(profile: current)
                    .environmentObject(authViewModel)
            } else {
                VStack(spacing: 12) {
                    Text("No profile loaded")
                        .font(.headline)
                    Text("Log in or complete your profile to see details here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }

        .alert("Restart Swiping?",
               isPresented: $showRestartAlert,
               actions: {
            Button("Cancel", role: .cancel) { }

            Button("Restart", role: .destructive) {
                restartAllSwipingFromSwipeScreen()
            }
        }, message: {
            Text("This will clear your swipes, liked profiles, matches, and chat previews for this account and reload a fresh stack of profiles.")
        })
    }

    // MARK: - Initial load
    private func startLoading() {
        guard !hasLoadedProfiles else { return }
        hasLoadedProfiles = true
        isLoading = true
        errorMessage = ""

        fetchProfiles()
    }

    // MARK: - Recommendation by interests
    private func sortProfilesForCurrentUser(_ all: [Profile]) -> [Profile] {
        guard let currentInterests = authViewModel.profile?.interests,
              !currentInterests.isEmpty else {
            return all
        }

        let baseSet = Set(
            currentInterests.map {
                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            }
        )

        func score(for profile: Profile) -> Int {
            let theirSet = Set(
                (profile.interests ?? []).map {
                    $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                }
            )
            return baseSet.intersection(theirSet).count
        }

        // higher score (more shared interests) should come first
        return all.sorted { a, b in
            score(for: a) > score(for: b)
        }
    }

    // MARK: - Card Section
    private var cardSection: some View {
        ZStack {
            if profiles.isEmpty {
                CompletionScreen {
                    // "Try again" from completion just re-fetches remaining / new;
                    // for a TRUE reset (all profiles back + reset likes / matches / chats),
                    // user taps Restart in this screen.
                    hasLoadedProfiles = false
                    startLoading()
                    showCompletion = false
                }
                .transition(.opacity.combined(with: .scale))

            } else {
                ForEach(Array(profiles.enumerated()), id: \.element.id) { enumeratedIndex, profile in
                    let isTopCard = enumeratedIndex == profiles.count - 1
                    let positionFromTop = (profiles.count - 1) - enumeratedIndex
                    let depth = min(positionFromTop, 2)

                    SwipeCard(
                        profile: profile,
                        onRemove: {
                            guard isTopCard else { return }

                            let wasLike = likedIdBuffer.contains(profile.id)

                            // persist swipe PER USER
                            persistSwipe(id: profile.id, like: wasLike)

                            // send to backend only if real Mongo _id
                            if isMongoId(profile.id) {
                                authViewModel.sendSwipe(to: profile.id, like: wasLike) { _ in }
                            }

                            // remove card
                            guard let removeIndex = profiles.firstIndex(where: { $0.id == profile.id }) else {
                                swipeTrigger = .none
                                return
                            }

                            profiles.remove(at: removeIndex)

                            if profiles.isEmpty {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showCompletion = true
                                }
                            }
                            swipeTrigger = .none
                            likedIdBuffer.remove(profile.id)
                        },
                        onMatch: { matched in
                            // RIGHT swipe buffer
                            likedIdBuffer.insert(matched.id)

                            // local liked list for tab UI
                            if !likedProfiles.contains(where: { $0.id == matched.id }) {
                                likedProfiles.append(matched)
                            }
                            matchedProfile = matched
                        },
                        swipeTrigger: Binding(
                            get: { isTopCard ? swipeTrigger : .none },
                            set: { newValue in
                                if isTopCard { swipeTrigger = newValue }
                            }
                        ),
                        canDrag: isTopCard
                    )
                    .offset(y: CGFloat(depth * 12))
                    .scaleEffect(1.0 - CGFloat(depth) * 0.03)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(Double(enumeratedIndex))
                }
            }
        }
    }

    // MARK: - Swipe Buttons
    private var swipeButtonBar: some View {
        HStack(spacing: 50) {
            Button {
                if swipeTrigger == .none { swipeTrigger = .left }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(radius: 6)
            }

            Button {
                if swipeTrigger == .none { swipeTrigger = .right }
            } label: {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .shadow(radius: 6)
            }
        }
    }

    // MARK: - Fetch Profiles
    private func fetchProfiles() {
        // Always re-hydrate fake/demo users so their images are present
        let fakeUsers = preparedFakeUsers()

        var endpoint = "/profile"
        if let currentId = authViewModel.profile?.id, !currentId.isEmpty {
            endpoint += "?excludeUserId=\(currentId)"
        }

        NetworkManager.shared.getRequest(endpoint: endpoint) {
            (result: Result<ProfileResponse, Error>) in

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let backendProfiles = response.users ?? []

                    // Universe for restoring likes: REAL first, then fake
                    let allCombined = backendProfiles + fakeUsers
                    restoreLikedProfiles(from: allCombined)

                    // Filter already-swiped PER USER
                    let swiped = loadSwipedIds()

                    let backendNotSwiped = backendProfiles.filter { !swiped.contains($0.id) }
                    let fakeNotSwiped    = fakeUsers.filter { !swiped.contains($0.id) }

                    // Sort each group separately by interest score
                    let backendSorted = sortProfilesForCurrentUser(backendNotSwiped)
                    let fakeSorted    = sortProfilesForCurrentUser(fakeNotSwiped)

                    // IMPORTANT:
                    // In a ZStack with ForEach(enumerated),
                    // the LAST element in `profiles` is drawn on TOP.
                    //
                    // So put FAKE first, REAL (backend) last,
                    // so real profiles are always on top of the deck.
                    profiles = fakeSorted + backendSorted

                    isLoading = false

                    print("✅ Loaded \(backendProfiles.count) backend + \(fakeUsers.count) fake (total \(allCombined.count)), remaining \(profiles.count)")

                case .failure(let error):
                    // Fallback purely to fake users (still re-hydrated)
                    restoreLikedProfiles(from: fakeUsers)

                    let swiped = loadSwipedIds()
                    let fakeNotSwiped = fakeUsers.filter { !swiped.contains($0.id) }

                    profiles = sortProfilesForCurrentUser(fakeNotSwiped)
                    errorMessage = "Loaded demo users (backend unavailable)"
                    isLoading = false

                    print("⚠️ Fallback profiles:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Prepare fake/demo users with images
    private func preparedFakeUsers() -> [Profile] {
        let raw = FakeUserLoader.loadCSV()

        return raw.map { original in
            var p = original

            // If imageData is already set, keep it
            if p.imageData != nil {
                return p
            }

            // 1) Try explicit localImageName from CSV (if your Profile supports it)
            if let local = p.localImageName,
               !local.isEmpty,
               let uiImage = UIImage(named: local),
               let data = uiImage.jpegData(compressionQuality: 0.9) ?? uiImage.pngData() {
                p.imageData = data
                return p
            }

            // 2) If profilePhoto looks like an asset name (no http / slash)
            if let photoName = p.profilePhoto,
               !photoName.isEmpty {
                let trimmed = photoName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.lowercased().hasPrefix("http"),
                   !trimmed.contains("/"),
                   let uiImage = UIImage(named: trimmed),
                   let data = uiImage.jpegData(compressionQuality: 0.9) ?? uiImage.pngData() {
                    p.imageData = data
                    return p
                }
            }

            // 3) Otherwise leave imageData nil (card will fall back to placeholder)
            return p
        }
    }

    // MARK: - Per-user keys
    private func swipedKey() -> String {
        let uid = authViewModel.userId ?? "guest"
        return "swipedProfileIds_\(uid)"
    }

    private func likedKey() -> String {
        let uid = authViewModel.userId ?? "guest"
        return "likedProfileIds_\(uid)"
    }

    // MARK: - Persistence helpers (PER USER)
    private func loadSwipedIds() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
              !data.isEmpty,
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(arr)
    }

    private func loadLikedIds() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: likedKey()),
              !data.isEmpty,
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(arr)
    }

    private func saveSwipedIds(_ set: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: swipedKey())
        }
    }

    private func saveLikedIds(_ set: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: likedKey())
        }
    }

    private func persistSwipe(id: String, like: Bool) {
        var swiped = loadSwipedIds()
        swiped.insert(id)
        saveSwipedIds(swiped)

        if like {
            var liked = loadLikedIds()
            liked.insert(id)
            saveLikedIds(liked)
        }
    }

    // MARK: - Restore liked profiles (REAL first, then fake)
    private func restoreLikedProfiles(from all: [Profile]) {
        let likedIds = loadLikedIds()
        var restored = all.filter { likedIds.contains($0.id) }

        // Real Mongo IDs first, then fake ones
        restored.sort { lhs, rhs in
            let lhsReal = isMongoId(lhs.id)
            let rhsReal = isMongoId(rhs.id)

            if lhsReal == rhsReal {
                // tie-breaker by name for stable display
                let lName = lhs.name ?? ""
                let rName = rhs.name ?? ""
                return lName.localizedCaseInsensitiveCompare(rName) == .orderedAscending
            }

            // real first
            return lhsReal && !rhsReal
        }

        likedProfiles = restored
    }

    // Avoid backend CastError for fake UUID ids
    private func isMongoId(_ id: String) -> Bool {
        id.range(of: "^[0-9a-fA-F]{24}$", options: .regularExpression) != nil
    }

    // MARK: - Restart logic from SwipeScreen
    private func restartAllSwipingFromSwipeScreen() {
        // 1) Clear persisted swipe & like IDs for this user
        UserDefaults.standard.removeObject(forKey: swipedKey())
        UserDefaults.standard.removeObject(forKey: likedKey())

        // 1b) Also clear any legacy global keys (backward compatibility)
        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
        UserDefaults.standard.removeObject(forKey: "likedProfileIds")

        // 2) Ask AuthViewModel to clear matches + chats on backend
        //    and reset ChatStore + sockets + match suppression
        authViewModel.applyLocalRestartFromUI()

        // 3) Bump nonce so .onChange(restartSwipingNonce) handles:
        //    - clearing local profiles / likedProfiles / buffer
        //    - reloading a fresh deck
        restartSwipingNonce += 1

        print("♻️ Restart Swiping (SwipeScreen): swipes, likes, matches, chats cleared for this user; fresh deck loading.")
    }
}

// MARK: - Preview
#Preview {
    SwipeScreen(
        profiles: .constant(sampleProfiles),
        likedProfiles: .constant([]),
        swipeTrigger: .constant(.none),
        matchedProfile: .constant(nil),
        showCompletion: .constant(false)
    )
    .environmentObject(AuthViewModel())
}
