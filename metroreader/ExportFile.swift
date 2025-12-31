//
//  ExportFile.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//


import SwiftUI
import UniformTypeIdentifiers


extension UTType {
    // This must match the Identifier you put in Xcode
    static var metropass: UTType {
        UTType(exportedAs: "xyz.docsystem.metropass")
    }
}

struct ExportFile: Transferable {
    let data: Data
    let fileName: String

    static var transferRepresentation: some TransferRepresentation {
        // We use DataRepresentation because your export is in memory as 'Data'
        DataRepresentation(exportedContentType: .metropass) { item in
            item.data
        }
        .suggestedFileName { item in
            item.fileName.hasSuffix(".metropass") ? item.fileName : "\(item.fileName).metropass"
        }
    }
}
