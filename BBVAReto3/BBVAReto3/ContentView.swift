//
//  ContentView.swift
//  BBVAReto3
//
//  Created by CEDAM21 on 13/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreen()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else {
                HomeView()
            }
        }
    }
}

// Simple Home view placeholder
struct HomeView: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                HStack {
                    Spacer()
                    Text("Cuentas")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.bbvaNavyBlue)
                .edgesIgnoringSafeArea(.top)
                
                // Account card example
                VStack(alignment: .leading) {
                    Text("0001AH2248")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("•2248")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("$2,152.08")
                            .font(.system(size: 28, weight: .medium))
                        Spacer()
                    }
                    
                    Text("Saldo disponible")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        Text("Ver cuenta y CLABE")
                            .foregroundColor(.bbvaCoreBlue)
                            .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 2)
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
