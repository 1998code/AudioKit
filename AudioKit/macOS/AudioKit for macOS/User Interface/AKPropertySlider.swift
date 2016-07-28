//
//  AKPropertySlider.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/26/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKPropertySlider: NSImageView {
    override public func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true
    }
    var callback: (Double)->()
    var initialValue: Double = 0
    public var value: Double = 0 {
        didSet {
            update()
        }
    }
    public var minimum: Double = 0
    public var maximum: Double = 0
    var property: String = ""
    var format = ""
    var color = NSColor.redColor()
    
    public init(property: String,
         format: String,
         value: Double,
         minimum: Double = 0,
         maximum: Double = 1,
         color: NSColor = NSColor.redColor(),
         frame: CGRect,
         callback: (x: Double)->()) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color
        
        self.callback = callback
        super.init(frame: frame)
        
        imageScaling = .ScaleAxesIndependently
        update()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let center = convertPoint(loc, fromView: nil)
        value = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        update()
        callback(value)
    }
    override public func mouseDragged(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let center = convertPoint(loc, fromView: nil)
        value = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        if value > maximum { value = maximum }
        if value < minimum { value = minimum }
        update()
        callback(value)
    }
    
    public func randomize() -> Double {
        value = random(minimum, maximum)
        update()
        return value
    }
    
    func update() {
        image = AKFlatSlider.imageOfFlatSlider(
            sliderColor: color,
            currentValue: CGFloat(value),
            initialValue: CGFloat(initialValue),
            minimum: CGFloat(minimum),
            maximum: CGFloat(maximum),
            propertyName: property,
            currentValueText: String(format: format, value)
        )
    }
}