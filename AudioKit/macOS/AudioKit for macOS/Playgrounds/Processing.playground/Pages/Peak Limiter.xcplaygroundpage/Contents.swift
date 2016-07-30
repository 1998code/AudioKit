//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Peak Limiter
//: ### A peak limiter will set a hard limit on the amplitude of an audio signal.
//: ### They're espeically useful for any type of live input processing, when you
//: ### may not be in total control of the audio signal you're recording or processing.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var peakLimiter = AKPeakLimiter(player)

//: Set the parameters here
peakLimiter.attackTime = 0.001 // Secs
peakLimiter.decayTime = 0.01 // Secs
peakLimiter.preGain = 10 // dB

AudioKit.output = peakLimiter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Peak Limiter")

        addButtons()

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Attack Time",
            format:  "%0.3f s",
            value: peakLimiter.attackTime, minimum: 0.001, maximum: 0.03,
            color: AKColor.greenColor()
        ) { sliderValue in
            peakLimiter.attackTime = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Decay Time",
            format:  "%0.3f s",
            value: peakLimiter.decayTime, minimum: 0.001, maximum: 0.03,
            color: AKColor.greenColor()
        ) { sliderValue in
            peakLimiter.decayTime = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Pre-gain",
            format:  "%0.1f dB",
            value: peakLimiter.preGain, minimum: -40, maximum: 40,
            color: AKColor.greenColor()
        ) { sliderValue in
            peakLimiter.preGain = sliderValue
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

    func process() {
        peakLimiter.start()
    }

    func bypass() {
        peakLimiter.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
