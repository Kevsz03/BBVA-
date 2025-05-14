// POSModels.swift
import Foundation

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let variations: [String]?
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
    var variation: String?
    var total: Double {
        Double(quantity) * product.price
    }
}

class POSViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var customAmount: String = ""
    @Published var isProcessingPayment = false
    @Published var showPaymentSuccess = false
    @Published var selectedProduct: Product?
    @Published var showProductSelector = false
    
    @Published var showContactlessPayment = false
    @Published var showReceipt = false
    @Published var currentAmount: Double = 0.0
    
    // Datos de la transacción
    var transactionId = ""
    var cardLastDigits = "2248" // Simulado
    
    func startPaymentFlow() {
        showContactlessPayment = true
        transactionId = String(format: "%09d", Int.random(in: 100000000...999999999))
    }
    
    func completePayment() {
        showContactlessPayment = false
        showReceipt = true
    }
    
    let products = [
        Product(name: "Quesadilla", price: 30.0, variations: ["Queso", "Pollo", "Champiñones", "Chorizo"]),
        Product(name: "Taco", price: 25.0, variations: ["Pastor", "Suadero", "Bistec", "Chorizo"]),
        Product(name: "Refresco", price: 20.0, variations: ["Cola", "Naranja", "Limón", "Manzana"]),
        Product(name: "Agua mineral", price: 20.0, variations: nil),
        Product(name: "Agua de sabor", price: 20.0, variations: ["Jamaica", "Horchata", "Limón", "Tamarindo"])
    ]
    
    var total: Double {
        cartItems.reduce(0) { $0 + $1.total }
    }
    
    func addToCart(product: Product, variation: String? = nil) {
        if let existingIndex = cartItems.firstIndex(where: {
            $0.product.id == product.id && $0.variation == variation
        }) {
            cartItems[existingIndex].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1, variation: variation))
        }
    }
}
