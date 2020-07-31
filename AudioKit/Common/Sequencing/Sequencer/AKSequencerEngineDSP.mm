// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#include "AKSequencerEngineDSP.hpp"

AKDSPRef createAKSequencerEngineDSP() {
    return new AKSequencerEngineDSP();
}

 void sequencerEngineAddMIDIEvent(AKDSPRef dsp, uint8_t status, uint8_t data1, uint8_t data2, double beat) {
    ((AKSequencerEngineDSP*)dsp)->addMIDIEvent(status, data1, data2, beat);
}

 void sequencerEngineAddMIDINote(AKDSPRef dsp, uint8_t noteNumber, uint8_t velocity, double beat, double duration) {
    ((AKSequencerEngineDSP*)dsp)->addMIDINote(noteNumber, velocity, beat, duration);
}

 void sequencerEngineRemoveMIDIEvent(AKDSPRef dsp, double beat) {
    ((AKSequencerEngineDSP*)dsp)->removeEventAt(beat);
}

 void sequencerEngineRemoveMIDINote(AKDSPRef dsp, double beat) {
    ((AKSequencerEngineDSP*)dsp)->removeNoteAt(beat);
}

 void sequencerEngineRemoveSpecificMIDINote(AKDSPRef dsp, double beat, uint8_t noteNumber) {
    ((AKSequencerEngineDSP*)dsp)->removeNoteAt(noteNumber, beat);
}

 void sequencerEngineRemoveAllInstancesOf(AKDSPRef dsp, uint8_t noteNumber) {
    ((AKSequencerEngineDSP*)dsp)->removeAllInstancesOf(noteNumber);
}

 void sequencerEngineStopPlayingNotes(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->stopPlayingNotes();
}

 void sequencerEngineClear(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->clear();
}

 void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit) {
    ((AKSequencerEngineDSP*)dsp)->setTargetAU(audioUnit);
}

#endif
