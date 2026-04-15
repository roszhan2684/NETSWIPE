//
//  WelcomeScreen.swift
//  NetSwipe
//
//  FINAL — Navigation fully fixed for Login & Register
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var likedProfiles: [Profile]
    @Binding var isLoggedIn: Bool

    @EnvironmentObject var authViewModel: AuthViewModel

    // Track navigation destination
    @State private var navigateTo: Destination? = nil

    enum Destination: Hashable, Identifiable {
        case login
        case register

        var id: Self { self } // Required for navigationDestination(item:)
    }

    var body: some View {
        // ✅ Simple NavigationStack (no .path needed)
        NavigationStack {
            ZStack {
                // 🌅 Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.45, blue: 0.1),
                        Color(red: 0.25, green: 0.0, blue: 0.0)
                    ]),
                    center: .center,
                    startRadius: 80,
                    endRadius: 600
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // 🔹 App Icon
                    Image("group-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 8)

                    // 🔹 Title
                    Text("NetSwipe")
                        .font(.custom("GCsaphoneDEMO-Regular", size: 54))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow.opacity(0.9), .orange, .red.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.7), radius: 12, x: 0, y: 6)
                        .tracking(4)
                        .padding(.top, 10)

                    // 🔹 Subtitle
                    Text("SWIPE   •   CONNECT   •   GROW")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(1.5)

                    Spacer()

                    // 🔹 Buttons
                    FloatingButton(title: "Login", colors: [Color.blue, Color.cyan]) {
                        navigateTo = .login
                    }

                    FloatingButton(title: "Register", colors: [Color.green, Color.teal]) {
                        navigateTo = .register
                    }

                    Spacer()
                }
                .padding()
            }
            // ✅ Navigation destinations
            .navigationDestination(item: $navigateTo) { dest in
                switch dest {
                case .login:
                    LoginScreen(
                        likedProfiles: $likedProfiles,
                        isLoggedIn: $isLoggedIn
                    )
                    .environmentObject(authViewModel)

                case .register:
                    RegisterScreen(
                        likedProfiles: $likedProfiles,
                        isLoggedIn: $isLoggedIn
                    )
                    .environmentObject(authViewModel)
                }
            }
        }
    }
}

//
// MARK: - Floating Button with Action
//
struct FloatingButton: View {
    let title: String
    let colors: [Color]
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Text(title.uppercased())
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 300)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
                .shadow(
                    color: .black.opacity(isPressed ? 0.2 : 0.5),
                    radius: isPressed ? 4 : 10,
                    x: 0,
                    y: isPressed ? 2 : 8
                )
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    WelcomeScreen(
        likedProfiles: .constant(sampleProfiles),
        isLoggedIn: .constant(false)
    )
    .environmentObject(AuthViewModel())
}
