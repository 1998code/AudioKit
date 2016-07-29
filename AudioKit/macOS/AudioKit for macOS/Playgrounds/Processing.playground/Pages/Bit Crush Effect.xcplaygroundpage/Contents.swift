//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Bit Crush Effect
//: ### An audio signal consists of two components, amplitude and frequency.
//: ### When an analog audio signal is converted to a digial representation, these
//: ### two components are stored by a bit-depth value, and a sample-rate value.
//: ### The sample-rate represents the number of samples of audio per second, and the
//: ### bit-depth represents the number of bits used capture that audio. The bit-depth
//: ### specifies the dynamic range (the difference between the smallest and loudest
//: ### audio signal). By changing the bit-depth of an audio file, you can create
//: ### rather interesting digital distortion effects.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var bitcrusher = AKBitCrusher(player)

//: Set the parameters of the bitcrusher here
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3333

AudioKit.output = bitcrusher
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    var bitDepthLabel: Label?
    var sampleRateLabel: Label?

    override func setup() {
        addTitle("Bit Crusher")

        addButtons()
        
        addSubview(AKPropertySlider(
            property: "Bit Depth",
            format: "%0.2f",
            value: bitcrusher.bitDepth, minimum: 1, maximum: 24,
            color: AKColor.greenColor()
        ) { sliderValue in
            bitcrusher.bitDepth = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Sample Rate",
            format: "%0.1f Hz",
            value: bitcrusher.sampleRate, maximum: 16000,
            color: AKColor.redColor()
        ) { sliderValue in
            bitcrusher.sampleRate = sliderValue
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

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
