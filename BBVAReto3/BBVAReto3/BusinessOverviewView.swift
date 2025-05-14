
import Foundation
import SwiftUI
import Charts

// Componentes auxiliares
struct HeaderSection: View {
    let businessName: String
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "¡Buenos días!"
        case 12..<20: return "¡Buenas tardes!"
        default: return "¡Buenas noches!"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.title2)
                .foregroundColor(.bbvaCoreBlue)
            
            Text(businessName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Resumen de hoy")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DailySalesChart: View {
    let salesData: [(hour: Int, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ventas por hora")
                .font(.headline)
            
            Chart {
                ForEach(salesData, id: \.hour) { sale in
                    BarMark(
                        x: .value("Hora", "\(sale.hour):00"),
                        y: .value("Ventas", sale.amount)
                    )
                    .foregroundStyle(Color.bbvaCoreBlue)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct DailyInsightsSection: View {
    let insights: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights del día")
                .font(.headline)
            
            ForEach(insights, id: \.self) { insight in
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(insight)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// ViewModel
class BusinessOverviewViewModel: ObservableObject {
    @Published var dailySales: [(hour: Int, amount: Double)] = [
        (8, 85.00),
        (9, 120.00),
        (10, 95.00),
        (11, 150.00),
        (12, 180.00),
        (13, 200.00),
        (14, 175.00),
        (15, 160.00),
        (16, 140.00),
        (17, 130.00),
        (18, 110.00),
        (19, 90.00),
        (20, 75.00)
    ]
    
    @Published var keyMetrics: [KeyMetric] = [
        KeyMetric(
            title: "Ventas del día",
            value: "$384",
            trend: 15.5,
            icon: "cart.fill"
        ),
        KeyMetric(
            title: "Clientes hoy",
            value: "15",
            trend: 8.2,
            icon: "person.2.fill"
        ),
        KeyMetric(
            title: "Ticket promedio",
            value: "$25.60",
            trend: -2.3,
            icon: "receipt.fill"
        ),
        KeyMetric(
            title: "Productos vendidos",
            value: "27",
            trend: 12.7,
            icon: "box.fill"
        )
    ]
    
    @Published var dailyInsights: [String] = [
        "Hoy tus ventas son 15% mejores que el martes pasado",
        "Tu producto más vendido es la Quesadilla de Champiñones",
        "El horario pico de ventas es de 2 PM a 4 PM"
    ]
    
    @Published var recommendations: [RecommendationBO] = [
        RecommendationBO(
            title: "Abastecimiento sugerido",
            description: "Tus existencias de tortillas están por acabarse. Considera hacer un pedido pronto.",
            type: .inventory,
            action: "Hacer pedido"
        ),
        RecommendationBO(
            title: "¡Buen momento para promociones!",
            description: "El tráfico de clientes aumenta un 30% entre 2 PM y 4 PM. Aprovecha para ofrecer combos especiales.",
            type: .sales,
            action: "Crear promoción"
        ),
        RecommendationBO(
            title: "💪 ¡Excelente trabajo!",
            description: "Has mantenido un crecimiento constante en ventas durante las últimas 3 semanas.",
            type: .motivation,
            action: "Ver detalles"
        )
    ]
    
    @Published var financialStatus: FinancialStatus = FinancialStatus(
        balance: 15420.50,
        pendingPayments: 2500.00,
        todayEarnings: 3841.00,
        weeklyEarnings: 24567.80
    )
    
    init() {} // Constructor vacío ya que todos los datos son estáticos
}


// Continuación de los componentes visuales
struct KeyMetricsGrid: View {
    let metrics: [KeyMetric]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(metrics) { metric in
                MetricCard(metric: metric)
            }
        }
    }
}

struct MetricCard: View {
    let metric: KeyMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: metric.icon)
                    .font(.title2)
                    .foregroundColor(.bbvaCoreBlue)
                
                Spacer()
                
                TrendIndicator(trend: metric.trend)
            }
            
            Text(metric.title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(metric.value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct TrendIndicator: View {
    let trend: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(trend), specifier: "%.1f")%")
                .font(.caption)
        }
        .foregroundColor(trend >= 0 ? .green : .red)
    }
}

struct SmartRecommendationsSection: View {
    let recommendations: [RecommendationBO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recomendaciones inteligentes")
                .font(.headline)
            
            ForEach(recommendations) { recommendation in
                RecommendationBOCard(recommendation: recommendation)
            }
        }
    }
}

struct RecommendationBOCard: View {
    let recommendation: RecommendationBO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: recommendation.type.icon)
                    .font(.title2)
                    .foregroundColor(recommendation.type.color)
                
                Text(recommendation.title)
                    .font(.headline)
                
                Spacer()
            }
            
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button {
                // Acción
            } label: {
                Text(recommendation.action)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(recommendation.type.color.opacity(0.1))
                    .foregroundColor(recommendation.type.color)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct SimpleFinancialStatus: View {
    let status: FinancialStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Estado financiero")
                .font(.headline)
            
            VStack(spacing: 16) {
                FinancialRow(
                    title: "Balance actual",
                    amount: status.balance,
                    icon: "dollarsign.circle.fill",
                    color: .bbvaCoreBlue
                )
                
                FinancialRow(
                    title: "Pagos pendientes",
                    amount: status.pendingPayments,
                    icon: "clock.fill",
                    color: .orange
                )
                
                FinancialRow(
                    title: "Ganancias de hoy",
                    amount: status.todayEarnings,
                    icon: "calendar",
                    color: .green
                )
                
                FinancialRow(
                    title: "Ganancias semanales",
                    amount: status.weeklyEarnings,
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct FinancialRow: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.medium)
        }
    }
}
