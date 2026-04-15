////
////  ProfileSetupScreen.swift
////  NetSwipe
////
////  Safer, keyboard-friendly, and warning-free
////
//
//import SwiftUI
//import PhotosUI
//
//struct ProfileSetupScreen: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @Environment(\.dismiss) private var dismiss
//
//    // MARK: - Bindings from App
//    @Binding var profiles: [Profile]
//    @Binding var likedProfiles: [Profile]
//    @Binding var swipeTrigger: SwipeDirection
//    @Binding var matchedProfile: Profile?
//    @Binding var showCompletion: Bool
//    @Binding var hasSetupProfile: Bool
//
//    // ✅ To reset login and return to WelcomeScreen
//    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
//
//    // MARK: - Local States
//    @State private var name: String = ""
//    @State private var interests: String = ""
//    @State private var pickedItem: PhotosPickerItem?
//    @State private var pickedImageData: Data?
//    @State private var isUploading: Bool = false
//    @State private var uploadMessage: String = ""
//    @State private var showExitAlert: Bool = false
//
//    // MARK: - View
//    var body: some View {
//        ZStack {
//            // Background gradient (sRGB to avoid out-of-range warnings)
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(.sRGB, red: 0.55, green: 0.2, blue: 0.75, opacity: 1.0),
//                    Color(.sRGB, red: 0.0,  green: 0.0, blue: 0.0,  opacity: 1.0)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 30) {
//                // -------------------------------
//                // 🔹 Header with Back Button
//                // -------------------------------
//                HStack {
//                    Button(action: { showExitAlert = true }) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 22, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(10)
//                            .background(Color.white.opacity(0.15))
//                            .clipShape(Circle())
//                    }
//
//                    Spacer()
//
//                    Text("Set up your profile")
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//
//                    Spacer()
//                    // Placeholder to center title
//                    Circle().fill(Color.clear).frame(width: 42, height: 42)
//                }
//                .padding(.horizontal)
//                .padding(.top, 20)
//
//                // -------------------------------
//                // 🔹 Scrollable Form
//                // -------------------------------
//                ScrollView {
//                    VStack(spacing: 24) {
//                        questionField("What’s your name?", text: $name)
//                        questionField("What are your interests? (comma separated)", text: $interests)
//
//                        // -------------------------------
//                        // 🔹 Photo Upload Section
//                        // -------------------------------
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Upload a profile photo")
//                                .foregroundColor(.white.opacity(0.9))
//                                .font(.headline)
//
//                            PhotosPicker(selection: $pickedItem, matching: .images) {
//                                ZStack {
//                                    if let data = pickedImageData,
//                                       let uiImage = UIImage(data: data) {
//                                        Image(uiImage: uiImage)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill)
//                                            .frame(height: 180)
//                                            .cornerRadius(12)
//                                            .clipped()
//                                    } else {
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
//                                            .frame(height: 180)
//                                            .overlay(
//                                                VStack(spacing: 10) {
//                                                    Image(systemName: "plus.circle.fill")
//                                                        .font(.system(size: 40))
//                                                        .foregroundColor(.white)
//                                                    Text("Tap to choose a photo")
//                                                        .foregroundColor(.white.opacity(0.8))
//                                                        .font(.subheadline)
//                                                }
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .scrollDismissesKeyboard(.interactively)
//
//                Spacer(minLength: 8)
//
//                // -------------------------------
//                // 🔹 Save Button
//                // -------------------------------
//                Button(action: saveProfile) {
//                    HStack {
//                        if isUploading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        }
//                        Text(isUploading ? "Saving..." : "Start Connecting")
//                            .font(.headline)
//                    }
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(isUploading ? Color.gray.opacity(0.5) : Color.blue)
//                    .cornerRadius(12)
//                    .padding(.horizontal)
//                }
//                .disabled(isUploading || name.trimmingCharacters(in: .whitespaces).isEmpty)
//
//                // -------------------------------
//                // 🔹 Back to Login Button
//                // -------------------------------
//                Button(action: { showExitAlert = true }) {
//                    Text("Back to Login")
//                        .foregroundColor(.white.opacity(0.85))
//                        .underline()
//                        .padding(.top, 6)
//                }
//
//                if !uploadMessage.isEmpty {
//                    Text(uploadMessage)
//                        .foregroundColor(uploadMessage.hasPrefix("❌") ? .red : .white.opacity(0.9))
//                        .font(.subheadline)
//                        .padding(.bottom, 10)
//                        .multilineTextAlignment(.center)
//                }
//            }
//        }
//        // ✅ Photo picker listener
//        .onChange(of: pickedItem) { _, newItem in
//            guard let item = newItem else { return }
//            Task {
//                if let data = try? await item.loadTransferable(type: Data.self) {
//                    await MainActor.run { pickedImageData = data }
//                }
//            }
//        }
//        // ✅ Alert for leaving setup → return to WelcomeScreen
//        .alert("Leave Profile Setup?", isPresented: $showExitAlert) {
//            Button("Cancel", role: .cancel) { }
//            Button("Yes, Go Back", role: .destructive) {
//                isLoggedIn = false   // ✅ Log out → triggers WelcomeScreen
//                hasSetupProfile = false
//            }
//        } message: {
//            Text("Your entered details will not be saved.")
//        }
//        // Small toolbar to dismiss keyboard (helps with keyboard constraint spam)
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                Button("Done") { hideKeyboard() }
//            }
//        }
//    }
//
//    // MARK: - Custom Text Field
//    private func questionField(_ question: String, text: Binding<String>) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(question)
//                .foregroundColor(.white.opacity(0.92))
//                .font(.headline)
//
//            TextField("Answer here…", text: text)
//                .padding()
//                .background(Color.white.opacity(0.15))
//                .cornerRadius(10)
//                .foregroundColor(.white)
//                .textInputAutocapitalization(.words)
//                .submitLabel(.done)
//        }
//    }
//
//    // MARK: - Save Profile Logic
//    private func saveProfile() {
//        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedName.isEmpty else {
//            uploadMessage = "Please enter your name."
//            return
//        }
//
//        isUploading = true
//        uploadMessage = "Saving your profile…"
//
//        // ✅ Placeholder image or user-picked image (upload pipeline can be added later)
//        let imageUrl = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png"
//
//        // ✅ Safe userId retrieval
//        let userId = authViewModel.profile?.id ?? UserDefaults.standard.string(forKey: "userId") ?? ""
//        guard !userId.isEmpty else {
//            isUploading = false
//            uploadMessage = "❌ Unable to find user ID. Please log in again."
//            return
//        }
//
//        // ✅ Convert interests string → array
//        let interestsArray = interests
//            .split(separator: ",")
//            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            .filter { !$0.isEmpty }
//
//        // ✅ Send to backend
//        authViewModel.completeProfile(
//            userId: userId,
//            name: trimmedName,
//            interests: interestsArray,
//            imageUrl: imageUrl
//        )
//
//        // Locally add a card so the Swipe screen has content immediately
//        let finalDesc = interestsArray.isEmpty ? "New here • Say hi!" : interestsArray.joined(separator: ", ")
//
//        // ⬇️ Fixed argument order: imageData BEFORE profileCompleted
//        let newProfile = Profile(
//            id: userId,
//            name: trimmedName,
//            description: finalDesc,
//            interests: interestsArray,
//            profilePhoto: pickedImageData == nil ? "roszhan" : nil,
//            imageData: pickedImageData,
//            profileCompleted: true
//        )
//
//        profiles = [newProfile] + sampleProfiles
//
//        // Best effort: wait briefly so /profile/update returns, then mark setup done.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//            self.isUploading = false
//            self.uploadMessage = "✅ Profile saved successfully!"
//            self.hasSetupProfile = true
//        }
//    }
//
//    // MARK: - Helpers
//    private func hideKeyboard() {
//        #if canImport(UIKit)
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//        #endif
//    }
//}
//
//  ProfileSetupScreen.swift
//  NetSwipe
//
//  Safer, keyboard-friendly, and base64-ready for Mongo image storage
//

