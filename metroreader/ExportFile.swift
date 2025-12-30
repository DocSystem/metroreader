//
//  ExportFile.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//


import SwiftUI
import UniformTypeIdentifiers

struct ExportFile: Transferable {
    let data: Data
    let fileName: String

    static var transferRepresentation: some TransferRepresentation {
        // We use DataRepresentation because your export is in memory as 'Data'
        DataRepresentation(exportedContentType: .json) { item in
            item.data
        }
        .suggestedFileName { item in
            item.fileName
        }
    }
}
