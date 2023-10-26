//
//  KlippaScannerSDK.swift
//  KlippaScannerSDK
//
//  Created by Hasan Kucukcayir on 26/10/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import KlippaScanner

@objc(KlippaScannerSDK)
class KlippaScannerSDK: NSObject {

    private var _resolve: RCTPromiseResolveBlock? = nil
    private var _reject: RCTPromiseRejectBlock? = nil

    @objc(startScanner:withResolver:withRejecter:)
    func startScanner(
        config: [String: Any],
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        _resolve = resolve
        _reject = reject



    }

}

