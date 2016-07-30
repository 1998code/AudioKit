//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Formant Filter
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKFormantFilter(player)

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Formant Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Center Frequency",
            format: "%0.1f Hz",
            value: filter.centerFrequency, maximum: 8000,
            color: AKColor.yellowColor()
        ) { sliderValue in
            filter.centerFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: filter.attackDuration, maximum: 0.1,
            color: AKColor.greenColor()
        ) { duration in
            filter.attackDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Decay",
            format: "%0.3f s",
            value: filter.decayDuration, maximum: 0.1,
            color: AKColor.cyanColor()
        ) { duration in
            filter.decayDuration = duration
            })

    }

    func process() {
        filter.play()
    }

    func bypass() {
        filter.bypass()
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 750))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
