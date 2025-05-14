import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BusinessOverviewView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Resumen")
                }
                .tag(0)
            
            Text("Ventas") // Placeholder
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Ventas")
                }
                .tag(1)
            
            Text("Productos") // Placeholder
                .tabItem {
                    Image(systemName: "box.fill")
                    Text("Productos")
                }
                .tag(2)
            
            Text("Finanzas") // Placeholder
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Finanzas")
                }
                .tag(3)
        }
        .tint(.white)
        .onAppear {
            // Configurar el estilo del TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.bbvaCoreBlue)
            
            // Ajustar los elementos del TabBar
            appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.6)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            // Ajustar la posición del texto e iconos
            let offset = UIOffset(horizontal: 0, vertical: 0) // Mover elementos hacia abajo
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = offset
            appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = offset
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Minimizar el espacio del TabBar
            UITabBar.appearance().frame.size.height = 30 // Altura estándar del TabBar
        }
    }
}

enum TimeFrame {
    case day, week, month
    
    var title: String {
        switch self {
        case .day: return "Hoy"
        case .week: return "Esta semana"
        case .month: return "Este mes"
        }
    }
}

struct BusinessOverviewView: View {
    @StateObject private var viewModel = BusinessOverviewViewModel()
    @State private var showRecommendations = false
    @State private var showFinancialDetails = false
    @State private var selectedTimeFrame = TimeFrame.day
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Color.bbvaNavyBlue
                        .frame(height: 0)
                        .ignoresSafeArea(edges: .top)
                    
                    HeaderView(title: "Resumen")
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Selector de período
                            Picker("Período", selection: $selectedTimeFrame) {
                                Text("Hoy").tag(TimeFrame.day)
                                Text("Semana").tag(TimeFrame.week)
                                Text("Mes").tag(TimeFrame.month)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            // Gráfico de ventas
                            DailySalesChart(salesData: viewModel.dailySales)
                                .padding(.horizontal)
                            
                            // KPIs principales
                            KeyMetricsGrid(metrics: viewModel.keyMetrics)
                                .padding(.horizontal)
                            
                            // Botones de acceso rápido
                            VStack(spacing: 16) {
                                QuickActionButton(
                                    title: "Ver recomendaciones",
                                    icon: "lightbulb.fill",
                                    color: .orange
                                ) {
                                    showRecommendations = true
                                }
                                
                                QuickActionButton(
                                    title: "Estado financiero",
                                    icon: "dollarsign.circle.fill",
                                    color: .bbvaCoreBlue
                                ) {
                                    showFinancialDetails = true
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .sheet(isPresented: $showRecommendations) {
                RecommendationsView(recommendations: viewModel.recommendations)
            }
            .sheet(isPresented: $showFinancialDetails) {
                FinancialDetailsView(status: viewModel.financialStatus)
            }
        }
    }
}

struct RecommendationsView: View {
    let recommendations: [RecommendationBO]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(title: "Recomendaciones")
                    .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Mensaje principal
                        VStack(spacing: 8) {
                            Text("Insights personalizados")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.bbvaCoreBlue)
                            
                            Text("Basados en el análisis de tu negocio")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        
                        // Recomendaciones
                        ForEach(recommendations) { recommendation in
                            RecommendationBOCard(recommendation: recommendation)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.gray.opacity(0.05))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct FinancialDetailsView: View {
    let status: FinancialStatus
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header BBVA
                    HeaderView(title: "Estado Financiero")
                    
                    VStack(spacing: 24) {
                        // Balance principal
                        VStack(spacing: 8) {
                            Text("Balance actual")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("$\(status.balance, specifier: "%.2f")")
                                .font(.system(size: 42, weight: .medium))
                                .foregroundColor(.bbvaCoreBlue)
                        }
                        .padding(.top, 32)
                        
                        // Selector de período
                        Picker("Período", selection: $selectedPeriod) {
                            Text("Hoy").tag(0)
                            Text("Semana").tag(1)
                            Text("Mes").tag(2)
                        }
                        .pickerStyle(.segmented)
                        
                        // Tarjetas de métricas
                        VStack(spacing: 16) {
                            FinancialMetricCard(
                                title: "Ingresos",
                                amount: status.todayEarnings,
                                icon: "arrow.up.circle.fill",
                                color: .green
                            )
                            
                            FinancialMetricCard(
                                title: "Pagos pendientes",
                                amount: status.pendingPayments,
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            FinancialMetricCard(
                                title: "Gastos",
                                amount: 156.50,
                                icon: "arrow.down.circle.fill",
                                color: .red
                            )
                        }
                        
                        // Acciones rápidas
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Acciones rápidas")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    QuickFinanceAction(
                                        title: "Registrar venta",
                                        icon: "cart.fill.badge.plus"
                                    )
                                    
                                    QuickFinanceAction(
                                        title: "Registrar gasto",
                                        icon: "minus.circle.fill"
                                    )
                                    
                                    QuickFinanceAction(
                                        title: "Ver reportes",
                                        icon: "doc.text.fill"
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.gray.opacity(0.05))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct FinancialMetricCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("$\(amount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct QuickFinanceAction: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.bbvaCoreBlue)
                .frame(width: 50, height: 50)
                .background(Color.bbvaCoreBlue.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(color)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    MainTabView()
}
