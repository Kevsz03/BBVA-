//
//  LocationView.swift
//  BBVAReto3
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @FocusState private var focusedField: Bool
    
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
                
                // Location Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Address field
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Dirección del negocio")
                                    .font(.headline)
                                    .foregroundColor(Color.bbvaCoreBlue)
                            } icon: {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(Color.bbvaCoreBlue)
                            }
                            
                            TextField("Ej: Av. Reforma 123, Col. Juárez", text: $viewModel.businessAddress)
                                .focused($focusedField)
                                .font(.system(size: 16))
                                .disabled(true)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .background(Color.gray.opacity(0.05))
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // Map selection buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                viewModel.isMapViewPresented = true
                            }) {
                                HStack {
                                    Image(systemName: "map")
                                        .font(.system(size: 20))
                                    Text("Ver dirección en mapa")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.bbvaCoreBlue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.requestLocationPermission()
                            }) {
                                HStack {
                                    Image(systemName: "location")
                                        .font(.system(size: 20))
                                    Text("Estoy en mi negocio")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.bbvaCoreBlue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.bbvaCoreBlue, lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 8)
                        
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
        .fullScreenCover(isPresented: $viewModel.isMapViewPresented) {
            SimplifiedMapView(
                address: $viewModel.businessAddress,
                isPresented: $viewModel.isMapViewPresented
            )
        }
        .alert("Permiso de ubicación", isPresented: $viewModel.isShowingLocationPermissionAlert) {
            Button("Abrir Ajustes", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para usar tu ubicación actual, necesitamos permiso para acceder a la ubicación de tu dispositivo.")
        }
    }
}

#Preview("Pantalla 2: Ubicación") {
    LocationView(viewModel: {
        let vm = RegistrationViewModel()
        vm.currentStep = 1
        return vm
    }())
}
