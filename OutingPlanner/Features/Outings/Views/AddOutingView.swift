//
//  AddOutingView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

struct AddOutingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var outingName = ""
    @State private var selectedDate: Date? = nil
    
    // State internal untuk menangani interaksi DatePicker native
    @State private var internalDate = Date()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                // ==========================================
                // CUSTOM HEADER TOMBOL NATIVE MOCKUP FIGMA
                // ==========================================
                HStack(alignment: .center) {
                    // Tombol Silang (X) Gelap
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Add Outing")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Tombol Centang (✓) Biru
                    Button(action: { saveOuting() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(outingName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(outingName.isEmpty)
                }
                .padding(.top, 8)
                
                // ==========================================
                // INPUT FIELD BLOCK
                // ==========================================
                VStack(spacing: 20) {
                    
                    // 1. OUTING NAME
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OUTING NAME")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        TextField("Enter outing name", text: $outingName)
                            .padding()
                            .background(Color(white: 0.11))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                    }
                    
                    // 2. DATE (NATIVE COMPACT OVERLAY BEHAVIOR)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            // Tampilan Kotak Sesuai Figma
                            HStack {
                                Text(selectedDate != nil ? formattedDate(selectedDate!) : "Select Date")
                                    .font(.subheadline)
                                    .foregroundColor(selectedDate != nil ? .white : .secondary)
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(white: 0.11))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                            
                            // DatePicker Native Apple (.compact) diletakkan di paling depan
                            // Menggunakan frame maksimum agar seluruh area kotak bisa di-klik secara pas
                            DatePicker("", selection: $internalDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                // Trik agar tampilan asli Apple tidak kelihatan, tapi sistem pop-up melayangnya tetap terpicu
                                .opacity(0.015)
                                .onChange(of: internalDate) { _, newValue in
                                    // Begitu user tap tanggal di pop-up, tanggal ter-update dan otomatis menutup pop-up kalendernya
                                    selectedDate = newValue
                                }
                        }
                        .frame(height: 52) // Mengunci tinggi area kotak input tanggal
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .environment(\.colorScheme, .dark)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Hasilnya pas seperti mockup: "20 October 2026"
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func saveOuting() {
        let newOuting = Outing(name: outingName, date: selectedDate)
        modelContext.insert(newOuting)
        dismiss()
    }
}

#Preview {
    AddOutingView()
        .modelContainer(for: Outing.self, inMemory: true)
}
