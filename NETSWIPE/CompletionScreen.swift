////
////  CompletionScreen.swift
////  Demo cpsc 411
////
////  Created by ROSZHAN RAJ on 05/09/25.
////
////
//import SwiftUI
//struct CompletionScreen: View {
//    let restartAction: () -> Void
//    var body: some View {
//        VStack(spacing: 24) {
//            Spacer()
//            Text("More Profiles Coming Soon")
//                .font(.title2)
//                .multilineTextAlignment(.center)
//                .padding()
//            Button(action: restartAction) {
//                Text("Restart Swiping")
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 220)
//                    .background(Color.black)
//                    .cornerRadius(12)
//            }
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//  CompletionScreen.swift
//  NetSwipe
//
//  Simple end-of-deck screen with an option to restart swiping.
//

import SwiftUI

struct CompletionScreen: View {
    let restartAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("More Profiles Coming Soon")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: restartAction) {
                Text("Restart Swiping")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220)
                    .background(Color.black)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}
