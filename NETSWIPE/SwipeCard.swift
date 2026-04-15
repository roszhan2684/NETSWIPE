////
////  SwipeCard.swift
////  NetSwipe
////
//
//import SwiftUI
//import UIKit
//
//struct SwipeCard: View {
//    var profile: Profile
//    var onRemove: () -> Void
//    var onMatch: (Profile) -> Void
//    @Binding var swipeTrigger: SwipeDirection
//
//    @State private var offset: CGSize = .zero
//    @GestureState private var isDragging: Bool = false
//    @State private var showOverlay: Bool = false
//
//    var body: some View {
//        ZStack {
//            // MARK: - Profile Image + Gradient Layer
//            ZStack(alignment: .bottomLeading) {
//                // 1) Local photo data
//                if let imageData = profile.imageData,
//                   let uiImage = UIImage(data: imageData) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                }
//                // 2) Remote photo URL
//                else if let imageUrl = profile.profilePhoto,
//                        let url = URL(string: imageUrl) {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .success(let image):
//                            image.resizable().scaledToFill()
//                        case .failure:
//                            Image("roszhan").resizable().scaledToFill()
//                        default:
//                            ZStack {
//                                Color.black.opacity(0.15)
//                                ProgressView().tint(.white)
//                            }
//                        }
//                    }
//                }
//                // 3) Fallback local asset
//                else {
//                    Image("roszhan")
//                        .resizable()
//                        .scaledToFill()
//                }
//
//                // Gradient overlay
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color.black.opacity(0.9),
//                        Color.black.opacity(0.6),
//                        Color.clear
//                    ]),
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//                .frame(height: 250)
//            }
//            .frame(width: 320, height: 450)
//            .clipped()
//            .cornerRadius(20)
//            .shadow(radius: 8)
//            .offset(offset)
//            .rotationEffect(.degrees(Double(offset.width / 15)))
//            .scaleEffect(isDragging ? 0.97 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: offset)
//
//            // MARK: - Like / Dislike Overlay
//            if showOverlay {
//                overlayIcon
//                    .offset(x: offset.width > 0 ? 80 : -80, y: -140)
//                    .transition(.opacity)
//                    .animation(.easeInOut, value: showOverlay)
//            }
//
//            // MARK: - Text Overlay
//            VStack(alignment: .leading, spacing: 8) {
//                // ✅ Safe for String or String?
//                let rawName: String = (profile.name as Any?) as? String ?? ""
//                Text(rawName.isEmpty ? "Unknown User" : rawName)
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//                    .shadow(radius: 3)
//
//                if let desc = profile.description, !desc.isEmpty {
//                    Text(desc)
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.9))
//                        .lineLimit(2)
//                } else {
//                    Text("No description")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.6))
//                        .italic()
//                }
//
//                if let interests = profile.interests, !interests.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 6) {
//                            ForEach(interests, id: \.self) { interest in
//                                Text(interest)
//                                    .font(.caption)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 5)
//                                    .background(Color.white.opacity(0.25))
//                                    .cornerRadius(8)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .padding(.top, 4)
//                }
//            }
//            .padding(.horizontal, 18)
//            .padding(.bottom, 20)
//            .frame(width: 320, height: 450, alignment: .bottomLeading)
//        }
//        .contentShape(Rectangle())
//        .gesture(
//            DragGesture()
//                .updating($isDragging) { _, state, _ in state = true }
//                .onChanged { gesture in
//                    offset = gesture.translation
//                    showOverlay = abs(offset.width) > 40
//                }
//                .onEnded { gesture in
//                    let threshold: CGFloat = 100
//                    if abs(gesture.translation.width) > threshold {
//                        animateOut(toRight: gesture.translation.width > 0)
//                    } else {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
//                            offset = .zero
//                            showOverlay = false
//                        }
//                    }
//                }
//        )
//        .onChange(of: swipeTrigger) { _, newValue in
//            guard newValue != .none else { return }
//            animateOut(toRight: newValue == .right)
//        }
//    }
//
//    // MARK: - Overlay Icons
//    private var overlayIcon: some View {
//        Group {
//            if offset.width > 0 {
//                Image(systemName: "heart.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.green.opacity(0.85))
//                    .shadow(color: .green.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(-15))
//                    .scaleEffect(1.05)
//            } else {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.red.opacity(0.85))
//                    .shadow(color: .red.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(15))
//                    .scaleEffect(1.05)
//            }
//        }
//        .animation(.easeInOut(duration: 0.2), value: offset)
//    }
//
//    // MARK: - Swipe Animation
//    private func animateOut(toRight: Bool) {
//        let target = CGSize(width: toRight ? 1000 : -1000, height: 0)
//        withAnimation(.easeIn(duration: 0.25)) {
//            offset = target
//            showOverlay = true
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            if toRight { onMatch(profile) }
//            onRemove()
//            offset = .zero
//            showOverlay = false
//            swipeTrigger = .none
//        }
//    }
//}
//
//#Preview {
//    SwipeCard(
//        profile: sampleProfiles.first!,
//        onRemove: {},
//        onMatch: { _ in },
//        swipeTrigger: .constant(.none)
//    )
//}
//
//
////  SwipeCard.swift
////  NetSwipe
////
//
//import SwiftUI
//import UIKit
//
//struct SwipeCard: View {
//    var profile: Profile
//    var onRemove: () -> Void
//    var onMatch: (Profile) -> Void
//    @Binding var swipeTrigger: SwipeDirection
//
//    /// Only the top card should be draggable. For others, this will be false.
//    var canDrag: Bool = true
//
//    @State private var offset: CGSize = .zero
//    @GestureState private var isDragging: Bool = false
//    @State private var showOverlay: Bool = false
//
//    var body: some View {
//        ZStack {
//            // MARK: - Card Background (Image + Gradient)
//            ZStack(alignment: .bottomLeading) {
//                // ✅ Use centralized image loader from ProfileModel
//                profile.profileImage()
//                    .frame(width: 320, height: 450)
//                    .clipped()
//
//                // Bottom gradient for text readability
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color.black.opacity(0.95),
//                        Color.black.opacity(0.6),
//                        Color.clear
//                    ]),
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//                .frame(height: 250)
//            }
//            .frame(width: 320, height: 450)
//            .clipped()
//            .cornerRadius(20)
//            .shadow(radius: 10)
//
//            // MARK: - Like / Dislike Overlay Icon
//            if showOverlay {
//                overlayIcon
//                    .offset(x: offset.width > 0 ? 80 : -80, y: -140)
//                    .transition(.opacity)
//            }
//
//            // MARK: - Text Overlay
//            VStack(alignment: .leading, spacing: 8) {
//                let rawName: String = (profile.name as Any?) as? String ?? ""
//                Text(rawName.isEmpty ? "Unknown User" : rawName)
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//                    .shadow(radius: 4)
//
//                if let desc = profile.description, !desc.isEmpty {
//                    Text(desc)
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.9))
//                        .lineLimit(2)
//                } else {
//                    Text("No description")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.6))
//                        .italic()
//                }
//
//                if let interests = profile.interests, !interests.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 6) {
//                            ForEach(interests, id: \.self) { interest in
//                                Text(interest)
//                                    .font(.caption)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 5)
//                                    .background(Color.white.opacity(0.25))
//                                    .cornerRadius(8)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .padding(.top, 4)
//                }
//            }
//            .padding(.horizontal, 18)
//            .padding(.bottom, 20)
//            .frame(width: 320, height: 450, alignment: .bottomLeading)
//        }
//        .frame(width: 320, height: 450)
//        // 🔹 Move the *entire* card together
//        .offset(offset)
//        .rotationEffect(.degrees(Double(offset.width / 18))) // subtle tilt
//        .scaleEffect(isDragging ? 0.97 : 1.0)
//        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: offset)
//        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isDragging)
//        .contentShape(Rectangle())
//        .gesture(
//            DragGesture()
//                .updating($isDragging) { _, state, _ in
//                    if canDrag {
//                        state = true
//                    }
//                }
//                .onChanged { gesture in
//                    guard canDrag else { return }
//                    offset = gesture.translation
//                    showOverlay = abs(offset.width) > 40
//                }
//                .onEnded { gesture in
//                    guard canDrag else {
//                        // Non-top cards should not move at all
//                        offset = .zero
//                        showOverlay = false
//                        return
//                    }
//
//                    let threshold: CGFloat = 120
//                    if abs(gesture.translation.width) > threshold {
//                        animateOut(toRight: gesture.translation.width > 0)
//                    } else {
//                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
//                            offset = .zero
//                            showOverlay = false
//                        }
//                    }
//                }
//        )
//        // 🔹 Respond to heart / X buttons for the TOP card only
//        .onChange(of: swipeTrigger) { newValue in
//            guard canDrag, newValue != .none else { return }
//            animateOut(toRight: newValue == .right)
//        }
//    }
//
//    // MARK: - Overlay Icons
//    private var overlayIcon: some View {
//        Group {
//            if offset.width > 0 {
//                Image(systemName: "heart.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.green.opacity(0.9))
//                    .shadow(color: .green.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(-15))
//                    .scaleEffect(1.05)
//            } else {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.red.opacity(0.9))
//                    .shadow(color: .red.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(15))
//                    .scaleEffect(1.05)
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: offset)
//    }
//
//    // MARK: - Swipe Animation
//    private func animateOut(toRight: Bool) {
//        let target = CGSize(width: toRight ? 1000 : -1000, height: 0)
//
//        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//            offset = target
//            showOverlay = true
//        }
//
//        // After the card flies out, notify & reset
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            if toRight {
//                onMatch(profile)
//            }
//            onRemove()
//            offset = .zero
//            showOverlay = false
//            swipeTrigger = .none
//        }
//    }
//}
//
//#Preview {
//    SwipeCard(
//        profile: sampleProfiles.first!,
//        onRemove: {},
//        onMatch: { _ in },
//        swipeTrigger: .constant(.none),
//        canDrag: true
//    )
//}
//
////  SwipeCard.swift
////  NetSwipe
////
//
//import SwiftUI
//import UIKit
//
//struct SwipeCard: View {
//    var profile: Profile
//    var onRemove: () -> Void
//    var onMatch: (Profile) -> Void
//    @Binding var swipeTrigger: SwipeDirection
//
//    /// Only the top card should be draggable. For others, this will be false.
//    var canDrag: Bool = true
//
//    @State private var offset: CGSize = .zero
//    @GestureState private var isDragging: Bool = false
//    @State private var showOverlay: Bool = false
//
//    var body: some View {
//        ZStack {
//            // MARK: - Card Background (Image + Gradient)
//            ZStack(alignment: .bottomLeading) {
//                // ✅ Centralized image loader (handles Data, base64, or URL)
//                profile.profileImage()
//                    .frame(width: 320, height: 450)
//                    .clipped()
//
//                // Bottom gradient for text readability
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color.black.opacity(0.95),
//                        Color.black.opacity(0.6),
//                        Color.clear
//                    ]),
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//                .frame(height: 250)
//            }
//            .frame(width: 320, height: 450)
//            .clipped()
//            .cornerRadius(20)
//            .shadow(radius: 10)
//
//            // MARK: - Like / Dislike Overlay Icon
//            if showOverlay {
//                overlayIcon
//                    .offset(x: offset.width > 0 ? 80 : -80, y: -140)
//                    .transition(.opacity)
//            }
//
//            // MARK: - Text Overlay
//            VStack(alignment: .leading, spacing: 8) {
//                let displayName = profile.displayName
//                Text(displayName.isEmpty ? "Unknown User" : displayName)
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//                    .shadow(radius: 4)
//
//                if let desc = profile.description, !desc.isEmpty {
//                    Text(desc)
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.9))
//                        .lineLimit(2)
//                } else {
//                    Text("No description")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.6))
//                        .italic()
//                }
//
//                if let interests = profile.interests, !interests.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 6) {
//                            ForEach(interests, id: \.self) { interest in
//                                Text(interest)
//                                    .font(.caption)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 5)
//                                    .background(Color.white.opacity(0.25))
//                                    .cornerRadius(8)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .padding(.top, 4)
//                }
//            }
//            .padding(.horizontal, 18)
//            .padding(.bottom, 20)
//            .frame(width: 320, height: 450, alignment: .bottomLeading)
//        }
//        .frame(width: 320, height: 450)
//        // 🔹 Move the *entire* card together
//        .offset(offset)
//        .rotationEffect(.degrees(Double(offset.width / 18))) // subtle tilt
//        .scaleEffect(isDragging ? 0.97 : 1.0)
//        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: offset)
//        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isDragging)
//        .contentShape(Rectangle())
//        .gesture(
//            DragGesture()
//                .updating($isDragging) { _, state, _ in
//                    if canDrag {
//                        state = true
//                    }
//                }
//                .onChanged { gesture in
//                    guard canDrag else { return }
//                    offset = gesture.translation
//                    showOverlay = abs(offset.width) > 40
//                }
//                .onEnded { gesture in
//                    guard canDrag else {
//                        // Non-top cards should not move at all
//                        offset = .zero
//                        showOverlay = false
//                        return
//                    }
//
//                    let threshold: CGFloat = 120
//                    if abs(gesture.translation.width) > threshold {
//                        animateOut(toRight: gesture.translation.width > 0)
//                    } else {
//                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
//                            offset = .zero
//                            showOverlay = false
//                        }
//                    }
//                }
//        )
//        // 🔹 Respond to heart / X buttons for the TOP card only
//        .onChange(of: swipeTrigger) { newValue in
//            guard canDrag, newValue != .none else { return }
//            animateOut(toRight: newValue == .right)
//        }
//    }
//
//    // MARK: - Overlay Icons
//    private var overlayIcon: some View {
//        Group {
//            if offset.width > 0 {
//                Image(systemName: "heart.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.green.opacity(0.9))
//                    .shadow(color: .green.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(-15))
//                    .scaleEffect(1.05)
//            } else {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 80))
//                    .foregroundColor(.red.opacity(0.9))
//                    .shadow(color: .red.opacity(0.6), radius: 6)
//                    .rotationEffect(.degrees(15))
//                    .scaleEffect(1.05)
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: offset)
//    }
//
//    // MARK: - Swipe Animation
//    private func animateOut(toRight: Bool) {
//        let target = CGSize(width: toRight ? 1000 : -1000, height: 0)
//
//        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//            offset = target
//            showOverlay = true
//        }
//
//        // After the card flies out, notify & reset
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            if toRight {
//                onMatch(profile)
//            }
//            onRemove()
//            offset = .zero
//            showOverlay = false
//            swipeTrigger = .none
//        }
//    }
//}
//
//#Preview {
//    SwipeCard(
//        profile: sampleProfiles.first!,
//        onRemove: {},
//        onMatch: { _ in },
//        swipeTrigger: .constant(.none),
//        canDrag: true
//    )
//}
//
//
//  SwipeCard.swift
//  NetSwipe
//

import SwiftUI
import UIKit

struct SwipeCard: View {
    var profile: Profile
    var onRemove: () -> Void
    var onMatch: (Profile) -> Void
    @Binding var swipeTrigger: SwipeDirection

    /// Only the top card should be draggable. For others, this will be false.
    var canDrag: Bool = true

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging: Bool = false
    @State private var showOverlay: Bool = false

    var body: some View {
        GeometryReader { geo in
            // Make card almost full width, with a nice aspect ratio
            let cardWidth  = min(geo.size.width * 0.9, 380)
            let cardHeight = cardWidth * 1.4

            ZStack {
                // MARK: - Card Background (Full-bleed Image + Gradient)
                ZStack(alignment: .bottomLeading) {
                    cardImage(width: cardWidth, height: cardHeight)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                        .contentShape(Rectangle())

                    // Bottom gradient for text readability
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.95),
                            Color.black.opacity(0.6),
                            Color.clear
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: cardHeight * 0.45)
                }
                .frame(width: cardWidth, height: cardHeight)
                .cornerRadius(22)
                .shadow(radius: 12)

                // MARK: - Like / Dislike Overlay Icon
                if showOverlay {
                    overlayIcon
                        .offset(x: offset.width > 0 ? 90 : -90, y: -cardHeight * 0.28)
                        .transition(.opacity)
                }

                // MARK: - Text Overlay
                VStack(alignment: .leading, spacing: 8) {
                    let rawName: String = (profile.name as Any?) as? String ?? ""
                    Text(rawName.isEmpty ? "Unknown User" : rawName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 4)

                    if let desc = profile.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    } else {
                        Text("No description")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                    }

                    if let interests = profile.interests, !interests.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
                .frame(width: cardWidth, height: cardHeight, alignment: .bottomLeading)
            }
            .frame(width: cardWidth, height: cardHeight)
            // 🔹 Move the *entire* card together
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 18))) // subtle tilt
            .scaleEffect(isDragging ? 0.97 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: offset)
            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isDragging)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        if canDrag {
                            state = true
                        }
                    }
                    .onChanged { gesture in
                        guard canDrag else { return }
                        offset = gesture.translation
                        showOverlay = abs(offset.width) > 40
                    }
                    .onEnded { gesture in
                        guard canDrag else {
                            offset = .zero
                            showOverlay = false
                            return
                        }

                        let threshold: CGFloat = 120
                        if abs(gesture.translation.width) > threshold {
                            animateOut(toRight: gesture.translation.width > 0)
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                offset = .zero
                                showOverlay = false
                            }
                        }
                    }
            )
            // 🔹 Respond to heart / X buttons for the TOP card only
            .onChange(of: swipeTrigger) { newValue in
                guard canDrag, newValue != .none else { return }
                animateOut(toRight: newValue == .right)
            }
        }
        // Give GeometryReader some height to work with
        .frame(height: 520)
    }

    // MARK: - Overlay Icons
    private var overlayIcon: some View {
        Group {
            if offset.width > 0 {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green.opacity(0.9))
                    .shadow(color: .green.opacity(0.6), radius: 6)
                    .rotationEffect(.degrees(-15))
                    .scaleEffect(1.05)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red.opacity(0.9))
                    .shadow(color: .red.opacity(0.6), radius: 6)
                    .rotationEffect(.degrees(15))
                    .scaleEffect(1.05)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: offset)
    }

    // MARK: - Swipe Animation
    private func animateOut(toRight: Bool) {
        let target = CGSize(width: toRight ? 1000 : -1000, height: 0)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            offset = target
            showOverlay = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if toRight {
                onMatch(profile)
            }
            onRemove()
            offset = .zero
            showOverlay = false
            swipeTrigger = .none
        }
    }
}

