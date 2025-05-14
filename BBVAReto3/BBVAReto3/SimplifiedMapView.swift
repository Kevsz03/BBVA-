//
//  SimplifiedMapView.swift
//  BBVAReto3
//

import SwiftUI
import MapKit

struct SimplifiedMapView: View {
    @Binding var address: String
    @Binding var isPresented: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // Ciudad de México
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancelar")
                        .foregroundColor(Color.bbvaCoreBlue)
                }
                
                Spacer()
                
                Text("Selecciona ubicación")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    address = "Av. Reforma 222, Col. Juárez, CDMX, C.P. 06600"
                    dismiss()
                }) {
                    Text("Aceptar")
                        .foregroundColor(Color.bbvaCoreBlue)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.white.shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1))
            
            // Real Map without complex functionality
            Map(coordinateRegion: $region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.bottom)
            
            // Botones en la parte inferior
            VStack(spacing: 16) {
                Button(action: {
                    address = "Av. Reforma 222, Col. Juárez, CDMX, C.P. 06600"
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text("Usar esta ubicación")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.bbvaCoreBlue)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    address = "Mi ubicación actual (CDMX)"
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                        Text("Usar mi ubicación actual")
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
            .padding()
            .background(Color.white)
        }
    }
}

#Preview("Pantalla: Mapa") {
    SimplifiedMapView(
        address: .constant("Av. Reforma 222, Col. Juárez, CDMX"),
        isPresented: .constant(true)
    )
}
