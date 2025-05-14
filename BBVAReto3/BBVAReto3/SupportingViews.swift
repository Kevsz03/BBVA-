//
//  SupportingViews.swift
//  BBVAReto3
//

import SwiftUI

// MARK: - Header View
struct HeaderView: View {
    let title: String
    var showBackButton: Bool = false
    var backAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Color.bbvaNavyBlue
                .frame(height: 0)
                .edgesIgnoringSafeArea(.top)
            
            HStack {
                if showBackButton {
                    Button(action: {
                        backAction?()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                }
                
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                if showBackButton {
                    // Placeholder to balance layout
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                        .padding(.trailing, 8)
                }
            }
            .padding()
            .background(Color.bbvaNavyBlue)
        }
    }
}
// MARK: - Step Progress View
struct StepProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    let stepTitle: String
    let stepHint: String
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps + 1))
                .progressViewStyle(LinearProgressViewStyle(tint: Color.bbvaCoreBlue))
                .padding(.horizontal)
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Paso \(currentStep + 1) de \(totalSteps + 1)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.bbvaCoreBlue)
                
                Text(stepHint)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    let currentStep: Int
    let totalSteps: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let showPreviousButton: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if showPreviousButton {
                Button(action: onPrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Anterior")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.bbvaCoreBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.bbvaCoreBlue, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            } else {
                Spacer()
            }
            
            Button(action: onNext) {
                Text(currentStep < totalSteps ? "Siguiente" : "Ver resumen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.bbvaCoreBlue)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -3)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

// MARK: - Summary Row Component
struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

// MARK: - Recommendation Card
struct RecommendationCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color.bbvaCoreBlue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(Color.bbvaCoreBlue)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 200, height: 180)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Next Step Row
struct NextStepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.bbvaCoreBlue)
                .cornerRadius(15)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

#Preview("SupportingViews") {
    VStack(spacing: 20) {
        HeaderView(title: "Vista de ejemplo")
        StepProgressView(currentStep: 1, totalSteps: 3, stepTitle: "Ubicación", stepHint: "Dinos dónde está tu negocio")
        SummaryRow(label: "Nombre", value: "Mi Negocio, S.A. de C.V.")
        RecommendationCard(icon: "creditcard.fill", title: "Terminal punto de venta", description: "Acepta pagos con tarjeta con nuestra terminal")
        NextStepRow(number: 1, text: "Completar registro federal")
        Spacer()
        NavigationButtons(currentStep: 1, totalSteps: 3, onPrevious: {}, onNext: {}, showPreviousButton: true)
    }
    .background(Color.white)
}
