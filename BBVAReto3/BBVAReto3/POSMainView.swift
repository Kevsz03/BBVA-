import Foundation
import SwiftUI

// POSMainView.swift
struct POSMainView: View {
    @StateObject private var viewModel = POSViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // BBVA Header
                    HeaderView(title: "Punto de Venta")
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Business name and subtitle
                            VStack(spacing: 8) {
                                Text("El Sazón de Mary")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.bbvaCoreBlue)
                                
                                Text("Punto de venta MiPyME de María")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top)
                            
                            // Nueva venta button
                            Button {
                                viewModel.showProductSelector = true
                            } label: {
                                HStack {
                                    Image(systemName: "cart.fill.badge.plus")
                                        .font(.title2)
                                    Text("Nueva venta")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.bbvaCoreBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Options Grid
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Más opciones para cobrar")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    POSOptionCard(
                                        icon: "tag.fill",
                                        title: "Vende productos desde tu catálogo"
                                    )
                                    POSOptionCard(
                                        icon: "creditcard.fill",
                                        title: "Paga servicios para tus clientes"
                                    )
                                    POSOptionCard(
                                        icon: "phone.fill",
                                        title: "Realiza recargas telefónicas"
                                    )
                                    POSOptionCard(
                                        icon: "list.clipboard.fill",
                                        title: "Administra mis órdenes"
                                    )
                                    POSOptionCard(
                                        icon: "arrow.triangle.2.circlepath",
                                        title: "Administra tus suscripciones"
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showProductSelector) {
            POSProductSelectorView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.showContactlessPayment) {
            POSContactlessPaymentView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showReceipt) {
            POSReceiptView(
                amount: viewModel.currentAmount,
                cardLastDigits: viewModel.cardLastDigits,
                transactionId: viewModel.transactionId,
                businessName: "El Sazón de Mary"
            )
        }
    }
}

struct POSOptionCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.bbvaCoreBlue)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct POSProductSelectorView: View {
    @ObservedObject var viewModel: POSViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0 // 0 para cantidad, 1 para productos
    @State private var amountString = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView(title: "Nueva venta")
                
                // Selector de modo
                HStack(spacing: 0) {
                    TabButton(
                        title: "Cantidad",
                        icon: "number.square.fill",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    TabButton(
                        title: "Tus productos",
                        icon: "list.clipboard.fill",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                }
                .padding()
                
                if selectedTab == 0 {
                    // Vista calculadora
                    VStack(spacing: 24) {
                        // Cantidad
                        Text("$\(amountString.isEmpty ? "0.00" : amountString)")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 32)
                        
                        // Teclado numérico
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(1...9, id: \.self) { number in
                                NumberButton(title: "\(number)") {
                                    addNumber(number)
                                }
                            }
                            
                            NumberButton(title: "+") {
                                // Implementar suma
                            }
                            
                            NumberButton(title: "0") {
                                addNumber(0)
                            }
                            
                            NumberButton(title: "⌫") {
                                removeLastNumber()
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Botón cobrar
                        Button {
                            if let amount = Double(amountString) {
                                viewModel.currentAmount = amount
                                dismiss() // Cerrar la vista actual
                                viewModel.startPaymentFlow() // Iniciar el flujo de pago
                            }
                        } label: {
                            Text("Cobrar $\(amountString.isEmpty ? "0.00" : amountString)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.bbvaCoreBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding()
                        .disabled(amountString.isEmpty)
                    }
                    
                } else {
                    // Vista catálogo de productos
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.products) { product in
                                ProductCard(product: product) {
                                    viewModel.currentAmount = product.price
                                    dismiss() // Cerrar la vista actual
                                    viewModel.startPaymentFlow() // Iniciar el flujo de pago
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.bbvaCoreBlue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Ayuda o información
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.bbvaCoreBlue)
                    }
                }
            }
        }
    }
    
    private func addNumber(_ number: Int) {
        if amountString.count < 8 { // Limitar a 8 dígitos
            amountString += "\(number)"
        }
    }
    
    private func removeLastNumber() {
        if !amountString.isEmpty {
            amountString.removeLast()
        }
    }
    
    private func proceedToPayment() {
        // Implementar transición a la vista de pago
    }
}

