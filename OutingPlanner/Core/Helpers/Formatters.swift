//
//  Formatters.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation

enum Formatters {
    /// Format angka jadi format singkat rupiah.
    /// Contoh: 200_000 -> "Rp 200rb", 1_500_000 -> "Rp 1.5jt"
    static func rupiahShort(_ value: Int) -> String {
        if value == 0 { return "-" }
        if value >= 1_000_000 {
            let millions = Double(value) / 1_000_000
            let formatted = millions.formatted(.number.precision(.fractionLength(0...1)))
            return "Rp \(formatted)jt"
        } else if value >= 1_000 {
            return "Rp \(value / 1_000)rb"
        } else {
            return "Rp \(value)"
        }
    }

    /// Format angka jadi rupiah penuh dengan pemisah ribuan.
    /// Contoh: 200000 -> "Rp 200.000"
    static func rupiahBig(_ value: Int) -> String {
        if value == 0 { return "-" }
        let formatted = value.formatted(.number.grouping(.automatic))
        return "Rp \(formatted)"
    }

    /// Format tanggal panjang ala "20 October 2026".
    static func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Format jam pendek ala "14:30".
    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