import SwiftUI
import PhotosUI

struct ProfileSetupScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Bindings from App
    @Binding var profiles: [Profile]
    @Binding var likedProfiles: [Profile]
    @Binding var swipeTrigger: SwipeDirection
    @Binding var matchedProfile: Profile?
    @Binding var showCompletion: Bool
    @Binding var hasSetupProfile: Bool

    // ✅ To reset login and return to WelcomeScreen
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    // MARK: - Local States
    @State private var name: String = ""
    @State private var interests: String = ""
    @State private var pickedItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    @State private var isUploading: Bool = false
    @State private var uploadMessage: String = ""
    @State private var showExitAlert: Bool = false

    // MARK: - View
    var body: some View {
        ZStack {
            // Background gradient (sRGB to avoid out-of-range warnings)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.55, green: 0.2, blue: 0.75, opacity: 1.0),
                    Color(.sRGB, red: 0.0,  green: 0.0, blue: 0.0,  opacity: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // -------------------------------
                // 🔹 Header with Back Button
                // -------------------------------
                HStack {
                    Button(action: { showExitAlert = true }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Set up your profile")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Spacer()
                    // Placeholder to center title
                    Circle().fill(Color.clear).frame(width: 42, height: 42)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // -------------------------------
                // 🔹 Scrollable Form
                // -------------------------------
                ScrollView {
                    VStack(spacing: 24) {
                        questionField("What’s your name?", text: $name)
                        questionField("What are your interests? (comma separated)", text: $interests)

                        // -------------------------------
                        // 🔹 Photo Upload Section
                        // -------------------------------
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload a profile photo")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.headline)

                            PhotosPicker(selection: $pickedItem, matching: .images) {
                                ZStack {
                                    if let data = pickedImageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 180)
                                            .cornerRadius(12)
                                            .clipped()
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
                                            .frame(height: 180)
                                            .overlay(
                                                VStack(spacing: 10) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.white)
                                                    Text("Tap to choose a photo")
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .font(.subheadline)
                                                }
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollDismissesKeyboard(.interactively)

                Spacer(minLength: 8)

                // -------------------------------
                // 🔹 Save Button
                // -------------------------------
                Button(action: saveProfile) {
                    HStack {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isUploading ? "Saving..." : "Start Connecting")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isUploading ? Color.gray.opacity(0.5) : Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(isUploading || name.trimmingCharacters(in: .whitespaces).isEmpty)

                // -------------------------------
                // 🔹 Back to Login Button
                // -------------------------------
                Button(action: { showExitAlert = true }) {
                    Text("Back to Login")
                        .foregroundColor(.white.opacity(0.85))
                        .underline()
                        .padding(.top, 6)
                }

                if !uploadMessage.isEmpty {
                    Text(uploadMessage)
                        .foregroundColor(uploadMessage.hasPrefix("❌") ? .red : .white.opacity(0.9))
                        .font(.subheadline)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                }
            }
        }
        // ✅ Photo picker listener
        .onChange(of: pickedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run { pickedImageData = data }
                }
            }
        }
        // ✅ Alert for leaving setup → return to WelcomeScreen
        .alert("Leave Profile Setup?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Go Back", role: .destructive) {
                isLoggedIn = false   // ✅ Log out → triggers WelcomeScreen
                hasSetupProfile = false
            }
        } message: {
            Text("Your entered details will not be saved.")
        }
        // Small toolbar to dismiss keyboard (helps with keyboard constraint spam)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
            }
        }
    }

    // MARK: - Custom Text Field
    private func questionField(_ question: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .foregroundColor(.white.opacity(0.92))
                .font(.headline)

            TextField("Answer here…", text: text)
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .foregroundColor(.white)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
        }
    }

    // MARK: - Save Profile Logic
    private func saveProfile() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            uploadMessage = "Please enter your name."
            return
        }

        isUploading = true
        uploadMessage = "Saving your profile…"

        // ✅ Safe userId retrieval
        let userId = authViewModel.profile?.id
            ?? UserDefaults.standard.string(forKey: "userId")
            ?? ""

        guard !userId.isEmpty else {
            isUploading = false
            uploadMessage = "❌ Unable to find user ID. Please log in again."
            return
        }

        // ✅ Convert interests string → array
        let interestsArray = interests
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // ✅ Encode photo for backend:
        // If user picked an image → base64 string (to store in Mongo)
        // Else → use a default remote avatar URL
        let encodedPhoto: String
        if let data = pickedImageData {
            encodedPhoto = data.base64EncodedString()
        } else {
            encodedPhoto = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png"
        }

        // ✅ Send to backend (your authViewModel will POST to /profile/update with `profilePhoto`)
        authViewModel.completeProfile(
            userId: userId,
            name: trimmedName,
            interests: interestsArray,
            imageUrl: encodedPhoto   // can be base64 OR URL
        )

        // Local description text for the card
        let finalDesc = interestsArray.isEmpty
            ? "New here • Say hi!"
            : interestsArray.joined(separator: ", ")

        // ✅ Build local Profile so Swipe + ProfileView show updated data immediately
        let newProfile = Profile(
            id: userId,
            email: authViewModel.profile?.email,
            username: authViewModel.profile?.username,
            verified: authViewModel.profile?.verified,
            name: trimmedName,
            description: finalDesc,
            interests: interestsArray,
            profilePhoto: encodedPhoto,
            location: nil,
            isProfileComplete: true,
            createdAt: nil,
            updatedAt: nil,
            imageData: pickedImageData,     // so UI can use raw Data right away
            profileCompleted: true
        )

        // Update global + local state
        authViewModel.profile = newProfile
        profiles = [newProfile] + sampleProfiles

        // Best effort: wait briefly so /profile/update returns, then mark setup done.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isUploading = false
            self.uploadMessage = "✅ Profile saved successfully!"
            self.hasSetupProfile = true
        }
    }

    // MARK: - Helpers
    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
        #endif
    }
}
