# Week 1 Meeting Minutes - 24/05/2022
## Participants: Joseph Cameron (Me), Ian Miguel, Kenneth Boyd

This was the first meeting for the entire MSc dissertation project, so it was mainly introductory in nature.

The main topics of conversation were to further establish specific goals and aims of the project in order to gain an appropriate project scope, and to decide organisational/administrative details of the project.

First, I opened the meeting by stating that I would like to explore the possibility of designing a new MIDI editor that enables new, more intuitive interactions for both musicians and non-musicians to best exploit the capabilities of the MIDI protocol.
The overall aim here is to allow both musicians and non-musicians to better express their musical creativity through technology that they may otherwise be unaware of.
Next, I went on to explain my new interaction idea that I call "Conductor Interaction".
Essentially, "Conductor Interaction" is a style of interaction where I would allow users to wave their hands in the air and make gestures to perform actions.
The user's hands would be tracked with an [Ultraleap Leap Motion Controller](https://www.ultraleap.com/product/leap-motion-controller/).
The location of the hands could correspond to the musical note, and the gestures could correspond to actions such as play, enter note etc.
For example, a tap gesture could indicate that the user wants to play that note.
Furthermore, the notes available to users could be restricted by musical key, to help enable users to play nice, organic sounding melodies.
To enable user customisation, I also explained that it could be a good idea to provide both horizontal positioning and vertical positioning for finger locations in mid-air, depending on the user's preference.
Ken and Ian both responded positively to the idea of enabling new interactions for users, and particularly the idea of tracking subtleties in users' hands with the Leap Motion controller.

At this point Ken then raised a very good point about the project's goals for different user groups and enabling different user groups to all get something useful out of a new MIDI editor.
Initially, I can see two major user groups for this project.
Those groups are musicians and non-musicians.
* For the non-musicians, a major goal would be to get them more comfortable developing melodies and expressing themselves musically with natural intuitive interactions.
Currently, MIDI input is very focused towards interactions that directly resemble playing real musical instruments or require an innate talent for people to draw melodies from scratch.
Hence, it would be nice to enable users who don't play real musical instruments to play instruments and keep track of melodies via MIDI through an interaction such as my "Conductor Interaction" mentioned above.
This would also massively expand the reach of music production technology in general through MIDI, and diversify MIDI interactions to include non-musicians and users without knowledge of music theory.
* For musicians, I would want to make musicians far more aware of the full capability of MIDI that they may not have considered otherwise.
For example, the MIDI protocol can allow the pitch of individual notes to be altered (bent) during play, this is something classical piano players may not be familiar with in everyday play with a traditional piano.

Next, Ian mentioned that it is very important to consider the technology required to build my MIDI editor.
For example, do I want to create a stand-alone editor with its own inbuilt sounds, or do I want to create an interface to Logic Pro etc.?
At this point, Ian also suggested that I look up [Max](https://cycling74.com/products/max), a visual programming language/software suite for music and multimedia.
This will be one of my goals for week 1.

Ken and myself then had some discussion regarding the studies that I would perform for the user-centred interaction design process of this project.
I suggested that I could undertake interviews and observation studies with users, and we both agreed that having a handful of participants would be more than adequate.
The first study to gain user requirements would involve understanding what users need/like/dislike from/about MIDI editors.
The second study would be an evaluation study of my MIDI editor and its accompanying interactions designed and built based upon findings from the first study.
The studies could also include activities, such as asking users to recreate melodies that are played to them within a MIDI editor etc.
For activities such as this, it may be good to also provide the sheet music to fully include all the abilities of potential users.
Ken stressed that the details of the studies can be decided at a later point and that it's more important to figure the technological feasibility of my MIDI editor initially.
However, he also liked my initial ideas for the studies. 

Next, details of project management were discussed. 
I stated that I very much would like to keep track of meeting notes from which a clear set of goals for the following week could be made and communicated at the end of meetings.
I also said that I would like to provide short status reports to both Ian and Ken before every weekly supervision meeting to help keep all of us up to date on my current progress so far.
Ian and Ken were both very supportive of these ideas and commented on the importance of the good organisation it should enable.
We decided that I should email this status report the evening before every weekly supervision meeting. 
I also mentioned that I would like to keep a log of the project's work, noting the date, hours and a short summary of work achieved for a certain week.
It's hoped that this will help me to fully understand all elements of my project and enable a smoother writing process for the dissertation report.
To wrap up project management, I then stated that I will use version control for this project, and that I would setup and use a Git repository for the project.
Again, Ian and Ken were fully onboard with these ideas.

To wrap up the meeting, we discussed what the goals of week 1 are.
Ken and Ian both sent me some very useful resources to look over, which I will do over the next week.
I will also research some more background literature on the MIDI protocol and its details.
Importantly, over the next week I will also create and test some basic prototypes of MIDI editors on Processing/Java and/or Max to get a much better sense of the technological feasibility/scope on offer with this project.
This should also help me to narrow down on some specific goals and objectives for this project to mention in the DOER (Description, Objectives, Ethics, Resources) report due on 06/06/2022.
It was then established that the final goal of week 1 would be for me to create a Git repository, host it on GitHub, and then setup the project file structure of the project software, meeting minutes/project log etc.

Finally, it was decided between the three of us that a regular meeting time would be arranged later, perhaps in week 2.
