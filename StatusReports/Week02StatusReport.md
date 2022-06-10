# Week 2 Status Report

Over the past week, I have achieved the goals set up at the end of our previous meeting.

I completed and handed in the DOER document on time to MMS and figured out the ethics procedure.
Following on from this topic, I also spent a good amount of time this week conducting a small literature review on some influential papers in music technology, as preparation for the “Plan & Context Survey” slot I saw on MMS.
These papers include the original paper on what would become MIDI by Dave Smith and Chet Wood called “The Universal Synthesizer Interface”, and an interesting paper on the “Dysfunction of MIDI” by F. Richard Moore to help give some motivational points for my new MIDI Controller.
Furthermore, I found some similar related work to my touch-free interaction ideas within MIDI controllers in the form of the GECO MIDI and AeroMIDI applications.
These applications differ from my idea because they primarily focus on altering audio effects.
I’m going to be focusing on both composition and audio effects.
However, these applications are still very relevant applications to refer to.
 
The other big goal I achieved this week was that I managed to figure out how to create MIDI events in Logic Pro X in real time with only a Leap Motion controller!
To do this, I use Processing along with its MIDIBus and LeapMotion libraries to create the MIDI controller application, and I use the native Audio MIDI Setup macOS app to set up the MIDI bus that Processing uses to send/receive information.
Currently, I can trigger MIDI notes to play based on finger position and gestures read by the Leap Motion Controller.
This will be a big area of expansion and exploration in the coming weeks.
I’m relieved that this is possible to do in Processing, as it will allow much more efficient development for me to create a custom user interface, and users will get real-time feedback from the Logic DAW and its wide range of capabilities and sounds.
