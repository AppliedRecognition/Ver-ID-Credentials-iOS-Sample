//
//  DescribedError.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 08/12/2022.
//

import Foundation

struct DescribedError: Error {
    
    let localizedDescription: String
    
    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}