// MARK: - Image helpers
private extension SwipeCard {

    @ViewBuilder
    func cardImage(width: CGFloat, height: CGFloat) -> some View {
        // 1) Direct imageData if present
        if let data = profile.imageData,
           let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()

        // 2) Base64 in profilePhoto
        } else if let photo = profile.profilePhoto,
                  let base64 = decodeBase64Image(photo) {
            Image(uiImage: base64)
                .resizable()
                .scaledToFill()

        // 3) URL or relative path
        } else if let photo = profile.profilePhoto,
                  let url = normalizedPhotoURL(photo) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure(_):
                    placeholderCardBackground
                default:
                    ZStack {
                        placeholderCardBackground
                        ProgressView()
                    }
                }
            }

        // 4) Local asset name (either in localImageName or profilePhoto string)
        } else if let assetName = localAssetName() {
            if let ui = UIImage(named: assetName) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderCardBackground
            }

        // 5) Fallback gradient background
        } else {
            placeholderCardBackground
        }
    }

    var placeholderCardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.9),
                Color.black
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func localAssetName() -> String? {
        if let name = profile.localImageName, !name.isEmpty {
            return name
        }

        if let photo = profile.profilePhoto {
            let trimmed = photo.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty,
               !trimmed.lowercased().hasPrefix("http"),
               !trimmed.contains("/") {
                return trimmed
            }
        }
        return nil
    }

    func decodeBase64Image(_ input: String) -> UIImage? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let base64String: String
        if let range = trimmed.range(of: "base64,") {
            base64String = String(trimmed[range.upperBound...])
        } else {
            base64String = trimmed
        }

        guard let data = Data(base64Encoded: base64String),
              let img = UIImage(data: data) else {
            return nil
        }
        return img
    }

    func normalizedPhotoURL(_ input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Already a full URL
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return URL(string: trimmed)
        }

        // Treat as relative path on backend
        let serverBase = "http://192.168.1.23:5001"
        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
        return URL(string: fixed)
    }
}

// MARK: - Preview
#Preview {
    SwipeCard(
        profile: sampleProfiles.first!,
        onRemove: {},
        onMatch: { _ in },
        swipeTrigger: .constant(.none),
        canDrag: true
    )
}
