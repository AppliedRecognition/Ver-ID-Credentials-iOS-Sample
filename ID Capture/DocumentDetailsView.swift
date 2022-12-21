//
//  DocumentDetailsView.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import SwiftUI
import DocumentVerificationClient

struct DocumentDetailsView: View {
    
    @State var document: CapturedDocument
    
    var body: some View {
        List {
            Image(uiImage: document.faceCapture.image)
                .resizable()
                .overlay(alignment: .topLeading) {
                    Canvas { context, size in
                        let scale = size.width / document.faceCapture.image.size.width
                        let faceRect = document.faceCapture.face.bounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                        context.stroke(Path(roundedRect: faceRect, cornerRadius: 4), with: .color(Color.green), style: StrokeStyle(lineWidth: 2))
                    }
                }
                .aspectRatio(85.6/53.98, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
            ForEach(document.textFields) { section in
                Section(section.title) {
                    ForEach(section.fields) { field in
                        ListEntry(field: field)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Document details")
        .toolbar {
            if #available(iOS 16, *) {
                ShareLink(item: self.document, subject: Text("Captured document"), preview: SharePreview("Captured document")) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

struct ListEntry: View {
    
    let field: DocumentField
    
    var body: some View {
        HStack {
            if let image = field.image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                Spacer()
                Text(field.name)
            } else {
                Text(field.name)
                Spacer()
                if let value = field.value {
                    Text(value)
                }
            }
        }
    }
}

struct DocumentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if let doc = CapturedDocument.sample {
                DocumentDetailsView(document: doc)
            } else {
                Text("Unable to load preview")
            }
        }
    }
}
