//
//  AKFader.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/12/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public enum CurveType {
    case Linear, EqualPower, Exponential
    
    public static func fromString(curve: String) -> CurveType {

        switch curve {
        case "linear":
            return .Linear
        case "exponential":
            return .Exponential
        case "equalpower":
            return .EqualPower
        default:
            return .Linear
        }
    }
}

public class AKFader {
    
    let π = M_PI
    
    var output: AKBooster?

    var initialVolume: Double = 1.0 //make these only 0 or 1 right now
    var finalVolume: Double = 0.0 //make these only 0 or 1 right now
    
    var controlRate: Double = 1 / 60 // 60 times per second
    var curveType: CurveType = .Linear
    var taper: Double = 0.5 //doesn't apply to linear
    var duration: Double = 1.0 //seconds
    var offset: Double = 0.0
    var stepCounter = 0
    var numberOfSteps = 0
    
    var fadeTimer = NSTimer()
    var fadeScheduleTimer = NSTimer()
    
    let cadTimerRate: Double = 1 / 60
    var cadDelayTimer: CADisplayLink?
    var cadUpdateTimer: CADisplayLink?
    var cadTimerIncrement: Int = 0
    
    var directionString: String {
        return (finalVolume > initialVolume ? "up" : "down")
    }
    
    /// Init with a single control output
    public init(initialVolume: Double,
         finalVolume: Double,
         duration: Double = 1.0,
         type: CurveType = .Exponential,
         taper: Double = 1.0,
         offset: Double = 0.0,
         output: AKBooster) {
        
        self.initialVolume = initialVolume
        self.finalVolume = finalVolume
        curveType = type
        self.taper = taper
        self.duration = duration
        self.offset = offset
        numberOfSteps = Int(floor(duration / controlRate))
        self.output = output
    }
    
    /// Schedule a fade to start after fireTime
    ///
    /// - parameter fireTime: Time to start the fade at
    ///
    func scheduleFade(fireTime: Double) {
        //this schedules a fade to start after fireTime + the offset
        let millis = NSDate().timeIntervalSince1970*1000
        print("scheduling fade @\(millis) for \(millis + fireTime*1000) \(directionString)")
        scheduleCADTimer(fireTime + offset)
        output!.gain = initialVolume
    }
    
    /// Start the fade WITH the offset
    public func start() {
        scheduleFade(0.0)
    }
    /// Start the fade WITHOUT the offset
    public func startImmediately() {
        //this starts the recurring timer
        let millis = NSDate().timeIntervalSince1970*1000
        print("starting fade \(millis) \(directionString)")
        stepCounter = 0
        
        if cadUpdateTimer != nil {
            cadUpdateTimer?.invalidate()
        }
        if numberOfSteps == 0 { //if no steps to run, go ahead and set the volume early
            output!.gain = finalVolume
        }
        cadUpdateTimer = CADisplayLink(target: self, selector: #selector(updateFadeFromCADTimer))
        cadUpdateTimer?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
    
    @objc func updateFadeFromCADTimer() {
        let direction: Double = (initialVolume > finalVolume ? 1.0 : -1.0)
        let millis = NSDate().timeIntervalSince1970*1000
        print("updatingFade fade \(millis) - \(stepCounter) \(directionString)")
        if numberOfSteps == 0 {
            endFade()
        } else if stepCounter <= numberOfSteps {
            //normalized 0-1 value
            let controlAmount: Double = Double(stepCounter) / Double(numberOfSteps)
            var scaledControlAmount: Double = 0.0
            
            switch curveType {
            case .Linear:
                scaledControlAmount = controlAmount.denormalized(minimum: initialVolume,
                                                                 maximum: finalVolume,
                                                                 taper: 1)
            case .Exponential:
                scaledControlAmount = controlAmount.denormalized(minimum: initialVolume,
                                                                 maximum: finalVolume,
                                                                 taper: taper)
            case .EqualPower:
                //direction will be negative if going up
                scaledControlAmount = pow((0.5 + 0.5 * direction * cos(π * controlAmount)), 0.5)
            }
            
            output!.gain = scaledControlAmount
            stepCounter += 1
        } else {
            endFade()
        }
    }
    
    func endFade() {
        let millis = NSDate().timeIntervalSince1970*1000
        print("ending fade \(millis) - \(numberOfSteps) \(directionString)")
        cadUpdateTimer?.invalidate()
        output!.gain = finalVolume
        stepCounter = 0
    }
    static func generateCurvePoints(source: Double,
                                    target: Double,
                                    duration: Double = 1.0,
                                    type: CurveType = .Exponential,
                                    taper: Double = 1.0,
                                    controlRate: Double = 1 / 60) -> [Double] {
        var curvePoints = [Double]()
        let stepCount = Int(floor(duration / controlRate))
        var counter = 0
        let direction: Double = source > target ? 1.0 : -1.0
        if counter <= stepCount {
            //normalized 0-1 value
            let controlAmount: Double = Double(counter) / Double(stepCount)
            var scaledControlAmount: Double = 0.0
            
            switch type {
            case .Linear:
                scaledControlAmount = controlAmount.denormalized(minimum: source,
                                                                 maximum: target,
                                                                 taper: 1)
            case .Exponential:
                scaledControlAmount = controlAmount.denormalized(minimum: source,
                                                                 maximum: target,
                                                                 taper: taper)
            case .EqualPower:
                //direction will be negative if going up
                scaledControlAmount = pow((0.5 + 0.5 * direction * cos(M_PI * controlAmount)), 0.5)
            }
            curvePoints.append(scaledControlAmount)
            counter += 1
        }
        return curvePoints
    }
    
    func scheduleCADTimer(seconds: Double) {
        if seconds == 0 {
            startImmediately()
        } else {
            let delayRate = (seconds / cadTimerRate)
            let frameDelay = Int(floor(delayRate))
            cadDelayTimer = CADisplayLink(target: self, selector: #selector(startFadeFromCADTimer))
            cadDelayTimer?.frameInterval = frameDelay
            cadDelayTimer?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
    }
    
    @objc func startFadeFromCADTimer() {
        let millis = NSDate().timeIntervalSince1970*1000
        print("startFadeFromCADTimer fired \(millis) - \(cadTimerIncrement) \(directionString)")
        //runs twice, once when scheduled and again at next frame, so we have to skip the first one and run the second.
        if cadTimerIncrement > 0 {
            cadDelayTimer?.invalidate()
            startImmediately()
        }
        cadTimerIncrement += 1
    }
}
