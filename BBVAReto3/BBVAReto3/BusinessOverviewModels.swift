//
//  BusinessOverviewModels.swift
//  BBVAReto3
//
//  Created by CEDAM21 on 13/05/25.
//

import Foundation
import SwiftUI

struct KeyMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: Double // Porcentaje de cambio
    let icon: String
}

struct RecommendationBO: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: RecommendationType
    let action: String
}

enum RecommendationType {
    case inventory
    case sales
    case financial
    case motivation
    
    var icon: String {
        switch self {
        case .inventory: return "box.truck.fill"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .financial: return "dollarsign.circle.fill"
        case .motivation: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .inventory: return .orange
        case .sales: return .green
        case .financial: return .bbvaCoreBlue
        case .motivation: return .yellow
        }
    }
}

struct FinancialStatus {
    let balance: Double
    let pendingPayments: Double
    let todayEarnings: Double
    let weeklyEarnings: Double
}
