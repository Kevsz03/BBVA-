//
//  BusinessInfoView.swift
//  BBVAReto3
//

import SwiftUI
import Combine

struct BusinessInfoView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case businessName
        case businessOwner
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // BBVA Header
                HeaderView(title: viewModel.stepTitle)
                
                // Progress indicator
                StepProgressView(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps,
                    stepTitle: viewModel.stepTitle,
                    stepHint: viewModel.stepHint
                )
                
                // Business Info Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Business name card
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Nombre de tu empresa")
                                    .font(.headline)
                                    .foregroundColor(Color.bbvaCoreBlue)
                            } icon: {
                                Image(systemName: "building.2")
                                    .foregroundColor(Color.bbvaCoreBlue)
                            }
                            
                            TextField("Ej: Cafetería El Rincón", text: $viewModel.businessName)
                                .focused($focusedField, equals: .businessName)
                                .font(.system(size: 16))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .background(Color.white)
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // Business owner card
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Propietario del negocio")
                                    .font(.headline)
                                    .foregroundColor(Color.bbvaCoreBlue)
                            } icon: {
                                Image(systemName: "person")
                                    .foregroundColor(Color.bbvaCoreBlue)
                            }
                            
                            TextField("Ej: Juan Pérez López", text: $viewModel.businessOwner)
                                .focused($focusedField, equals: .businessOwner)
                                .font(.system(size: 16))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .background(Color.white)
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        Spacer(minLength: 80)
                    }
                    .padding()
                }
                
                // Bottom navigation
                NavigationButtons(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps,
                    onPrevious: { viewModel.goToPreviousStep() },
                    onNext: { viewModel.goToNextStep() },
                    showPreviousButton: viewModel.currentStep > 0
                )
            }
        }
    }
}

#Preview("Pantalla 1: Información del Negocio") {
    BusinessInfoView(viewModel: RegistrationViewModel())
}
