//
//  SplashScreen.swift
//  BBVAReto3
//

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Fondo
            Color(red: 0.027, green: 0.129, blue: 0.275) // BBVA Navy Blue #072146
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Logo
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.5)
                
                // Nombre de la aplicación
                Text("BBVA")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Eslogan
                Text("Contigo")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 0.357, green: 0.745, blue: 1.0)) // BBVA Sky Blue #5BBEFF
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer().frame(height: 50)
                
                // Spinner
                if isAnimating {
                    LoadingSpinner(isAnimating: .constant(true))
                        .frame(width: 40, height: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                isAnimating = true
            }
        }
    }
}

struct LoadingSpinner: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.357, green: 0.745, blue: 1.0).opacity(0.3), lineWidth: 3)
                .frame(width: 36, height: 36)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 36, height: 36)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
    }
}

#Preview {
    SplashScreen()
}
