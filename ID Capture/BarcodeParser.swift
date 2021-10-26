//
//  BarcodeParser.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import Foundation
import Vision
import RxSwift
import AAMVABarcodeParser

class BarcodeParser {
    
    static let `default` = BarcodeParser()
    
    func parseBarcodes(_ barcodes: [VNBarcodeObservation]) -> Single<DocumentData> {
        return Single<Data>.create(subscribe: { event in
            do {
                guard let barcodeData = barcodes.first?.payloadStringValue?.data(using: .utf8) else {
                    throw BarcodeParserError.emptyDocument
                }
                event(.success(barcodeData))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        }).flatMap({ data in
            self.parseBarcodeData(data)
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance)
    }
    
    func parseBarcodeData(_ barcodeData: Data) -> Single<DocumentData> {
        return Single<DocumentData>.create(subscribe: { event in
            do {
                let parser: BarcodeParsing
                if !ExecutionParams.isTesting, let intellicheckPassword = try SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
                    parser = IntellicheckBarcodeParser(apiKey: intellicheckPassword)
                } else {
                    parser = AAMVABarcodeParser()
                }
                let docData = try parser.parseData(barcodeData)
                event(.success(docData))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance)
    }
}
