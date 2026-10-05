//
//  Splashview.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//

import SwiftUI

struct SplashView: View {
    
    @State private var progress: CGFloat = 0
    @State private var finishedLoading = false
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false
    
    var body: some View {
        VStack{
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.15), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: progress * 0.89)
                    .stroke(.black, style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))

                Text("84")
                    .font(.system(size: 77, weight: .bold))
            }
            .frame(width: 180, height: 180)
            
            .padding()
            
            Text("Progress loading...")
                .font(.system(size: 20, weight: .medium))
                .italic()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 0.95
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                finishedLoading = true
            }
        }
        .fullScreenCover(isPresented: $finishedLoading) {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                WelcomeView()
            }
        }
            }
        }
  


#Preview {
    SplashView()
}
