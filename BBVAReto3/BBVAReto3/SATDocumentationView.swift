//
//  SATDocumentationView.swift
//  BBVAReto3
//

import SwiftUI

struct SATDocumentationView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var isFileImporterPresented = false
    @State private var documentTypeToImport: DocumentType = .rfc
    @Environment(\.dismiss) private var dismiss
    
    enum DocumentType {
        case rfc, identification, address, efirma
    }
    
    struct DocumentUploadCard: View {
        let title: String
        let description: String
        let icon: String
        let documentURL: URL?
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    // Icono
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.bbvaCoreBlue)
                        .frame(width: 40, height: 40)
                        .background(Color.bbvaCoreBlue.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Contenido
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        // Estado del documento
                        if let _ = documentURL {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Documento cargado")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Flecha o indicador de estado
                    Image(systemName: documentURL == nil ? "arrow.up.circle.fill" : "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(documentURL == nil ? .bbvaCoreBlue : .green)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // BBVA Header
                    HeaderView(title: "Documentación SAT")
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Título y descripción
                            VStack(spacing: 12) {
                                Text("Documentación Fiscal")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.bbvaCoreBlue)
                                
                                Text("Para completar tu registro como cliente MiPyME, necesitamos tu información fiscal")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                            
                            // RFC selector
                            VStack(alignment: .leading, spacing: 16) {
                                Text("¿Cuentas con RFC como Persona Física con Actividad Empresarial?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        viewModel.hasRFC = true
                                    } label: {
                                        HStack {
                                            Image(systemName: viewModel.hasRFC ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(viewModel.hasRFC ? .bbvaCoreBlue : .gray)
                                            Text("Sí, ya tengo RFC")
                                                .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(viewModel.hasRFC ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    Button {
                                        viewModel.hasRFC = false
                                        viewModel.showRFCAssistant = true
                                    } label: {
                                        HStack {
                                            Image(systemName: !viewModel.hasRFC ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(!viewModel.hasRFC ? .bbvaCoreBlue : .gray)
                                            Text("No, necesito uno")
                                                .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(!viewModel.hasRFC ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            if viewModel.hasRFC {
                                // Documentos necesarios
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Documentos requeridos")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                    
                                    DocumentUploadCard(
                                        title: "RFC o Constancia de Situación Fiscal",
                                        description: "Documento emitido por el SAT que avala tu situación fiscal",
                                        icon: "doc.text.fill",
                                        documentURL: viewModel.rfcDocument,
                                        action: {
                                            documentTypeToImport = .rfc
                                            isFileImporterPresented = true
                                        }
                                    )
                                    
                                    DocumentUploadCard(
                                        title: "Identificación oficial",
                                        description: "INE, pasaporte o cédula profesional vigentes",
                                        icon: "person.text.rectangle.fill",
                                        documentURL: viewModel.identificationDocument,
                                        action: {
                                            documentTypeToImport = .identification
                                            isFileImporterPresented = true
                                        }
                                    )
                                    
                                    DocumentUploadCard(
                                        title: "Comprobante de domicilio",
                                        description: "No mayor a 3 meses de antigüedad",
                                        icon: "house.fill",
                                        documentURL: viewModel.addressDocument,
                                        action: {
                                            documentTypeToImport = .address
                                            isFileImporterPresented = true
                                        }
                                    )
                                    
                                    DocumentUploadCard(
                                        title: "e.firma (antes FIEL)",
                                        description: "Archivo .cer o .key de tu firma electrónica",
                                        icon: "signature",
                                        documentURL: viewModel.efirmaDocument,
                                        action: {
                                            documentTypeToImport = .efirma
                                            isFileImporterPresented = true
                                        }
                                    )
                                    
                                    // Fotografias del negocio
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Validación del negocio")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                        
                                        VStack(alignment: .leading, spacing: 24) {
                                            // Card principal para la validación
                                            VStack(alignment: .leading, spacing: 16) {
                                                // Título e ícono
                                                HStack {
                                                    Image(systemName: "building.2.fill")
                                                        .font(.title2)
                                                        .foregroundColor(.bbvaCoreBlue)
                                                        .frame(width: 40, height: 40)
                                                        .background(Color.bbvaCoreBlue.opacity(0.1))
                                                        .clipShape(Circle())
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text("Fotografías del negocio")
                                                            .font(.headline)
                                                            .foregroundColor(.primary)
                                                        
                                                        Text("Necesitamos validar tu espacio de trabajo")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                // Descripción detallada
                                                Text("Sube 2-3 fotografías que muestren claramente tu espacio de trabajo. Pueden ser de tu local comercial, oficina, puesto de trabajo o área donde realizas tu actividad profesional.")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal)
                                                
                                                // Grid de fotos
                                                if !viewModel.businessPhotos.isEmpty {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack(spacing: 12) {
                                                            ForEach(viewModel.businessPhotos, id: \.self) { photoURL in
                                                                Image(systemName: "photo.fill")
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 80, height: 80)
                                                                    .background(Color.bbvaCoreBlue.opacity(0.1))
                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                    .overlay(
                                                                        Button(action: {
                                                                            if let index = viewModel.businessPhotos.firstIndex(of: photoURL) {
                                                                                viewModel.businessPhotos.remove(at: index)
                                                                            }
                                                                        }) {
                                                                            Image(systemName: "xmark.circle.fill")
                                                                                .foregroundColor(.red)
                                                                                .background(Color.white)
                                                                                .clipShape(Circle())
                                                                        }
                                                                        .offset(x: 30, y: -30),
                                                                        alignment: .topTrailing
                                                                    )
                                                            }
                                                            
                                                            if viewModel.businessPhotos.count < 3 {
                                                                Button(action: {
                                                                    // Aquí iría la lógica para tomar/seleccionar foto
                                                                    // Simulamos agregando una URL falsa
                                                                    viewModel.businessPhotos.append(URL(string: "photo\(viewModel.businessPhotos.count + 1)")!)
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName: "plus.circle.fill")
                                                                            .font(.title)
                                                                        Text("Agregar")
                                                                            .font(.caption)
                                                                    }
                                                                    .frame(width: 80, height: 80)
                                                                    .foregroundColor(.bbvaCoreBlue)
                                                                    .background(Color.bbvaCoreBlue.opacity(0.1))
                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                }
                                                            }
                                                        }
                                                        .padding(.horizontal)
                                                    }
                                                } else {
                                                    // Botón para agregar primera foto
                                                    Button(action: {
                                                        // Simulamos agregando una URL falsa
                                                        viewModel.businessPhotos.append(URL(string: "photo1")!)
                                                    }) {
                                                        HStack {
                                                            Image(systemName: "camera.fill")
                                                            Text("Tomar o seleccionar fotos")
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding()
                                                        .background(Color.bbvaCoreBlue.opacity(0.1))
                                                        .foregroundColor(.bbvaCoreBlue)
                                                        .cornerRadius(8)
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                
                                                // Botón de validación
                                                if viewModel.businessPhotos.count >= 2 {
                                                    Button(action: {
                                                        viewModel.isProcessingPhotos = true
                                                        
                                                        // Simulamos el procesamiento del modelo ML
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                            viewModel.isProcessingPhotos = false
                                                            viewModel.showValidationSuccess = true
                                                        }
                                                    }) {
                                                        HStack {
                                                            if viewModel.isProcessingPhotos {
                                                                ProgressView()
                                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                                Text("Procesando...")
                                                            } else {
                                                                Image(systemName: "checkmark.shield.fill")
                                                                Text("Validar negocio")
                                                            }
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding()
                                                        .background(Color.bbvaCoreBlue)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(8)
                                                    }
                                                    .disabled(viewModel.isProcessingPhotos)
                                                    .padding(.horizontal)
                                                }
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                    
                                    // Teléfono
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Número de teléfono celular")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        TextField("55 1234 5678", text: $viewModel.phoneNumber)
                                            .keyboardType(.phonePad)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    .background(Color.white)
                                            )
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal)
                                }
                            }
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.vertical)
                    }
                    
                    // Bottom buttons
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancelar")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.bbvaCoreBlue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.bbvaCoreBlue, lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            // Aquí iría la lógica para finalizar y enviar la documentación
                            dismiss()
                        }) {
                            Text("Finalizar registro")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.bbvaCoreBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
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
            .sheet(isPresented: $viewModel.showRFCAssistant) {
                RFCAssistantView(isPresented: $viewModel.showRFCAssistant)
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf, .image, .text],
                allowsMultipleSelection: false
            ) { result in
                do {
                    let fileURL = try result.get().first!
                    
                    // Guardar URL según el tipo de documento
                    switch documentTypeToImport {
                    case .rfc:
                        viewModel.rfcDocument = fileURL
                    case .identification:
                        viewModel.identificationDocument = fileURL
                    case .address:
                        viewModel.addressDocument = fileURL
                    case .efirma:
                        viewModel.efirmaDocument = fileURL
                    }
                    
                } catch {
                    print("Error al importar archivo: \(error.localizedDescription)")
                }
            }
            .alert("Validación exitosa", isPresented: $viewModel.showValidationSuccess) {
                Button("Continuar", role: .cancel) { }
            } message: {
                Text("Hemos verificado exitosamente las fotografías de tu negocio. Puedes continuar con el proceso de registro.")
            }
        }
    }
}