// Componentes auxiliares
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.bbvaCoreBlue.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .bbvaCoreBlue : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NumberButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.primary)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductCard: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .foregroundColor(.bbvaCoreBlue)
                    
                    if let variations = product.variations {
                        Text(variations.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.bbvaCoreBlue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct POSContactlessPaymentView: View {
    @ObservedObject var viewModel: POSViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var showSuccess = false
    @State private var showReceipt = false
    
    // Datos simulados de la tarjeta
    private let cardLastDigits = "2248"
    private let transactionId = String(format: "%09d", Int.random(in: 100000000...999999999))
    
    var body: some View {
        ZStack {
            // Fondo
            Color.white.edgesIgnoringSafeArea(.all)
            
            if showSuccess {
                // Vista de éxito
                PaymentSuccessView(amount: viewModel.currentAmount) {
                    showReceipt = true
                }
            } else {
                // Vista de espera NFC
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Símbolo NFC animado
                    NFCSymbol(isAnimating: isAnimating)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 16) {
                        Text("Acerca la tarjeta")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.bbvaCoreBlue)
                        
                        Text("$\(String(format: "%.2f", viewModel.currentAmount))")
                            .font(.system(size: 42, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Mantén la tarjeta cerca del dispositivo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Botón cancelar
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancelar")
                            .font(.headline)
                            .foregroundColor(.bbvaCoreBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.bbvaCoreBlue, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startNFCAnimation()
            // Simular detección de tarjeta después de 3 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showPaymentSuccess()
            }
        }
        .sheet(isPresented: $showReceipt) {
            POSReceiptView(
                amount: viewModel.currentAmount,
                cardLastDigits: cardLastDigits,
                transactionId: transactionId,
                businessName: "El Sazón de Mary"
            )
        }
    }
    
    private func startNFCAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    private func showPaymentSuccess() {
        withAnimation(.spring()) {
            showSuccess = true
        }
    }
}

// Componente del símbolo NFC
struct NFCSymbol: View {
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Círculos concéntricos
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.bbvaCoreBlue.opacity(0.3), lineWidth: 2)
                    .scaleEffect(isAnimating ? 1 + Double(i) * 0.2 : 0.8)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.2),
                        value: isAnimating
                    )
            }
            
            // Símbolo NFC
            Image(systemName: "creditcard.wireless.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.bbvaCoreBlue)
        }
    }
}

// Vista de éxito del pago
struct PaymentSuccessView: View {
    let amount: Double
    let action: () -> Void
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Círculo de éxito animado
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showCheckmark = true
                }
            }
            
            VStack(spacing: 16) {
                Text("¡Pago exitoso!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("$\(String(format: "%.2f", amount))")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Button {
                action()
            } label: {
                Text("Ver recibo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.bbvaCoreBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 24)
            .padding(.horizontal)
        }
    }
}

struct POSReceiptView: View {
    let amount: Double
    let cardLastDigits: String
    let transactionId: String
    let businessName: String
    @Environment(\.dismiss) private var dismiss
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm:ss"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Encabezado de éxito
                        VStack(spacing: 8) {
                            Text("Operación exitosa")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.bbvaCoreBlue)
                            
                            Text(currentDate)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        
                        // Monto
                        VStack(spacing: 8) {
                            Text("Importe cobrado")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("$\(String(format: "%.2f", amount))")
                                .font(.system(size: 42, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Comisión $0.00")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical)
                        
                        // Detalles de la transacción
                        VStack(spacing: 20) {
                            // Tarjeta y comercio
                            HStack(spacing: 16) {
                                // Icono de tarjeta
                                Image(systemName: "creditcard.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.bbvaCoreBlue)
                                    .clipShape(Circle())
                                
                                // Datos del comercio
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("•••• \(cardLastDigits)")
                                        .font(.headline)
                                    Text(businessName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                            // Detalles adicionales
                            VStack(spacing: 16) {
                                DetailRow(title: "Concepto", value: "Venta en terminal")
                                DetailRow(title: "Tipo de operación", value: "Cobro con tarjeta")
                                DetailRow(title: "Folio de operación", value: transactionId)
                            }
                            .padding(.horizontal)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Mensaje de comprobante
                        Text("Recibirás el comprobante de tu operación al correo registrado")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Botón compartir
                        Button {
                            // Implementar compartir
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Compartir comprobante")
                            }
                            .font(.headline)
                            .foregroundColor(.bbvaCoreBlue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.bbvaCoreBlue, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.bbvaCoreBlue)
                    }
                }
            }
        }
    }
}

// Componente auxiliar para las filas de detalles
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Preview
#Preview {
    POSMainView()
}
