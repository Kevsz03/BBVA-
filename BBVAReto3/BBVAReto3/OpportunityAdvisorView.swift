//
//  OpportunityAdvisorView.swift
//  BBVAReto3
//

import SwiftUI
import MapKit

struct OpportunityAdvisorView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    // Coordenadas del centro de CDMX (Zócalo)
    private let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Datos simulados de recomendaciones
    private let recommendations = [
        Recommendation(
            title: "¡Ubicación favorable!",
            description: "Esta zona tiene alto tráfico peatonal y comercial",
            icon: "checkmark.circle.fill",
            color: .green
        ),
        Recommendation(
            title: "Competencia moderada",
            description: "Hay 3 negocios similares en un radio de 1km",
            icon: "exclamationmark.triangle.fill",
            color: .orange
        ),
        Recommendation(
            title: "Alto potencial",
            description: "El poder adquisitivo de la zona es superior al promedio",
            icon: "star.fill",
            color: .yellow
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // BBVA Header
            HeaderView(title: viewModel.stepTitle)
            
            // Progress indicator
            StepProgressView(
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.totalSteps,
                stepTitle: "Análisis de Oportunidad",
                stepHint: "Analicemos el potencial de tu ubicación"
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Mapa de calor
                    ZStack {
                        Map(coordinateRegion: .constant(initialRegion))
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Overlay simulando mapa de calor
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .blur(radius: 20)
                    }
                    .padding(.horizontal)
                    
                    // Indicadores de potencial
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Indicadores de la zona")
                            .font(.headline)
                            .foregroundColor(.bbvaCoreBlue)
                            .padding(.horizontal)
                        
                        ForEach(recommendations) { recommendation in
                            RecommendationCardOA(recommendation: recommendation)
                        }
                    }
                    
                    // Resumen del análisis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen del análisis")
                            .font(.headline)
                            .foregroundColor(.bbvaCoreBlue)
                        
                        Text("Basado en nuestro análisis, esta ubicación tiene un potencial alto para tu tipo de negocio. Te recomendamos:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        BulletPointView(text: "Considera horarios extendidos por el alto tráfico nocturno")
                        BulletPointView(text: "Enfócate en diferenciarte de la competencia cercana")
                        BulletPointView(text: "Aprovecha el alto poder adquisitivo con productos premium")
                    }
                    .padding()
                    .background(Color.bbvaNavyBlue.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Bottom navigation
            NavigationButtons(
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.totalSteps,
                onPrevious: viewModel.goToPreviousStep,
                onNext: viewModel.goToNextStep,
                showPreviousButton: viewModel.currentStep > 0
            )
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Supporting Views and Models
struct Recommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct RecommendationCardOA: View {
    let recommendation: Recommendation
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: recommendation.icon)
                .font(.title2)
                .foregroundColor(recommendation.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct BulletPointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.headline)
                .foregroundColor(.bbvaCoreBlue)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview("Asesor de Oportunidades") {
    OpportunityAdvisorView(viewModel: {
        let vm = RegistrationViewModel()
        vm.currentStep = 3
        return vm
    }())
}
