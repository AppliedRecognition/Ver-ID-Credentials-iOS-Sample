//
//  CapturedDocumentExport.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 20/12/2022.
//

import Foundation
import SwiftUI
import ZIPFoundation
import UniformTypeIdentifiers

@available(iOS 16, *)
extension CapturedDocument: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .zip) { document in
            try document.archiveToZip()
        }
    }
    
    func archiveToZip() throws -> Data {
        var csv = "\"Section\",\"Property\",\"Value\""
        guard let archive = Archive(accessMode: .create) else {
            throw DocumentExportError.failedToCreateArchive
        }
        guard let png = self.faceCapture.image.pngData() else {
            throw DocumentExportError.failedToCreatePNG
        }
        try archive.addEntry(with: "document.png", type: .file, uncompressedSize: Int64(png.count)) {
            let position = Int($0)
            return png[position..<position+$1]
        }
        if let faceImage = self.faceCapture.faceImage.pngData() {
            try archive.addEntry(with: "face.png", type: .file, uncompressedSize: Int64(faceImage.count)) {
                let position = Int($0)
                return faceImage[position..<position+$1]
            }
        }
        if let frontCapture = self.frontCapture?.pngData() {
            try archive.addEntry(with: "front.png", type: .file, uncompressedSize: Int64(frontCapture.count)) {
                let position = Int($0)
                return frontCapture[position..<position+$1]
            }
        }
        if let backCapture = self.backCapture?.pngData() {
            try archive.addEntry(with: "back.png", type: .file, uncompressedSize: Int64(backCapture.count)) {
                let position = Int($0)
                return backCapture[position..<position+$1]
            }
        }
        for section in self.textFields {
            var i = 1
            for field in section.fields {
                if let value = field.value {
                    csv.append("\r\n\"\(section.title)\",\"\(field.name)\",\"\(value)\"")
                } else if let image = field.image?.pngData() {
                    let imageName = "\(section.title)-\(field.name)-\(i).png"
                    i += 1
                    try archive.addEntry(with: imageName, type: .file, uncompressedSize: Int64(image.count)) { position, size in
                        let pos = Int(position)
                        return image[pos..<pos+size]
                    }
                    csv.append("\r\n\"\(section.title)\",\"\(field.name)\",\"\(imageName)\"")
                }
            }
        }
        guard let data = csv.data(using: .utf8) else {
            throw DocumentExportError.failedToConvertCSVData
        }
        try archive.addEntry(with: "properties.csv", type: .file, uncompressedSize: Int64(data.count)) {
            let position = Int($0)
            return data[position..<position+$1]
        }
        guard let zip = archive.data else {
            throw DocumentExportError.failedToGetArchiveData
        }
        return zip
    }
}

enum DocumentExportError: LocalizedError {
    case failedToCreateArchive, failedToCreatePNG, failedToConvertCSVData, failedToGetArchiveData
}
