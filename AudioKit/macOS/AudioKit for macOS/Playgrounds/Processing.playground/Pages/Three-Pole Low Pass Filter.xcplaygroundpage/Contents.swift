//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Three-Pole Low Pass Filter
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var filter = AKThreePoleLowpassFilter(player)

//: Set the parameters of the Moog Ladder Filter here.
filter.cutoffFrequency = 300 // Hz
filter.resonance = 0.6
filter.rampTime = 0.1

AudioKit.output = filter
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Three Pole Low Pass Filter")

        addButtons()
        
        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: filter.cutoffFrequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Resonance",
            value: filter.resonance,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.resonance = sliderValue
            })

    }

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }

    override func stop() {
        player.stop()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 400))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
