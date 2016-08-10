//
//  AKDecimatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKDecimatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDecimator(input)
        input.start()
        AKTestMD5("5776a357a7fe6a6393f5215d39142925", alternate: "d868f3d94c69bff3fb83ba83516d0b98")
    }
}
