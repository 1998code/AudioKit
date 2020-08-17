// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CAudioKit

/// AudioKit Expander based on Apple's DynamicsProcessor Audio Unit
///
public class AKExpander: AKNode, AKToggleable, AUEffect, AKInput {

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper

    private var internalCompressionAmount: AudioUnitParameterValue = 0.0
    private var internalInputAmplitude: AudioUnitParameterValue = 0.0
    private var internalOutputAmplitude: AudioUnitParameterValue = 0.0

    /// Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    public var expansionRatio: AUValue = 2 {
        didSet {
            expansionRatio = (1...50).clamp(expansionRatio)
            au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        }
    }

    /// Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    public var expansionThreshold: AUValue = 2 {
        didSet {
            expansionThreshold = (1...50).clamp(expansionThreshold)
            au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        }
    }

    /// Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    public var attackDuration: AUValue = 0.001 {
        didSet {
            attackDuration = (0.000_1...0.2).clamp(attackDuration)
            au[kDynamicsProcessorParam_AttackTime] = attackDuration
        }
    }

    /// Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    public var releaseDuration: AUValue = 0.05 {
        didSet {
            releaseDuration = (0.01...3).clamp(releaseDuration)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        }
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    public var masterGain: AUValue = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    /// Compression Amount (dB) read only
    public var compressionAmount: AUValue {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    public var inputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    public var outputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    /// Dry/Wet Mix (Default 1)
    public var dryWetMix: AUValue = 1 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            inputGain.volume = 1 - dryWetMix
            effectGain.volume = dryWetMix
        }
    }

    private var mixer = AKMixer()
    private var lastKnownMix: AUValue = 1
    private var inputMixer = AKMixer()
    private var inputGain = AKMixer()
    private var effectGain = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - attackDuration: Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseDuration: Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        threshold: AUValue = -20,
        headRoom: AUValue = 5,
        expansionRatio: AUValue = 2,
        expansionThreshold: AUValue = 2,
        attackDuration: AUValue = 0.001,
        releaseDuration: AUValue = 0.05,
        masterGain: AUValue = 0,
        compressionAmount: AUValue = 0,
        inputAmplitude: AUValue = 0,
        outputAmplitude: AUValue = 0) {

        self.expansionRatio = expansionRatio
        self.expansionThreshold = expansionThreshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.masterGain = masterGain

        inputGain.volume = 0
        effectGain.volume = 1

        input?.connect(to: inputMixer)
        inputMixer.connect(to: [inputGain, effectGain])

        let effect = _Self.effect
        self.internalEffect = effect
        AKManager.engine.attach(effect)
        au = AUWrapper(effect)

        input?.connect(to: inputMixer)
        inputMixer >>> inputGain >>> mixer
        inputMixer >>> effectGain >>> effect >>> mixer

        super.init(avAudioNode: mixer.avAudioNode)

        au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        au[kDynamicsProcessorParam_AttackTime] = attackDuration
        au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        au[kDynamicsProcessorParam_MasterGain] = masterGain
    }

    public var inputNode: AVAudioNode {
        return inputMixer.avAudioNode
    }
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }

    /// Disconnect the node
    public override func detach() {
        stop()

        AKManager.detach(nodes: [inputGain.avAudioNode, effectGain.avAudioNode, mixer.avAudioNode])
        AKManager.engine.detach(self.internalEffect)
    }
}
