import SwiftUI

struct SplashScreen: View {
    @Binding var likedProfiles: [Profile]
    @Binding var isLoggedIn: Bool   // ✅ add this so you can pass it forward

    @State private var showWelcome = false

    var body: some View {
        ZStack {
            Image("splash_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text("NetSwipe")
                    .font(.largeTitle) // ✅ use .largeTitle (no .xlargeTitle in SwiftUI)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                ProgressView()
                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showWelcome = true
            }
        }
        .fullScreenCover(isPresented: $showWelcome) {
            // ✅ forward BOTH bindings
            WelcomeScreen(
                likedProfiles: $likedProfiles,
                isLoggedIn: $isLoggedIn
            )
        }
    }
}
