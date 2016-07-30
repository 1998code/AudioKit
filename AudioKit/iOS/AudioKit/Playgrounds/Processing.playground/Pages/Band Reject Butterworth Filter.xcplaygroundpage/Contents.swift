//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Band Reject Butterworth Filter

import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a band pass filter
var filter = AKBandRejectButterworthFilter(player)

//: Set the parameters of the band pass filter here
filter.centerFrequency = 5000 // Hz
filter.bandwidth = 600  // Cents

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Band Reject Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Center Frequency",
            format: "%0.1f Hz",
            value: filter.centerFrequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.centerFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Bandwidth",
            format: "%0.1f Hz",
            value: filter.bandwidth, minimum: 100, maximum: 12000,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.bandwidth = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView(height: 550)

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
