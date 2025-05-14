//
//  AppCoordinator.swift
//  BBVAReto3
//

import SwiftUI

struct AppCoordinator: View {
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreen()
                    .transition(.opacity)
            } else {
                RegistrationCoordinator()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Programar el cambio de vista después de 2.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

#Preview {
    AppCoordinator()
}
