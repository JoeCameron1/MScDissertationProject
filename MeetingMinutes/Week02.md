# Week 2 Meeting Minutes - 01/06/2022
## Participants: Joseph Cameron (Me), Ian Miguel, Kenneth Boyd

The meeting started with some feedback from Ken and Ian on my progress after the first week.
First, we talked about the initial draft of objectives that I had outlined for the project.
The feedback was very positive overall, and both Ian and Ken commented that the objectives should naturally become more refined and specific as the project progresses.
Furthermore, Ken suggested that I add an additional secondary objective that relates to providing some sort of design recommendations for anyone looking to design a similar system in the future.
I agreed with this and updated my project's secondary objectives to include the goal of providing a collection of design recommendations.

Secondly, we discussed the dissertation structure I had provided and its overall suitability.
Overall, both Ken and Ian thought the structure looked very good, with Ken suggesting that I could perhaps add a section in the Literature Review chapter that is dedicated to discussing previous and related work on interactions with musical interactions and the feedback that users get from musical instruments.
Ian also suggested that this section could be extended to also look at existing electronic hardware and software with interesting interactions, such as the Theremin, Breath Controller, Ribbon Controller, sustain pedals, Air FX controller, and so on.
I thought this was a great idea, and updated the Literature Review chapter structure to include this.

Next, our attention turned towards the core implementation that is required to have a working MIDI controller protoype for users to interact with in future studies.
We all agreed that it would be especially important to develop a system that delivers real-time, or close to real-time, feedback from user inputs via gesture interactions etc.
I suggested that the best way for this to work would be to create a pipeline to a digital audio workstation (DAW), such as Logic, so that user inputs can be transformed to MIDI data and sent directly to Logic and then plays sounds within Logic.
The advantage of this would be the robustness and array of sounds available to a user.
The power of a DAW like Logic should be harnessed and not simply recreated in this project, as I would rather focus on user interactions over implementing features that already exist.

To conclude the meeting, we agreed that I would have two main goals to achieve over week 2.
The first goal would be to complete the desription, objectives, ethics, and resources document (DOER) that is due as a deliverable on the following Monday (06/06/2022).
The second goal involved making a "proof of concept" prototype whereby I can demonstrate that it is possible to make some sort of application that can take input gestures from the Leap Motion controller and then play sounds in Logic via MIDI messages in real time.
