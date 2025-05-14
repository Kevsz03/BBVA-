//
//  BusinessSummaryView.swift
//  BBVAReto3
//

import SwiftUI

struct BusinessSummaryView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con animación de éxito
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("¡Registro completado!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Resumen de la información de tu negocio")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)
                    
                    // Información del negocio
                    SummaryCard(
                        title: "Información General",
                        icon: "building.2.fill",
                        content: [
                            ("Nombre del negocio", viewModel.businessName),
                            ("Propietario", viewModel.businessOwner)
                        ]
                    )
                    
                    // Dirección
                    SummaryCard(
                        title: "Ubicación",
                        icon: "location.fill",
                        content: [
                            ("Dirección", viewModel.businessAddress)
                        ]
                    )
                    
                    // Ingresos
                    SummaryCard(
                        title: "Finanzas",
                        icon: "dollarsign.circle.fill",
                        content: [
                            ("Ingresos estimados", viewModel.estimatedMonthlyIncome)
                        ]
                    )
                    
                    // Siguiente paso para RFC
                    VStack(spacing: 16) {
                        Text("Siguiente paso: SAT")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Para completar tu registro como cliente MiPyME, necesitamos tu información fiscal. ¿Ya cuentas con RFC como Persona Física con Actividad Empresarial?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button {
                            viewModel.showSATDocumentation = true
                        } label: {
                            Text("Comenzar trámite de RFC")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.bbvaCoreBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Botón para finalizar
                    Button {
                        dismiss()
                    } label: {
                        Text("Volver al inicio")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.bbvaCoreBlueLight)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Resumen de Registro")
                        .font(.headline)
                        .foregroundColor(.bbvaCoreBlue)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showSATDocumentation) {
                SATDocumentationView(viewModel: viewModel)
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let icon: String
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.bbvaCoreBlue)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.bbvaCoreBlue)
            }
            
            Divider()
            
            ForEach(content, id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(item.1)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview("Business Summary") {
    BusinessSummaryView(viewModel: {
        let vm = RegistrationViewModel()
        vm.businessName = "Café Especial Lomas"
        vm.businessOwner = "Juan Pérez"
        vm.businessAddress = "Av. Reforma 222, Col. Juárez, CDMX, C.P. 06600"
        vm.estimatedMonthlyIncome = "$45,000.00"
        return vm
    }())
}
