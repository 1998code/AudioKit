//
//  AKTremoloTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKTremoloTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKTremolo(input)
        input.start()
        AKTestMD5("")
    }
}
