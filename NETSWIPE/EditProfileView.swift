////
////  EditProfileView.swift
////  NetSwipe
////
////  Allows the user to edit their profile (name, interests, bio, location, photo URL)
////  and updates the backend via /profile/update
////
//
//import SwiftUI
//
///// Body sent to POST /profile/update
//struct UpdateProfileBody: Codable {
//    let userId: String
//    let name: String
//    let interests: String       // CSV string: "UI/UX, AI, Product"
//    let bio: String
//    let location: String
//    let profilePhoto: String
//}
//
//struct EditProfileView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    // 🔹 Local editable copy of the profile (NON-optional)
//    @State private var profile: Profile
//    
//    @State private var name: String = ""
//    @State private var interestsText: String = ""
//    @State private var bio: String = ""
//    @State private var location: String = ""
//    @State private var photoURL: String = ""
//    
//    @State private var isSaving: Bool = false
//    @State private var errorMessage: String?
//    
//    // MARK: - Init
//    init(profile: Profile) {
//        _profile = State(initialValue: profile)
//        _name = State(initialValue: profile.name ?? "")
//        _interestsText = State(initialValue: (profile.interests ?? []).joined(separator: ", "))
//        _bio = State(initialValue: profile.description ?? "")
//        _location = State(initialValue: profile.location ?? "")
//        _photoURL = State(initialValue: profile.profilePhoto ?? "")
//    }
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 0.2, green: 0.0, blue: 0.25),
//                        Color(red: 0.5, green: 0.2, blue: 0.8)
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 20) {
//                        // Current photo preview
//                        profile.profileImage()
//                            .frame(width: 120, height: 120)
//                            .clipShape(RoundedRectangle(cornerRadius: 24))
//                            .shadow(radius: 6)
//                            .padding(.top, 24)
//                        
//                        Group {
//                            field("Name", text: $name)
//                            field("Interests (comma separated)", text: $interestsText)
//                            field("Location", text: $location)
//                            field("Photo URL (optional)", text: $photoURL)
//                            
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Bio")
//                                    .font(.headline)
//                                    .foregroundColor(.white.opacity(0.9))
//                                TextEditor(text: $bio)
//                                    .frame(minHeight: 120)
//                                    .padding(8)
//                                    .background(Color.white.opacity(0.12))
//                                    .clipShape(RoundedRectangle(cornerRadius: 14))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 14)
//                                            .stroke(Color.white.opacity(0.2))
//                                    )
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .padding(.horizontal)
//                        
//                        if let errorMessage {
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                                .font(.footnote)
//                                .padding(.top, 4)
//                        }
//                        
//                        Button {
//                            saveProfile()
//                        } label: {
//                            HStack {
//                                if isSaving {
//                                    ProgressView()
//                                }
//                                Text(isSaving ? "Saving..." : "Save Changes")
//                                    .fontWeight(.semibold)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.purple)
//                            .foregroundColor(.white)
//                            .cornerRadius(16)
//                            .shadow(radius: 6)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 12)
//                        .disabled(isSaving)
//                        
//                        Spacer(minLength: 30)
//                    }
//                }
//            }
//            .navigationBarTitle("Edit Profile", displayMode: .inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Close") {
//                        dismiss()
//                    }
//                    .foregroundColor(.white)
//                }
//            }
//        }
//        .tint(.white)
//    }
//    
//    // MARK: - Reusable TextField
//    private func field(_ title: String, text: Binding<String>) -> some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white.opacity(0.9))
//            TextField(title, text: text)
//                .padding(10)
//                .background(Color.white.opacity(0.12))
//                .clipShape(RoundedRectangle(cornerRadius: 14))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 14)
//                        .stroke(Color.white.opacity(0.2))
//                )
//                .foregroundColor(.white)
//        }
//    }
//    
//    // MARK: - Save Logic
//    private func saveProfile() {
//        guard !profile.id.isEmpty else {
//            errorMessage = "Missing user id."
//            return
//        }
//        
//        isSaving = true
//        errorMessage = nil
//        
//        let body = UpdateProfileBody(
//            userId: profile.id,
//            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
//            interests: interestsText,
//            bio: bio,
//            location: location,
//            profilePhoto: photoURL
//        )
//        
//        NetworkManager.shared.postRequest(
//            endpoint: "/profile/update",
//            body: body
//        ) { (result: Result<UpdateProfileResponse, Error>) in
//            DispatchQueue.main.async {
//                self.isSaving = false
//                switch result {
//                case .success(let response):
//                    // 🔑 response.user is `Profile?` in your project, so unwrap safely
//                    guard let updatedUser = response.user else {
//                        self.errorMessage = "Server did not return an updated profile."
//                        print("⚠️ UpdateProfileResponse.user was nil")
//                        return
//                    }
//                    
//                    self.profile = updatedUser
//                    self.authViewModel.profile = updatedUser
//                    print("✅ Profile updated:", updatedUser.displayName)
//                    self.dismiss()
//                    
//                case .failure(let error):
//                    print("❌ Update profile error:", error.localizedDescription)
//                    self.errorMessage = "Failed to save changes. Please try again."
//                }
//            }
//        }
//    }
//}
//
//  EditProfileView.swift
//  NetSwipe
//
//  Allows the user to edit their profile (name, interests, bio, location, photo)
//  and updates the backend via /profile/update
//

import SwiftUI
import PhotosUI

/// Body sent to POST /profile/update
struct UpdateProfileBody: Codable {
    let userId: String
    let name: String
    let interests: String       // CSV string: "UI/UX, AI, Product"
    let bio: String
    let location: String
    let profilePhoto: String    // base64 string OR existing URL/string
}

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 🔹 Local editable copy of the profile (NON-optional)
    @State private var profile: Profile
    
    @State private var name: String = ""
    @State private var interestsText: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    
    // 🔹 New photo picking state
    @State private var pickedItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    // MARK: - Init
    init(profile: Profile) {
        _profile = State(initialValue: profile)
        _name = State(initialValue: profile.name ?? "")
        _interestsText = State(initialValue: (profile.interests ?? []).joined(separator: ", "))
        _bio = State(initialValue: profile.description ?? "")
        _location = State(initialValue: profile.location ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.0, blue: 0.25),
                        Color(red: 0.5, green: 0.2, blue: 0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Current / New photo preview
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Profile Photo")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            PhotosPicker(selection: $pickedItem, matching: .images) {
                                ZStack {
                                    if let data = pickedImageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                            .shadow(radius: 6)
                                    } else {
                                        // Show current profile image
                                        profile.profileImage()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                            .shadow(radius: 6)
                                    }
                                }
                            }
                            Text("Tap the photo to choose a new one from your gallery.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 24)
                        
                        Group {
                            field("Name", text: $name)
                            field("Interests (comma separated)", text: $interestsText)
                            field("Location", text: $location)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                TextEditor(text: $bio)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.2))
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top, 4)
                        }
                        
                        Button {
                            saveProfile()
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                }
                                Text(isSaving ? "Saving..." : "Save Changes")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 6)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .disabled(isSaving)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .tint(.white)
        // ✅ Load image data when user picks a new photo
        .onChange(of: pickedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.pickedImageData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Reusable TextField
    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            TextField(title, text: text)
                .padding(10)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2))
                )
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Save Logic
    private func saveProfile() {
        guard !profile.id.isEmpty else {
            errorMessage = "Missing user id."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        // 🔹 Use new base64 image if user picked one, otherwise keep existing profile.profilePhoto
        let finalPhotoString: String = {
            if let data = pickedImageData {
                return data.base64EncodedString()
            } else {
                return profile.profilePhoto ?? ""
            }
        }()
        
        let body = UpdateProfileBody(
            userId: profile.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            interests: interestsText,
            bio: bio,
            location: location,
            profilePhoto: finalPhotoString
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/profile/update",
            body: body
        ) { (result: Result<UpdateProfileResponse, Error>) in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success(let response):
                    // 🔑 response.user is `Profile?` in your project, so unwrap safely
                    guard let updatedUser = response.user else {
                        self.errorMessage = "Server did not return an updated profile."
                        print("⚠️ UpdateProfileResponse.user was nil")
                        return
                    }
                    
                    self.profile = updatedUser
                    self.authViewModel.profile = updatedUser
                    print("✅ Profile updated:", updatedUser.displayName)
                    self.dismiss()
                    
                case .failure(let error):
                    print("❌ Update profile error:", error.localizedDescription)
                    self.errorMessage = "Failed to save changes. Please try again."
                }
            }
        }
    }
}
