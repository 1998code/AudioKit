//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFormantFilterTests: AKTestCase {

    func testDefault() {
        output = AKFormantFilter(input)
        AKTestNoEffect()
    }
}
