//
//  FinanceView.swift
//  BBVAReto3
//

import SwiftUI
import Combine

struct FinanceView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @FocusState private var focusedField: Bool
    
    // Extraer componentes estáticos a vistas separadas
    private let infoText = "Tu información financiera nos permite ofrecerte productos específicos para tu tipo de negocio y nivel de ingresos, como líneas de crédito, tarjetas empresariales con beneficios especiales o cuentas sin comisiones."
    
    var body: some View {
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
            
            // Finance Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Income estimation card
                    VStack(alignment: .leading, spacing: 12) {
                        Label(
                            title: { Text("Ingresos mensuales estimados")
                                .font(.headline)
                                .foregroundColor(.bbvaCoreBlue) },
                            icon: { Image(systemName: "dollarsign.circle")
                                .foregroundColor(.bbvaCoreBlue) }
                        )
                        
                        TextField("$0.00", text: $viewModel.estimatedMonthlyIncome)
                            .focused($focusedField)
                            .font(.system(size: 16))
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.estimatedMonthlyIncome) { newValue in
                                viewModel.estimatedMonthlyIncome = viewModel.formatCurrency(string: newValue)
                            }
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
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    
                    // Information card
                    InfoCard(text: infoText)
                    
                    Spacer(minLength: 80)
                }
                .padding()
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

// MARK: - Subcomponents
private struct InfoCard: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.bbvaCoreBlue)
                
                Text("¿Por qué necesitamos esta información?")
                    .font(.headline)
                    .foregroundColor(.bbvaCoreBlue)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.bbvaNavyBlue.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview("Pantalla 3: Finanzas") {
    FinanceView(viewModel: {
        let vm = RegistrationViewModel()
        vm.currentStep = 2
        return vm
    }())
}
