//
//  RegistrationViewModel.swift
//  BBVAReto3
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var businessName = ""
    @Published var businessOwner = ""
    @Published var estimatedMonthlyIncome = ""
    @Published var businessAddress = "Av. Reforma 222, Col. Juárez, CDMX, C.P. 06600"
    @Published var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
    @Published var isMapViewPresented = false
    @Published var isShowingLocationPermissionAlert = false
    @Published var currentStep = 0
    @Published var showSummary = false
    @Published var showRFCAssistant = false
    @Published var showSATDocumentation = false
    
    // Nuevos campos para documentación
    @Published var hasRFC = false
    @Published var rfcDocument: URL?
    @Published var identificationDocument: URL?
    @Published var addressDocument: URL?
    @Published var efirmaDocument: URL?
    @Published var phoneNumber = ""
    
    // Agregar al RegistrationViewModel:
    @Published var businessPhotos: [URL] = []
    @Published var isProcessingPhotos = false
    @Published var showValidationSuccess = false
    
    let totalSteps = 3 // Ajustado a 5 incluyendo el nuevo paso
    
    var stepTitle: String {
            switch currentStep {
            case 0: return "Información del negocio"
            case 1: return "Ubicación"
            case 2: return "Finanzas"
            case 3: return "Análisis de Oportunidad"
            default: return "Registro MiPyME"
            }
        }
    
    var canGoNext: Bool {
        return true // Simpificado para fines de demostración
    }
    
    var stepHint: String {
            switch currentStep {
            case 0:
                return "Cuéntanos sobre tu negocio para brindarte mejores servicios"
            case 1:
                return "Conocer dónde operas nos ayuda a brindarte soluciones específicas"
            case 2:
                return "Esta información nos permite ofrecerte productos financieros a la medida"
            case 3:
                return "Analicemos el potencial de tu ubicación"
            default:
                return ""
            }
        }
    
    func goToNextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        } else {
            showSummary = true
        }
    }
    
    func goToPreviousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter
    }()
    
    func formatCurrency(string: String) -> String {
        let digits = string.filter { $0.isNumber }
        if let number = Double(digits) {
            return numberFormatter.string(from: NSNumber(value: number/100)) ?? "$0"
        }
        return "$0"
    }
    
    func requestLocationPermission() {
        let locationManager = CLLocationManager()
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isShowingLocationPermissionAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            getCurrentLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        let locationManager = CLLocationManager()
        
        if let location = locationManager.location {
            selectedLocation = location.coordinate
            lookupAddress(for: location)
        }
    }
    
    private func lookupAddress(for location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard error == nil, let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                var addressComponents: [String] = []
                
                if let street = placemark.thoroughfare {
                    addressComponents.append(street)
                }
                if let number = placemark.subThoroughfare {
                    addressComponents.append(number)
                }
                if let neighborhood = placemark.subLocality {
                    addressComponents.append("Col. \(neighborhood)")
                }
                if let city = placemark.locality {
                    addressComponents.append(city)
                }
                if let state = placemark.administrativeArea {
                    addressComponents.append(state)
                }
                if let postalCode = placemark.postalCode {
                    addressComponents.append("C.P. \(postalCode)")
                }
                
                self?.businessAddress = addressComponents.joined(separator: ", ")
            }
        }
    }
}
