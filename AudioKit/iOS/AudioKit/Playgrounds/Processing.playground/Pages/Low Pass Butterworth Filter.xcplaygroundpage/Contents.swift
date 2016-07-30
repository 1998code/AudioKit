//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Butterworth Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the
//: ### high-frequency components of the audio signal, allowing for the
//: ### lower frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKLowPassButterworthFilter(player)
filter.cutoffFrequency = 500 // Hz

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Pass Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: filter.cutoffFrequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
            })
    }


    func process() {
        filter.start()
    }

    func bypass() {
        filter.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
