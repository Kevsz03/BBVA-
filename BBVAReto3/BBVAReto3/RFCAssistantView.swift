//
//  RFCAssistantView.swift
//  BBVAReto3
//

import SwiftUI

struct RFCAssistantView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var hasAppointment = false
    @State private var hasBusinessActivity = false
    @State private var checklist = [
        "CURP": false,
        "Identificación oficial": false,
        "Comprobante de domicilio": false,
        "Correo y celular": false
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // BBVA Header
                    ZStack {
                        Color.bbvaNavyBlue
                        
                        Text("Asistente de RFC")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(height: 60)
                    .edgesIgnoringSafeArea(.top)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case 0:
                                introductionView
                            case 1:
                                appointmentView
                            case 2:
                                businessTypeView
                            case 3:
                                documentsView
                            case 4:
                                appointmentExplanationView
                            case 5:
                                recommendationsView
                            case 6:
                                successView
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                        .padding(.bottom, 80)
                    }
                    
                    // Navigation buttons
                    if currentStep < 6 {
                        HStack {
                            if currentStep > 0 {
                                Button(action: {
                                    currentStep -= 1
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Anterior")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.bbvaCoreBlue)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.bbvaCoreBlue, lineWidth: 1)
                                    )
                                }
                            } else {
                                Spacer()
                            }
                            
                            Button(action: {
                                if currentStep < 6 {
                                    currentStep += 1
                                }
                            }) {
                                Text(currentStep == 5 ? "Finalizar" : "Siguiente")
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
                    } else {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Volver al registro BBVA")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.bbvaCoreBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Asistente RFC")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .accentColor(.white)
    }
    
    // MARK: - Step Views
    
    private var introductionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.system(size: 70))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("¡Hola! Te ayudaré a darte de alta en el SAT como Persona Física con Actividad Empresarial.")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("Vamos paso a paso para que puedas completar tu trámite sin problemas.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("¿Estás listo para comenzar?")
                    .font(.headline)
                
                HStack {
                    Button {
                        currentStep += 1
                    } label: {
                        Text("Sí, empecemos")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.bbvaCoreBlue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        // Acción para mostrar dudas
                    } label: {
                        Text("Tengo dudas")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.bbvaCoreBlue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.bbvaCoreBlue, lineWidth: 1)
                            )
                    }
                }
                
                Text("MarcaSAT: 55 627 22 728")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var appointmentView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("Paso 1: Agendar cita SAT")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Para iniciar tu trámite, necesitas agendar una cita en el SAT")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("¿Ya tienes una cita agendada?")
                    .font(.headline)
                
                Button {
                    hasAppointment = true
                    // Avanzamos automáticamente si ya tiene cita
                    currentStep += 1
                } label: {
                    HStack {
                        Image(systemName: hasAppointment ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(hasAppointment ? .bbvaCoreBlue : .gray)
                        Text("Sí, ya la agendé")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(hasAppointment ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button {
                    hasAppointment = false
                } label: {
                    HStack {
                        Image(systemName: !hasAppointment ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!hasAppointment ? .bbvaCoreBlue : .gray)
                        Text("No, necesito ayuda")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(!hasAppointment ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                if !hasAppointment {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Para agendar cita:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Link(destination: URL(string: "https://citas.sat.gob.mx")!) {
                            HStack {
                                Text("Sitio oficial del SAT")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .foregroundColor(.bbvaCoreBlue)
                        }
                        
                        Text("Selecciona: Inscripción al RFC como Persona Física con Actividad Empresarial")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.bbvaNavyBlue.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var businessTypeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 60))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("Paso 2: Tipo de inscripción")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Necesitamos saber el tipo de actividad que realizarás")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("¿Vas a trabajar, vender, prestar servicios o emprender?")
                    .font(.headline)
                
                Button {
                    hasBusinessActivity = true
                } label: {
                    HStack {
                        Image(systemName: hasBusinessActivity ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(hasBusinessActivity ? .bbvaCoreBlue : .gray)
                        Text("Sí, voy a trabajar o emprender")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(hasBusinessActivity ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button {
                    hasBusinessActivity = false
                } label: {
                    HStack {
                        Image(systemName: !hasBusinessActivity ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!hasBusinessActivity ? .bbvaCoreBlue : .gray)
                        Text("No, solo quiero RFC para trámites")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(!hasBusinessActivity ? Color.bbvaCoreBlue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                if hasBusinessActivity {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Persona Física con Actividad Económica")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var documentsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.on.doc.fill")
                .font(.system(size: 60))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("Paso 3: Documentos necesarios")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Marca los documentos que ya tienes listos")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(checklist.keys.sorted()), id: \.self) { item in
                    Button {
                        checklist[item]?.toggle()
                    } label: {
                        HStack {
                            Image(systemName: checklist[item]! ? "checkmark.square.fill" : "square")
                                .foregroundColor(checklist[item]! ? .bbvaCoreBlue : .gray)
                            
                            Text(item)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                if checklist.values.filter({ $0 }).count == checklist.count {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("¡Perfecto! Tienes todo lo necesario")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var appointmentExplanationView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("Paso 4: ¿Qué pasará en tu cita?")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Es importante que sepas qué esperar durante tu visita al SAT")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                InformationRow(
                    icon: "number.circle.fill",
                    title: "Generación del RFC",
                    description: "Te asignarán tu Registro Federal de Contribuyentes con homoclave"
                )
                
                InformationRow(
                    icon: "key.fill",
                    title: "Contraseña del portal SAT",
                    description: "Te darán acceso al portal del SAT para trámites en línea"
                )
                
                InformationRow(
                    icon: "signature",
                    title: "e.firma (opcional)",
                    description: "Podrás tramitar tu firma electrónica para documentos digitales"
                )
                
                InformationRow(
                    icon: "doc.text.fill",
                    title: "Constancia de situación fiscal",
                    description: "Te entregarán este documento que valida tu inscripción al RFC"
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var recommendationsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 60))
                .foregroundColor(.bbvaCoreBlue)
            
            Text("Recomendaciones finales")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Para que tu cita sea exitosa")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                InformationRow(
                    icon: "clock.fill",
                    title: "Puntualidad",
                    description: "Llega al menos 15 minutos antes de tu cita"
                )
                
                InformationRow(
                    icon: "person.fill.xmark",
                    title: "Sin acompañantes",
                    description: "El trámite es personal y no requiere acompañantes"
                )
                
                InformationRow(
                    icon: "folder.fill",
                    title: "Documentación organizada",
                    description: "Lleva toda tu documentación en una carpeta"
                )
                
                InformationRow(
                    icon: "phone.fill",
                    title: "Teléfono listo",
                    description: "Ten a la mano el número de MarcaSAT: 55 627 22 728"
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("¡Listo!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Ya tienes todo lo necesario para darte de alta como Persona Física con Actividad Empresarial.")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.bbvaCoreBlue)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Asiste a tu cita")
                            .font(.headline)
                        Text("Con todos los documentos requeridos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(.bbvaCoreBlue)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Obtén tu RFC y constancia")
                            .font(.headline)
                        Text("Guarda bien tu contraseña y documentos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(.bbvaCoreBlue)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Regresa a BBVA para completar tu registro")
                            .font(.headline)
                        Text("Ya podrás continuar tu registro como cliente MiPyME")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .padding()
    }
}

struct InformationRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.bbvaCoreBlue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview("RFC Assistant") {
    RFCAssistantView(isPresented: .constant(true))
}
