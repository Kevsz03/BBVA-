//
//  RegistrationCoordinator.swift
//  BBVAReto3
//

import SwiftUI

struct RegistrationCoordinator: View {
    @StateObject private var viewModel = RegistrationViewModel()
    
    var body: some View {
        ZStack {
            // Mostrar la vista correspondiente según el paso actual
            if viewModel.showSummary {
                BusinessSummaryView(viewModel: viewModel)
            } else {
                switch viewModel.currentStep {
                case 0:
                    BusinessInfoView(viewModel: viewModel)
                case 1:
                    LocationView(viewModel: viewModel)
                case 2:
                    FinanceView(viewModel: viewModel)
                case 3:
                    OpportunityAdvisorView(viewModel: viewModel)
                default:
                    BusinessInfoView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview("Coordinador de Registro") {
    RegistrationCoordinator()
}
