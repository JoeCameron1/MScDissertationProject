# Week 3 Meeting Minutes - 09/06/2022
## Participants: Joseph Cameron (Me), Ian Miguel, Kenneth Boyd, Xu Zhu

The meeting started with a review of the “proof of concept” prototype that I made over week 2, where I use gestures sensed by the Leap Motion controller to send the correct corresponding MIDI message to Logic to play sounds in real-time.
Ian mentioned that this is a very good milestone to reach in the project as I can now focus on developing the interactions and so on, now that the core functionality of a MIDI pipeline is set up between my application and a DAW.
Ian also said that I should comment on the robustness this allows within my dissertation report when talking about my implementation in the implementation chapter, as it can theoretically work on any DAW system, as long as the DAW can recognise the MIDI channel that is created using the native Audio MIDI Setup app on Mac.
Furthermore, the fact that I use the Audio MIDI Setup app, which is a native application to macOS, to setup the MIDI bus is also a strength of the system as you don’t have to download any additional software.
Ian suggested that the next thing I should look at doing on the implementation side of the project is to try and trigger actions such as record (start, stop) and the playback functions (rewind, fast forward etc.) in the same fashion as playing sounds (like I'm doing so far), as this would then allow users to start having control over MIDI sections.
We agreed that it would be a good idea to implement these over the next week, and I added that these actions along with the development of a basic edit function (such as adjusting the pitch of an existing MIDI note) would encompass a very complete set of controls for users to manipulate.

Ian and I then started to talk about the upcoming Plan & Context Survey deliverable due on the following Monday (13/06/2022).
We then agreed that it would be a good idea to add a chapter to my Literature Review (which is due in the Plan & Context Survey) that talks about Music Theory and how it maps to MIDI.
I agreed, and suggested that I should talk about chords, keys, and musical scales etc. and how velocity/pitch in MIDI matches musical notation etc.
This also prompted me to think about including a side by side diagram of a basic musical score and its MIDI piano roll counterpart to illustrate this.
Ian also suggested taking Ken’s idea for the interaction with musical instruments section and add a section, or create an entirely new section, called “A brief history of interfaces to create music/music controllers” that would present a timeline of technology available for music production.
This section could include hardware (Theremin to GECO MIDI) and software (DAWs).

Next, myself, Ken, and Xu discussed possibilities for the user interface of the music creation application/controller that I will create.
One of my goals is to enable customisations for users, and Ken suggested that this could include levels for the complexity of features of the MIDI controller available to users, such as "Easy", "Intermediate", and "Advanced".
Based on this concept, I ideated that the "Easy" option could allow only a few notes and/or moods to be played/selected and then each increasing level of difficulty includes more and more complexity, detail, and options.
This covers the "Play vs Learn Concept”.

Next, myself, Ken, and Xu then discussed a plan for starting my initial user study to gain user requirements.
We agreed that it would be best for me to start recruiting participants now, and to have a handful of people ready to take part within the next 2 weeks.
We also agreed that I should have a plan/script of questions and activities for users to answer and take part in during the studies.
I suggested that I would have some example questions and activities for the study ready by Wednesday next week (15/06/2022) and then we could review the questions and activities on either Thursday or Friday.

To wrap up the meeting we all confirmed that my goals over the next week are to:
* Complete the Plan & Context Survey Deliverable due on the 13/06/2022. This includes completing an initial draft of the Literature Review.
* Experiment with allowing interactions that start, stop, rewind, and fast-forward playback in my MIDI controller prototype.
* Experiment with allowing interactions that start/stop recording user-inputs as sections of MIDI and enable sections of MIDI to be looped in my MIDI controller prototype.
* Update my prototype to include the options of "Easy", "Intermediate", and "Advanced" for differing levels of complexity and detail.
* Complete an initial draft of questions and activities to ask and present to participants of the user study for gathering user requirements.
