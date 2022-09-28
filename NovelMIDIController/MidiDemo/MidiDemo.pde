// The Novel MIDI Controller Application
// MSc Dissertation Project - University of St Andrews (2021-2022)
// Author = Joseph Manfredi Cameron
// -----------------------------------------------------------------------------------

// IMPORT STATEMENTS

import themidibus.*;

import de.voidplus.leapmotion.*;

import java.io.File;
import java.io.IOException;

import javax.swing.JFileChooser;

import javax.sound.midi.InvalidMidiDataException;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Sequence;
import javax.sound.midi.Sequencer;
import javax.sound.midi.*;

import controlP5.*;

// -----------------------------------------------------------------------------------

// GLOBAL VARIABLES
boolean mainMenu, liveMode, editorMode;

// MidiBus object that controls communication between Processing and DAW (Logic Pro X)
MidiBus myBus;

// The Leap Motion Controller
LeapMotion leap;

// ControlP5
ControlP5 controlP5;
DropdownList selectMusicalKey;
RadioButton notesChordsToggle;
RadioButton composeDeleteEditToggle;
boolean compose, delete, edit;
Button exportToMIDIFile;
Button loadFromMIDIFile;
Button goLiveMode;
Button goEditorMode;
Button goMainMenu;
Knob tempoKnob;

// Int that tracks what musical key is selected
int selectedMusicalKey;

// Booleans that control notes and chords modes
boolean notes;
boolean chords;
boolean pitchBend;

static int noteOffset = 48;

// Ensures only valid notes/chords are played in live mode
boolean[] active = new boolean[128];

float indexFingerXAxis;
float indexFingerYAxis;

float fingerTipDisplayX;
float fingerTipDisplayY;

InterfaceKeyboard interfaceKeyboard;

// Keeps track of notes on/off in Live Mode
// Current MIDI Note for notes mode
MIDINote currentMIDINote;
// Current MIDI Chord for chords mode
MIDIChord currentMIDIChord;

// Water Ripple Visualisation
int cols;
int rows;
float[][] current;
float[][] previous;
float rippleMagnitude = .9;
int index = 0;

// Tracks pinching gestures
boolean isPinching = false;

// MIDI Editor Variables
Sequencer sequencer;
Sequence sequence;
Track track; // Track that holds top melody notes
Track chordsTrack; // Track that holds chords
Track pitchBendTrack; // Track that holds pitch bend messages
int currentPitchBendEditTick;
boolean playing;

// -----------------------------------------------------------------------------------

void setup() {
  
  // Setup Application Window
  size(1152, 700);
  
  // Setup Application State Booleans
  mainMenu = true;
  liveMode = false;
  editorMode = false;
  
  // Setup MIDI Bus to Logic
  MidiBus.list(); // Prints list of available MIDI devices/ports
  // From MidiBus.list(), we know that the index for the output is 2
  myBus = new MidiBus(this, -1, 2, "Processing to DAW");
  
  // Setup LeapMotion Controller
  leap = new LeapMotion(this).allowGestures();
  
  // Setup MIDI Editor
  setupMidiEditor();
  
  // Default Notes Mode
  notes = true;
  chords = false;
  pitchBend = false;
  
  // ControlP5
  // LIVE MODE
  // Musical Key Dropdown List
  controlP5 = new ControlP5(this);
  selectMusicalKey = controlP5.addDropdownList("Select Key", 285, 10, 100, 100);
  formatMusicalKeyDropdownList(selectMusicalKey);
  selectedMusicalKey = 0;
  // Notes/Chords Radiobutton Toggle
  notesChordsToggle = controlP5.addRadioButton("notesChordsRadioButton")
                                 .setPosition(500, 20)
                                 .addItem("Notes", 0)
                                 .addItem("Chords", 1)
                                 .addItem("Pitch Bend", 2)
                                 .setItemHeight(20)
                                 .setItemWidth(20)
                                 .setItemsPerRow(3)
                                 .setSize(30,30)
                                 .setSpacingColumn(50)
                                 .activate(0);
  // EDITOR MODE
  // Notes/Chords Radiobutton Toggle
  composeDeleteEditToggle = controlP5.addRadioButton("composeDeleteEditRadioButton")
                                 .setPosition(815, 20)
                                 .addItem("Compose", 0)
                                 .addItem("Delete", 1)
                                 .addItem("Edit", 2)
                                 .setItemHeight(20)
                                 .setItemWidth(20)
                                 .setItemsPerRow(3)
                                 .setSize(30,30)
                                 .setSpacingColumn(50)
                                 .activate(0);
  exportToMIDIFile = controlP5.addButton("exportMIDI").setPosition(90, 10).setLabel("Export MIDI").setSize(75,50);
  loadFromMIDIFile = controlP5.addButton("loadMIDI").setPosition(170, 10).setLabel("Load MIDI").setSize(75,50);
  goLiveMode = controlP5.addButton("goLiveMode").setPosition((width/2)-150, (height/2)-100).setLabel("Live Mode").setSize(300,150);
  goEditorMode = controlP5.addButton("goEditorMode").setPosition((width/2)-150, (height/2)+100).setLabel("Editor Mode").setSize(300,150);
  goMainMenu = controlP5.addButton("goMainMenu").setPosition(10, 10).setLabel("Main Menu").setSize(75,50); // MAKE THIS AN IMAGE OF HOME INSTEAD?
  tempoKnob = controlP5.addKnob("tempoKnob")
                         .setRange(50, 200)
                         .setValue(128)
                         .setPosition(width-60, 10)
                         .setRadius(20)
                         .setNumberOfTickMarks(150)
                         .snapToTickMarks(true)
                         .setDragDirection(Knob.HORIZONTAL)
                         .setLabel("Tempo (BPM)");
  
  // Draws correct info to the screen depending on modes selected
  interfaceKeyboard = new InterfaceKeyboard(0); // C Major scale is 0
  
  // Water Ripple Visualisation Setup
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  
}

void draw() {
  if (liveMode) {
    background(255);
    
    // -------------
    // Water Ripples
    loadPixels();
    for (int i = 1; i < cols - 1; i++) {
      for (int j = 1; j < rows - 1; j++) {
  
        current[i][j] = (previous[i-1][j] + previous[i+1][j] + previous[i][j-1] + previous[i][j+1]) / 2 - current[i][j];
        current[i][j] = current[i][j] * rippleMagnitude;
        
        int index = i + j * cols;
        pixels[index] = color(current[i][j] * 255);
      }
    }
    updatePixels();
    
    float[][] temp = previous;
    previous = current; 
    current = temp;
    // -------------
    
    fill(255);
    textAlign(LEFT);
    
    for (Hand hand : leap.getHands ()) {
      indexFingerXAxis = hand.getIndexFinger().getRawPositionOfJointTip().x;
      indexFingerYAxis = hand.getIndexFinger().getRawPositionOfJointTip().y;
      
      // Key finger tips within bounds, prevents exceptions being thrown
      if (indexFingerYAxis >= 399) {
        indexFingerYAxis = 399;
      } else if (indexFingerYAxis <= 50) {
        indexFingerYAxis = 50;
      }
      
      // Draw Finger Tip
      fingerTipDisplayX = indexFingerXAxis + (width/2);
      fingerTipDisplayY = height - indexFingerYAxis;
      circle(fingerTipDisplayX, fingerTipDisplayY, 20);
      
      // Pinch Gesture
      if (isPinching) {
        if (hand.getPinchStrength() < .07) {
          pinchReleased();
          isPinching = false;
        } else {
          pinchMoved(indexFingerXAxis, indexFingerYAxis);
        }
      } else {
        if (hand.getPinchStrength() > .07) {
          pinchStarted();
          isPinching = true;
        }
      }
    }
    
    // Draw Keyboard
    interfaceKeyboard.draw();
    
    // Draw Instructions
    fill(255, 0, 0);
    rect(0, 650, width, 50);
    fill(255);
    
    // Show the live mode buttons
    selectMusicalKey.show();
    notesChordsToggle.show();
    goMainMenu.show();
    
    // Finally, hide the editor mode buttons and main menu buttons
    composeDeleteEditToggle.hide();
    exportToMIDIFile.hide();
    loadFromMIDIFile.hide();
    goLiveMode.hide();
    goEditorMode.hide();
    tempoKnob.hide();
    
  } else if (editorMode) {
    // EDITOR MODE GUI
    background(0);
    drawNotesGrid();
    drawChordsGrid();
    drawPitchBendGrid();
    stroke(100);
    strokeWeight(4);
    line(0, 70, width, 70);
    line(width-85, 0, width-85, 70);
    line(775, 0, 775, 70);
    line(460, 0, 460, 70);
    line(255, 0, 255, 70);
    strokeWeight(1);
    stroke(0);
    if (notes) {
      stroke(255,0,0);
      strokeWeight(4);
      line(0, 95, width, 95);
      line(0, 255, width, 255);
      strokeWeight(1);
      stroke(0);
    } else if (chords) {
      stroke(255,0,0);
      strokeWeight(4);
      line(0, 295, width, 295);
      line(0, 455, width, 455);
      strokeWeight(1);
      stroke(0);
    } else if (pitchBend) {
      stroke(255,0,0);
      strokeWeight(4);
      line(0, 495, width, 495);
      line(0, 655, width, 655);
      strokeWeight(1);
      stroke(0);
    }
    // Draw Keyboard
    interfaceKeyboard.draw();
    drawNotes();
    drawChords();
    drawPitchBends();
    drawNotesPlayback();
    drawChordsPlayback();
    drawPitchBendPlayback();
    if (sequencer.isRunning()) {
      textAlign(CENTER);
      text("Space Bar = Pause", width/2, height-15);
      textAlign(LEFT);
      strokeWeight(4);
      line((width/2)-3, height-35, (width/2)-3, height-25);
      line((width/2)+3, height-35, (width/2)+3, height-25);
      strokeWeight(1);
    } else {
      textAlign(CENTER);
      text("Space Bar = Play", width/2, height-15);
      textAlign(LEFT);
      triangle((width/2)-4, height-35, (width/2)-4, height-25, (width/2)+4, height-30);
    }
    
    for (Hand hand : leap.getHands ()) {
      indexFingerXAxis = hand.getPalmPosition().x;
      indexFingerYAxis = hand.getPalmPosition().y;
      
      // Key finger tips within bounds, prevents exceptions being thrown
      if (indexFingerYAxis >= 599) {
        indexFingerYAxis = 599;
      } else if (indexFingerYAxis <= 50) {
        indexFingerYAxis = 50;
      }
      if (indexFingerXAxis >= 1000) {
        indexFingerXAxis = 1000;
      } else if (indexFingerXAxis <= 400) {
        indexFingerXAxis = 400;
      }
      
      // Draw Finger Tip
      fingerTipDisplayX = map(indexFingerXAxis, 400, 1000, 0, 1152);
      if (notes) {
        fingerTipDisplayY = map(indexFingerYAxis, 50, 599, 90, 260);
      } else if (chords) {
        fingerTipDisplayY = map(indexFingerYAxis, 50, 599, 290, 460);
      } else if (pitchBend) {
        fingerTipDisplayY = map(indexFingerYAxis, 50, 599, 500, 650);
      }
      
      // Pinch Gesture
      if (isPinching) {
        if (hand.getPinchStrength() < .07) {
          pinchReleased();
          isPinching = false;
        } else {
          pinchMoved(indexFingerXAxis, indexFingerYAxis);
        }
      } else {
        if (hand.getPinchStrength() > .07) {
          pinchStarted();
          isPinching = true;
        }
      }
    }
    
    // Draw Hand Location
    stroke(0); // This is to see hand location when hovering over notes
    circle((int) fingerTipDisplayX, (int) fingerTipDisplayY, 5);
    
    // Show the editor buttons
    selectMusicalKey.show();
    notesChordsToggle.show();
    composeDeleteEditToggle.show();
    exportToMIDIFile.show();
    loadFromMIDIFile.show();
    goMainMenu.show();
    tempoKnob.show();
    
    // Hide the main menu buttons
    goLiveMode.hide();
    goEditorMode.hide();
    
  } else if (mainMenu) {
    
    // MAIN MENU GUI
    background(0);
    
    // Title
    textSize(36);
    textAlign(CENTER);
    text("The Novel MIDI Controller", width/2, 150);
    textSize(12);
    textAlign(LEFT);
    
    // Show the main menu buttons
    goLiveMode.show();
    goEditorMode.show();
    
    // Hide the live mode and editor mode buttons
    selectMusicalKey.hide();
    notesChordsToggle.hide();
    composeDeleteEditToggle.hide();
    exportToMIDIFile.hide();
    loadFromMIDIFile.hide();
    goMainMenu.hide();
    tempoKnob.hide();
  }
  
}

void goLiveMode() {
  mainMenu = false;
  liveMode = true;
  editorMode = false;
}

void goEditorMode() {
  mainMenu = false;
  liveMode = false;
  editorMode = true;
}

void goMainMenu() {
  mainMenu = true;
  liveMode = false;
  editorMode = false;
}

// Called when a user initiates a pinch gesture
void pinchStarted() {
  //println("Pinch Started");
  if (liveMode) {
    if (notes) {
      int midiPitch;
      switch (selectedMusicalKey) {
        case 0:
          midiPitch = getCMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 1:
          midiPitch = getCMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 2:
          midiPitch = getCSharpMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 3:
          midiPitch = getCSharpMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 4:
          midiPitch = getDMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 5:
          midiPitch = getDMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 6:
          midiPitch = getDSharpMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 7:
          midiPitch = getDSharpMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 8:
          midiPitch = getEMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 9:
          midiPitch = getEMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 10:
          midiPitch = getFMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 11:
          midiPitch = getFMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 12:
          midiPitch = getFSharpMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 13:
          midiPitch = getFSharpMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 14:
          midiPitch = getGMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 15:
          midiPitch = getGMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 16:
          midiPitch = getGSharpMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 17:
          midiPitch = getGSharpMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 18:
          midiPitch = getAMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 19:
          midiPitch = getAMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 20:
          midiPitch = getASharpMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 21:
          midiPitch = getASharpMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 22:
          midiPitch = getBMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        case 23:
          midiPitch = getBMinorScaleNote(indexFingerXAxis, indexFingerYAxis);
          break;
        default:
          midiPitch = getCMajorScaleNote(indexFingerXAxis, indexFingerYAxis);
      }
      
      if (!active[midiPitch]) {
        active[midiPitch] = true;
        myBus.sendNoteOn(1, midiPitch, 127);
        println("Note On");
        // Set current MIDI Note to one that is playing
        currentMIDINote = new MIDINote(1, midiPitch, 127);
      }
    } else if (chords) {
      int[] midiPitches = new int[3];
      switch (selectedMusicalKey) {
        case 0:
          midiPitches = getCMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 1:
          midiPitches = getCMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 2:
          midiPitches = getCSharpMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 3:
          midiPitches = getCSharpMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 4:
          midiPitches = getDMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 5:
          midiPitches = getDMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 6:
          midiPitches = getDSharpMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 7:
          midiPitches = getDSharpMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 8:
          midiPitches = getEMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 9:
          midiPitches = getEMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 10:
          midiPitches = getFMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 11:
          midiPitches = getFMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 12:
          midiPitches = getFSharpMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 13:
          midiPitches = getFSharpMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 14:
          midiPitches = getGMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 15:
          midiPitches = getGMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 16:
          midiPitches = getGSharpMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 17:
          midiPitches = getGSharpMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 18:
          midiPitches = getAMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 19:
          midiPitches = getAMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 20:
          midiPitches = getASharpMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 21:
          midiPitches = getASharpMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 22:
          midiPitches = getBMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        case 23:
          midiPitches = getBMinorScaleChord(indexFingerXAxis, indexFingerYAxis);
          break;
        default:
          midiPitches = getCMajorScaleChord(indexFingerXAxis, indexFingerYAxis);
      }
      
      if (!active[midiPitches[0]]) {
        active[midiPitches[0]] = true;
        myBus.sendNoteOn(1, midiPitches[0], 127);
        println("Note On");
      }
      if (!active[midiPitches[1]]) {
        active[midiPitches[1]] = true;
        myBus.sendNoteOn(1, midiPitches[1], 127);
        println("Note On");
      }
      if (!active[midiPitches[2]]) {
        active[midiPitches[2]] = true;
        myBus.sendNoteOn(1, midiPitches[2], 127);
        println("Note On");
      }
      currentMIDIChord = new MIDIChord(1, midiPitches, 127);
    } else if (pitchBend) {
      // Map Finger Value to 0 to 16383
      int pitchBendValue = (int) map(indexFingerYAxis, 50, 399, 0, 16383);
      myBus.sendMessage(224, pitchBendValue % 128, pitchBendValue / 128);
    }
    
    // Draw Water Ripple
    drawWaterRipple(fingerTipDisplayX, fingerTipDisplayY);
  
  } else if (editorMode) {
    if (compose && notes) {
      // If hand is in notes zone
      if ((fingerTipDisplayY >= 100) && (fingerTipDisplayY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
        }
        
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addNote(midiPitch, tick);
      }
      
    } else if ((delete && notes) || (edit && notes)) {
      if ((fingerTipDisplayY >= 100) && (fingerTipDisplayY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
        }
        
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        for (int i = 0; i < track.size(); i++) {
          if ((track.get(i).getMessage().getMessage()[1] == midiPitch) && ((track.get(i).getTick() == tick) || (track.get(i).getTick() == tick-1))) {
            track.remove(track.get(i));
          }
        }
      }
    } else if (compose && chords) {
      if ((fingerTipDisplayY >= 300) && (fingerTipDisplayY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
        }
        
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addChord(midiPitches, tick);
      }
      
    } else if ((delete && chords) || (edit && chords)) {
      if ((fingerTipDisplayY >= 300) && (fingerTipDisplayY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
        }
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        ArrayList<MidiEvent> notesToRemove = new ArrayList<MidiEvent>();
        for (int i = 0; i < chordsTrack.size(); i++) {
          if (((chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[0]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[1]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[2])) && ((chordsTrack.get(i).getTick() == tick) || (chordsTrack.get(i).getTick() == tick-1))) {
            notesToRemove.add(chordsTrack.get(i));
          }
        }
        for (int j = 0; j < notesToRemove.size(); j++) {
          // Remove all notes that make up the chord
          chordsTrack.remove(notesToRemove.get(j));
        }
      }
    } else if (compose && pitchBend) {
      int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
      int pitchBendValue = (int) map(fingerTipDisplayY, 650, 500, 0, 16383);
      addPitchBend(pitchBendValue, tick);
    } else if (delete && pitchBend) {
      int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
      for (int i = 0; i < pitchBendTrack.size(); i++) {
        if ((pitchBendTrack.get(i).getTick() == tick) && (((pitchBendTrack.get(i).getMessage().getMessage()[2] * 128) + pitchBendTrack.get(i).getMessage().getMessage()[1]) != 8192)) {
          // Only remove if it's not the default pitch bend 8192 message and it's the same tick
          pitchBendTrack.remove(pitchBendTrack.get(i));
        }
      }
    } else if (edit && pitchBend) {
      int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
      currentPitchBendEditTick = tick; // Keep track of what tick the dynamic rectangle representing the new bend should be drawn in
      for (int i = 0; i < pitchBendTrack.size(); i++) {
        if ((pitchBendTrack.get(i).getTick() == tick) && (((pitchBendTrack.get(i).getMessage().getMessage()[2] * 128) + pitchBendTrack.get(i).getMessage().getMessage()[1]) != 8192)) {
          // Only remove if it's not the default pitch bend 8192 message and it's the same tick
          pitchBendTrack.remove(pitchBendTrack.get(i));
        }
      }
    }
  }
  
}

// Called when a user moves a pinched hand
void pinchMoved(float fingerTipXAxis, float fingerTipYAxis) {
  //println("Pinch Moved: " + posIndexTip);
  if (liveMode) {
    if (pitchBend) {
      // Map Finger Value to 0 to 16383
      int pitchBendValue = (int) map(fingerTipYAxis, 50, 399, 0, 16383);
      myBus.sendMessage(224, pitchBendValue % 128, pitchBendValue / 128);
    }
  } else if (editorMode) {
    if ((edit && notes) || (edit && chords)) {
      // Press and drag mouse to edit
      // On press, if a note exists there, then delete note that was there and draw bar that follows mouse
      fill(175);
      rectMode(CENTER);
      rect(((int) fingerTipDisplayX) + ((width/sequencer.getTickLength() / 2)), ((int) fingerTipDisplayY), 2*(width/sequencer.getTickLength()), 10);
      rectMode(CORNER);
      fill(255);
    } else if (edit && pitchBend) {
      fill(175);
      int currentPitchBendEditTickX = (int) (width/sequencer.getTickLength()) * currentPitchBendEditTick;
      if (fingerTipDisplayY < 575) {
        rect(currentPitchBendEditTickX, ((int) fingerTipDisplayY), width/sequencer.getTickLength(), abs(fingerTipDisplayY - 575));
      } else {
        rect(currentPitchBendEditTickX, 575, width/sequencer.getTickLength(), abs(fingerTipDisplayY - 575));
      }
      fill(255);
    }
  }
}

// Called when a pinch gesture is released/stopped
void pinchReleased() {
  //println("Pinch Released");
  if (liveMode) {
    if (notes) {
      turnNoteOff(currentMIDINote);
    } else if (chords) {
      turnChordOff(currentMIDIChord);
    } else if (pitchBend) {
      // Default to no pitch bend which is the value 8192
      myBus.sendMessage(224, 8192 % 128, 8192 / 128);
    }
  } else if (editorMode) {
    if (edit && notes) {
      // If hand is in notes grid zone
      if ((fingerTipDisplayY >= 100) && (fingerTipDisplayY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(fingerTipDisplayY);
        }
        
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addNote(midiPitch, tick);
      }
    } else if (edit && chords) {
      if ((fingerTipDisplayY >= 300) && (fingerTipDisplayY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(fingerTipDisplayY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(fingerTipDisplayY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(fingerTipDisplayY);
        }
        int tick = (int) (fingerTipDisplayX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addChord(midiPitches, tick);
      }
    } else if (edit && pitchBend) {
      int pitchBendValue = (int) map(fingerTipDisplayY, 650, 500, 0, 16383);
      addPitchBend(pitchBendValue, currentPitchBendEditTick);
    }
  }
}

// Formats the dropdown menu for selecting keys
void formatMusicalKeyDropdownList(DropdownList selectKey) {
  selectKey.setOpen(false);
  selectKey.addItem("C Major", 0);
  selectKey.addItem("C Minor", 1);
  selectKey.addItem("C# Major", 2);
  selectKey.addItem("C# Minor", 3);
  selectKey.addItem("D Major", 4);
  selectKey.addItem("D Minor", 5);
  selectKey.addItem("D# Major", 6);
  selectKey.addItem("D# Minor", 7);
  selectKey.addItem("E Major", 8);
  selectKey.addItem("E Minor", 9);
  selectKey.addItem("F Major", 10);
  selectKey.addItem("F Minor", 11);
  selectKey.addItem("F# Major", 12);
  selectKey.addItem("F# Minor", 13);
  selectKey.addItem("G Major", 14);
  selectKey.addItem("G Minor", 15);
  selectKey.addItem("G# Major", 16);
  selectKey.addItem("G# Minor", 17);
  selectKey.addItem("A Major", 18);
  selectKey.addItem("A Minor", 19);
  selectKey.addItem("A# Major", 20);
  selectKey.addItem("A# Minor", 21);
  selectKey.addItem("B Major", 22);
  selectKey.addItem("B Minor", 23);
  selectKey.setSize(150,75);
  selectKey.setBarHeight(25);
  selectKey.setItemHeight(25);
}

// Called whenever an event from a Control P5 element is triggered
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    if (theEvent.getName() == "notesChordsRadioButton") {
      if (theEvent.getValue() == 0) {
        // Turn Note Mode On
        notes = true;
        chords = false;
        pitchBend = false;
      } else if (theEvent.getValue() == 1) {
        // Turn Chord Mode On
        notes = false;
        chords = true;
        pitchBend = false;
      } else if (theEvent.getValue() == 2) {
        // Turn Pitch Bend Mode On
        notes = false;
        chords = false;
        pitchBend = true;
      }
    } else if (theEvent.getName() == "composeDeleteEditRadioButton") {
      if (theEvent.getValue() == 0) {
        // Turn Note Mode On
        compose = true;
        delete = false;
        edit = false;
      } else if (theEvent.getValue() == 1) {
        // Turn Chord Mode On
        compose = false;
        delete = true;
        edit = false;
      } else if (theEvent.getValue() == 2) {
        // Turn Pitch Bend Mode On
        compose = false;
        delete = false;
        edit = true;
      }
    }
  } else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    if (theEvent.getController().getName() == "Select Key") {
      int ddlValue = (int) theEvent.getController().getValue();
      selectedMusicalKey = ddlValue;
    } else if (theEvent.getController().getName() == "tempoKnob") {
      float newTempoValue = theEvent.getController().getValue();
      sequencer.setTempoFactor(newTempoValue/sequencer.getTempoInBPM());
    }
  }
}

void keyPressed() {
  if (editorMode) {
    // MAKE SPACE BAR START & STOP
    if ((key == ' ') && (!playing)) {
      playSequence();
      playing = true;
    } else if ((key == ' ') && (playing)) {
      stopSequence();
      playing = false;
    }
  }
}

// THIS WAS THE CODE FOR KEY TAP GESTURES
// DECIDED THAT PINCH GESTURES WERE BETTER
//void leapOnKeyTapGesture(KeyTapGesture g) {
  
//  int     id               = g.getId();
//  Finger  finger           = g.getFinger();
//  PVector position         = g.getPosition();
//  PVector direction        = g.getDirection();
//  long    duration         = g.getDuration();
//  float   durationSeconds  = g.getDurationInSeconds();

//  //println("KeyTapGesture: " + id);
//  //println("KeyTapGesture Duration: " + duration);
//  //println("Finger Position: " + position);
  
//  //int midiPitch = getCMajorScaleNote(indexFingerYAxis);
//  int midiPitch;
//  switch (selectedMusicalKey) {
//    case 0:
//      midiPitch = getCMajorScaleNote(indexFingerYAxis);
//      break;
//    case 1:
//      midiPitch = getCMinorScaleNote(indexFingerYAxis);
//      break;
//    default:
//      midiPitch = getCMajorScaleNote(indexFingerYAxis);
//  }
  
//  if (!active[midiPitch]) {
//    active[midiPitch] = true;
//    myBus.sendNoteOn(1, midiPitch, 127);
//    println("Note On");
//    // Set Timer
//    currentMIDINote = new MIDINote(1, midiPitch, 127);
//    noteTimer = 5;
//  }
  
//  drawWaterRipple(fingerTipDisplayX, fingerTipDisplayY);
  
//}

// Turns off a MIDI note playing in live mode
void turnNoteOff(MIDINote midiNote) {
  if (midiNote != null) {
    active[midiNote.getNote()] = false;
    myBus.sendNoteOff(midiNote.getChannel(), midiNote.getNote(), midiNote.getVelocity());
    println("Note Off");
  }
}

// Turns off a chord that's playing in live mode
void turnChordOff(MIDIChord midiChord) {
  if (midiChord != null) {
    active[midiChord.getNotes()[0]] = false;
    active[midiChord.getNotes()[1]] = false;
    active[midiChord.getNotes()[2]] = false;
    myBus.sendNoteOff(midiChord.getChannel(), midiChord.getNotes()[0], midiChord.getVelocity());
    println("Note Off");
    myBus.sendNoteOff(midiChord.getChannel(), midiChord.getNotes()[1], midiChord.getVelocity());
    println("Note Off");
    myBus.sendNoteOff(midiChord.getChannel(), midiChord.getNotes()[2], midiChord.getVelocity());
    println("Note Off");
  }
}

// HELPER FUNCTIONS THAT RETRIEVE THE MIDI PITCH FOR A CERTAIN ZONE OF INTERACTIVITY FOR EACH KEY
public int getCMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 48;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 50;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 52;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 53;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 55;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 57;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 59;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 60;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 62;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 64;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 65;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 67;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 69;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 71;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getCMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 48;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 50;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 51;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 53;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 55;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 56;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 58;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 60;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 62;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 63;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 65;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 67;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 68;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 70;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getCSharpMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 49;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 51;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 53;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 54;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 56;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 58;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 60;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 61;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 63;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 65;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 66;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 68;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 70;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 72;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getCSharpMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 49;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 51;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 52;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 54;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 56;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 57;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 59;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 61;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 63;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 64;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 66;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 68;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 69;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 71;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getDMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 50;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 52;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 54;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 55;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 57;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 59;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 61;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 62;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 64;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 66;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 67;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 69;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 71;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 73;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getDMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 50;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 52;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 53;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 55;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 57;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 58;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 60;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 62;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 64;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 65;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 67;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 69;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 70;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 72;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getDSharpMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 51;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 53;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 55;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 56;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 58;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 60;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 62;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 63;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 65;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 67;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 68;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 70;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 72;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 74;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getDSharpMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 51;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 53;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 54;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 56;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 58;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 59;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 61;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 63;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 65;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 66;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 68;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 70;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 71;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 73;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getEMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 52;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 54;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 56;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 57;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 59;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 61;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 63;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 64;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 66;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 68;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 69;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 71;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 73;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 75;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getEMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 52;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 54;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 55;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 57;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 59;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 60;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 62;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 64;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 66;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 67;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 69;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 71;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 72;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 74;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getFMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 53;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 55;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 57;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 58;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 60;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 62;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 64;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 65;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 67;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 69;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 70;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 72;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 74;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 76;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getFMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 53;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 55;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 56;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 58;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 60;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 61;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 63;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 65;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 67;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 68;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 70;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 72;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 73;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 75;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getFSharpMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 54;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 56;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 58;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 59;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 61;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 63;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 65;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 66;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 68;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 70;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 71;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 73;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 75;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 77;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getFSharpMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 54;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 56;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 57;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 59;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 61;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 62;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 64;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 66;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 68;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 69;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 71;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 73;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 74;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 76;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getGMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 55;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 57;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 59;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 60;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 62;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 64;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 66;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 67;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 69;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 71;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 72;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 74;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 76;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 78;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getGMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 55;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 57;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 58;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 60;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 62;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 63;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 65;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 67;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 69;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 70;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 72;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 74;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 75;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 77;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getGSharpMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 56;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 58;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 60;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 61;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 63;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 65;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 67;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 68;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 70;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 72;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 73;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 75;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 77;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 79;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getGSharpMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 56;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 58;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 59;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 61;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 63;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 64;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 66;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 68;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 70;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 71;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 73;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 75;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 76;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 78;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getAMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 57;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 59;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 61;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 62;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 64;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 66;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 68;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 69;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 71;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 73;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 74;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 76;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 78;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 80;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getAMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 57;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 59;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 60;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 62;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 64;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 65;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 67;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 69;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 71;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 72;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 74;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 76;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 77;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 79;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getASharpMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 58;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 60;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 62;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 63;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 65;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 67;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 69;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 70;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 72;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 74;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 75;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 77;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 79;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 81;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getASharpMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 58;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 60;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 61;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 63;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 65;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 66;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 68;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 70;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 72;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 73;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 75;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 77;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 78;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 80;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getBMajorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 59;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 61;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 63;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 64;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 66;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 68;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 70;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 71;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 73;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 75;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 76;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 78;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 80;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 82;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int getBMinorScaleNote(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 59;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 61;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 62;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 64;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 66;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 67;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 69;
    } else {
      return -1;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      return 71;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      return 73;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      return 74;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      return 76;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      return 78;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      return 79;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      return 81;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}

public int[] getCMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {36,40,43};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {38,41,45};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {40,43,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {41,45,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {43,47,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {47,50,53};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {59,62,65};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {36,39,43};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {38,41,44};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {39,43,46};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {41,44,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {43,46,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {44,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {50,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCSharpMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {37,41,44};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {39,42,46};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {41,44,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {42,46,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {44,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {48,51,54};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {60,63,66};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCSharpMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {37,40,44};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {39,42,45};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {40,44,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {42,45,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {44,47,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {45,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {51,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {38,42,45};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {40,43,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {42,45,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {43,47,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {45,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {49,52,55};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {61,64,67};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {38,41,45};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {40,43,46};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {41,45,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {43,46,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {52,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {60,64,67};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDSharpMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {39,43,46};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {41,44,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {43,46,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {44,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {50,53,56};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {60,63,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {62,65,68};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDSharpMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {39,42,46};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {41,44,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {42,46,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {44,47,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {53,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {61,65,68};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getEMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {40,44,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {42,45,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {44,47,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {45,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {51,54,57};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {61,64,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {63,66,69};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getEMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {40,43,47};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {42,45,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {43,47,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {54,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {60,64,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {62,66,69};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {41,45,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {43,46,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {52,55,58};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {60,64,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {62,65,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {64,67,70};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {41,44,48};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {43,46,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {44,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {55,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {60,63,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {61,65,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {63,67,70};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFSharpMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {42,46,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {44,47,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {53,56,59};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {61,65,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {63,66,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {65,68,71};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFSharpMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {42,45,49};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {44,47,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {45,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {56,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {61,64,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {62,66,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {64,68,71};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {43,47,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {54,57,60};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {60,64,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {62,66,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {64,67,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {66,69,72};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {43,46,50};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {45,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {57,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {60,63,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {62,65,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {63,67,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {65,69,72};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGSharpMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {44,48,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {55,58,61};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {60,63,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {61,65,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {63,67,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {65,68,72};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {67,70,73};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGSharpMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {44,47,51};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {46,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {58,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {61,64,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {63,66,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {64,68,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {66,70,73};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getAMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {45,49,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {56,59,62};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {61,64,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {62,66,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {64,68,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {66,69,73};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {68,71,74};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getAMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {45,48,52};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {47,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {48,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {57,60,64};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {59,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {60,64,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {62,65,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {64,67,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {65,69,72};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {67,71,74};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getASharpMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {46,50,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {48,51,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {50,53,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {51,55,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {53,57,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {55,58,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {57,60,63};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {58,62,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {60,63,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {62,65,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {63,67,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {65,69,72};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {67,70,74};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {69,72,75};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getASharpMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {46,49,53};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {48,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {49,53,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {53,56,60};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {56,60,63};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {58,61,65};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {60,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {61,65,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {63,66,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {65,68,72};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {66,70,73};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {68,72,75};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getBMajorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {47,51,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {49,52,56};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {51,54,58};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {52,56,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {54,58,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {56,59,63};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {58,61,64};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {59,63,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {61,64,68};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {63,66,70};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {64,68,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {66,70,73};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {68,71,75};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {70,73,76};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getBMinorScaleChord(float fingerPositionXAxis, float fingerPositionYAxis) {
  if (fingerPositionXAxis < 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {47,50,54};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {49,52,55};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {50,54,57};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {52,55,59};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {54,57,61};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {55,59,62};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {57,61,64};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else if (fingerPositionXAxis >= 0) {
    if ((fingerPositionYAxis >= 50) && (fingerPositionYAxis < 100)) {
      int[] pitches = {59,62,66};
      return pitches;
    } else if ((fingerPositionYAxis >= 100) && (fingerPositionYAxis < 150)) {
      int[] pitches = {61,64,67};
      return pitches;
    } else if ((fingerPositionYAxis >= 150) && (fingerPositionYAxis < 200)) {
      int[] pitches = {62,66,69};
      return pitches;
    } else if ((fingerPositionYAxis >= 200) && (fingerPositionYAxis < 250)) {
      int[] pitches = {64,67,71};
      return pitches;
    } else if ((fingerPositionYAxis >= 250) && (fingerPositionYAxis < 300)) {
      int[] pitches = {66,69,73};
      return pitches;
    } else if ((fingerPositionYAxis >= 300) && (fingerPositionYAxis < 350)) {
      int[] pitches = {67,71,74};
      return pitches;
    } else if ((fingerPositionYAxis >= 350) && (fingerPositionYAxis < 400)) {
      int[] pitches = {69,73,76};
      return pitches;
    } else {
      int[] pitches = {-1,-1,-1};
      return pitches;
    }
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

// Draw the water ripple effect when a note is played
void drawWaterRipple(float fingerDisplayX, float fingerDisplayY) {
  int rippleX = (int) fingerDisplayX;
  int rippleY = (int) fingerDisplayY;
  current[rippleX][rippleY] = 255;
}

// --------------------------
// MIDI EDITOR SPECIFIC STUFF

public void setupMidiEditor() {
 
  try {
    // A static method of MidiSystem that returns
    // a sequencer instance.
    sequencer = MidiSystem.getSequencer();
    sequencer.open();
 
    // Creating a sequence.
    sequence = new Sequence(Sequence.PPQ, 4);
    // PPQ(Pulse per ticks) is used to specify timing type and 4 is the timing resolution.
 
    // Creating a track in the sequence where MIDI events are added and triggered
    track = sequence.createTrack();
    // This track stores the chord information
    chordsTrack = sequence.createTrack();
    // This track stores pitch bend information
    pitchBendTrack = sequence.createTrack();
    
    // Add some phoney events to get the right length of sequence
    for (int i = 1; i < 65; i++) {
      ShortMessage msg = new ShortMessage();
      msg.setMessage(176, 0, 110, 0);
      track.add(new MidiEvent(msg, i));
    }
    
    // Adding default pitch bend messages to snap it back to default after a pitch bend message is sent
    for (int j = 0; j < 64; j++) {
      ShortMessage defaultPitchBendMessage = new ShortMessage();
      defaultPitchBendMessage.setMessage(224, 1, 8192 % 128, 8192 / 128);
      pitchBendTrack.add(new MidiEvent(defaultPitchBendMessage, j));
    }
 
    // Setting our sequence so that the sequencer can run it on synthesizer
    sequencer.setSequence(sequence);
    // Specifies the tempo in beats per minute.
    sequencer.setTempoInBPM(128);
    // Set a continuous loop
    sequencer.setLoopCount(Sequencer.LOOP_CONTINUOUSLY);
    // SET LOOP START AND END POINTS? MAKE IT 4 BARS BY DEFAULT.
    //sequencer.setLoopStartPoint(0);
    //sequencer.setLoopEndPoint(32);
    playing = false;
      
  } catch (Exception ex) {
      ex.printStackTrace();
  }
    
}

public MidiEvent makeEvent(int command, int channel, int note, int velocity, int tick) {
  MidiEvent event = null;
  try {
    // ShortMessage stores a note as command type, channel, instrument it has to be played on and its speed.
    ShortMessage a = new ShortMessage();
    a.setMessage(command, channel, note, velocity);
    // A midi event is comprised of a short message(representing a note) and the tick at which that note has to be played
    event = new MidiEvent(a, tick);
  }
  catch (Exception ex) {
    ex.printStackTrace();
  }
  return event;
}

public void drawNotes() {
  // Draw all notes in a track from a sequence
  fill(255);
  for (int i = 0; i < track.size(); i++) {
    //println(track.get(i).getMessage().getStatus());
    if (track.get(i).getMessage().getStatus() == 145) {
      //println(track.get(i).getTick());
      //println(track.get(i).getMessage().getMessage()[1]); // Pitch
      //println(track.get(i).getMessage().getMessage()[2]); // Velocity
      // x is (width/totalTicks) * tick
      // y is (height/number of pitches available) * pitchIndex (getPitchIndex from pitch of note (68 = 1 here etc.))
      int yPos = getNoteYPos(track.get(i).getMessage().getMessage()[1]);
      rect((width/sequencer.getTickLength())*track.get(i).getTick(), yPos, 2*(width/sequencer.getTickLength()), 10);
      fill(0);
      text(getPitchNoteText(track.get(i).getMessage().getMessage()[1]), ((width/sequencer.getTickLength())*track.get(i).getTick())+5, yPos+7);
      fill(255);
    }
  }
}

public void drawChords() {
  // Draw all notes in a track from a sequence
  fill(255);
  for (int i = 0; i < chordsTrack.size(); i++) {
    //println(track.get(i).getMessage().getStatus());
    if ((chordsTrack.get(i).getMessage().getStatus() == 145) && (chordsTrack.get(i).getMessage().getMessage()[2] == 101)) {
      //println(track.get(i).getTick());
      //println(track.get(i).getMessage().getMessage()[1]); // Pitch
      //println(track.get(i).getMessage().getMessage()[2]); // Velocity
      // x is (width/totalTicks) * tick
      // y is (height/number of pitches available) * pitchIndex (getPitchIndex from pitch of note (68 = 1 here etc.))
      int yPos = getChordYPos(chordsTrack.get(i).getMessage().getMessage()[1]);
      rect((width/sequencer.getTickLength())*chordsTrack.get(i).getTick(), yPos, 2*(width/sequencer.getTickLength()), 10);
      fill(0);
      text(getPitchNoteText(chordsTrack.get(i).getMessage().getMessage()[1]) + " " + getChordTypeText(yPos), ((width/sequencer.getTickLength())*chordsTrack.get(i).getTick())+5, yPos+7);
      fill(255);
    }
  }
}

public void drawPitchBends() {
  // Draw all notes in a track from a sequence
  fill(255);
  for (int i = 0; i < pitchBendTrack.size(); i++) {
    //println(track.get(i).getMessage().getStatus());
    if (pitchBendTrack.get(i).getMessage().getStatus() == 225) {
      int pitchBendValue = (pitchBendTrack.get(i).getMessage().getMessage()[2] * 128) + pitchBendTrack.get(i).getMessage().getMessage()[1];
      // Getting original value from MSB and LSB is (data2 * 128) + data1
      if (pitchBendValue < 8192) {
        rect((width/sequencer.getTickLength())*pitchBendTrack.get(i).getTick(), 575, width/sequencer.getTickLength(), (map(pitchBendValue, 0, 16383, 650, 500)-575));
      } else {
        rect((width/sequencer.getTickLength())*pitchBendTrack.get(i).getTick(), map(pitchBendValue, 0, 16383, 650, 500), width/sequencer.getTickLength(), abs(map(pitchBendValue, 0, 16383, 650, 500)-575));
      }
    }
  }
}

// Draws notes back in the correct position on notes grid
public int getNoteYPos(int pitch) {
  int yPos = -500;
  int keyOffset = 0;
  if ((selectedMusicalKey == 0) || (selectedMusicalKey == 1)) {
    // C Keys
    keyOffset = 0;
  } else if ((selectedMusicalKey == 2) || (selectedMusicalKey == 3)) {
    // C# Keys
    keyOffset = 1;
  } else if ((selectedMusicalKey == 4) || (selectedMusicalKey == 5)) {
    // D Keys
    keyOffset = 2;
  } else if ((selectedMusicalKey == 6) || (selectedMusicalKey == 7)) {
    // D# Keys
    keyOffset = 3;
  } else if ((selectedMusicalKey == 8) || (selectedMusicalKey == 9)) {
    // E Keys
    keyOffset = 4;
  } else if ((selectedMusicalKey == 10) || (selectedMusicalKey == 11)) {
    // F Keys
    keyOffset = 5;
  } else if ((selectedMusicalKey == 12) || (selectedMusicalKey == 13)) {
    // F# Keys
    keyOffset = 6;
  } else if ((selectedMusicalKey == 14) || (selectedMusicalKey == 15)) {
    // G Keys
    keyOffset = 7;
  } else if ((selectedMusicalKey == 16) || (selectedMusicalKey == 17)) {
    // G# Keys
    keyOffset = 8;
  } else if ((selectedMusicalKey == 18) || (selectedMusicalKey == 19)) {
    // A Keys
    keyOffset = 9;
  } else if ((selectedMusicalKey == 20) || (selectedMusicalKey == 21)) {
    // A# Keys
    keyOffset = 10;
  } else if ((selectedMusicalKey == 22) || (selectedMusicalKey == 23)) {
    // B Keys
    keyOffset = 11;
  }
  int notePositionInScale = pitch - 48 - keyOffset;
  switch (notePositionInScale) {
    case 0:
      yPos = 240;
      break;
    case 2:
      yPos = 230;
      break;
    case 3:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 220;
        //break;
      }
      break;
    case 4:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 220;
      }
      break;
    case 5:
      yPos = 210;
      break;
    case 7:
      yPos = 200;
      break;
    case 8:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 190;
      }
      break;
    case 9:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 190;
      }
      break;
    case 10:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 180;
      }
      break;
    case 11:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 180;
      }
      break;
    case 12:
      yPos = 170;
      break;
    case 14:
      yPos = 160;
      break;
    case 15:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 150;
      }
      break;
    case 16:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 150;
      }
      break;
    case 17:
      yPos = 140;
      break;
    case 19:
      yPos = 130;
      break;
    case 20:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 120;
      }
      break;
    case 21:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 120;
      }
      break;
    case 22:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 110;
      }
      break;
    case 23:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 110;
      }
      break;
    case 24:
      yPos = 100;
      break;
    default:
      yPos = -500; // Draw off screen because note is note in scale/range
  }
  return yPos;
}

// Draws chords back in the correct position on the chords grid
public int getChordYPos(int pitch) {
  int yPos = -500;
  int keyOffset = 0;
  if ((selectedMusicalKey == 0) || (selectedMusicalKey == 1)) {
    // C Keys
    keyOffset = 0;
  } else if ((selectedMusicalKey == 2) || (selectedMusicalKey == 3)) {
    // C# Keys
    keyOffset = 1;
  } else if ((selectedMusicalKey == 4) || (selectedMusicalKey == 5)) {
    // D Keys
    keyOffset = 2;
  } else if ((selectedMusicalKey == 6) || (selectedMusicalKey == 7)) {
    // D# Keys
    keyOffset = 3;
  } else if ((selectedMusicalKey == 8) || (selectedMusicalKey == 9)) {
    // E Keys
    keyOffset = 4;
  } else if ((selectedMusicalKey == 10) || (selectedMusicalKey == 11)) {
    // F Keys
    keyOffset = 5;
  } else if ((selectedMusicalKey == 12) || (selectedMusicalKey == 13)) {
    // F# Keys
    keyOffset = 6;
  } else if ((selectedMusicalKey == 14) || (selectedMusicalKey == 15)) {
    // G Keys
    keyOffset = 7;
  } else if ((selectedMusicalKey == 16) || (selectedMusicalKey == 17)) {
    // G# Keys
    keyOffset = 8;
  } else if ((selectedMusicalKey == 18) || (selectedMusicalKey == 19)) {
    // A Keys
    keyOffset = 9;
  } else if ((selectedMusicalKey == 20) || (selectedMusicalKey == 21)) {
    // A# Keys
    keyOffset = 10;
  } else if ((selectedMusicalKey == 22) || (selectedMusicalKey == 23)) {
    // B Keys
    keyOffset = 11;
  }
  int notePositionInScale = pitch - 36 - keyOffset;
  switch (notePositionInScale) {
    case 0:
      yPos = 440;
      break;
    case 2:
      yPos = 430;
      break;
    case 3:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 420;
        //break;
      }
      break;
    case 4:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 420;
      }
      break;
    case 5:
      yPos = 410;
      break;
    case 7:
      yPos = 400;
      break;
    case 8:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 390;
      }
      break;
    case 9:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 390;
      }
      break;
    case 10:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 380;
      }
      break;
    case 11:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 380;
      }
      break;
    case 12:
      yPos = 370;
      break;
    case 14:
      yPos = 360;
      break;
    case 15:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 350;
      }
      break;
    case 16:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 350;
      }
      break;
    case 17:
      yPos = 340;
      break;
    case 19:
      yPos = 330;
      break;
    case 20:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 320;
      }
      break;
    case 21:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 320;
      }
      break;
    case 22:
      if (selectedMusicalKey % 2 == 1) {
        yPos = 310;
      }
      break;
    case 23:
      if (selectedMusicalKey % 2 == 0) {
        yPos = 310;
      }
      break;
    case 24:
      yPos = 300;
      break;
    default:
      yPos = -500; // Draw off screen because note is note in scale/range
  }
  return yPos;
}

public void playSequence() {
  // Sequencer starts to play notes
  sequencer.start();
}

public void stopSequence() {
  // Sequencer stops playing notes
  sequencer.stop();
}

void drawNotesPlayback() {
  float xPos = map(sequencer.getMicrosecondPosition(), 0, sequencer.getMicrosecondLength(), 0, width);
  stroke(255);
  line(xPos, 100, xPos, 250);
  fill(255);
  // Upper Playback Triangle
  triangle(xPos-10, 100, xPos+10, 100, xPos, 110);
  // Lower Playback Triangle
  triangle(xPos-10, 250, xPos+10, 250, xPos, 250-10);
}

void drawChordsPlayback() {
  float xPos = map(sequencer.getMicrosecondPosition(), 0, sequencer.getMicrosecondLength(), 0, width);
  stroke(255);
  line(xPos, 300, xPos, 450);
  fill(255);
  // Upper Playback Triangle
  triangle(xPos-10, 300, xPos+10, 300, xPos, 310);
  // Lower Playback Triangle
  triangle(xPos-10, 450, xPos+10, 450, xPos, 450-10);
}

void drawPitchBendPlayback() {
  float xPos = map(sequencer.getMicrosecondPosition(), 0, sequencer.getMicrosecondLength(), 0, width);
  stroke(255);
  line(xPos, 500, xPos, 650);
  fill(255);
  // Upper Playback Triangle
  triangle(xPos-10, 500, xPos+10, 500, xPos, 510);
  // Lower Playback Triangle
  triangle(xPos-10, 650, xPos+10, 650, xPos, 650-10);
}

void drawNotesGrid() {
  long xSection = (width/sequencer.getTickLength());
  // Vertical Timing Lines
  for (int i = 1; i < 65; i++) {
    //stroke(0, 0, 255);
    if (i % 16 == 0) {
      stroke(255, 0, 0, 150);
      line(i*xSection, 100, i*xSection, 250);
      stroke(0);
    } else if (i % 4 == 0) {
      stroke(0, 0, 255, 150); // Make this less saturated
      line(i*xSection, 100, i*xSection, 250);
      stroke(0);
    } else {
      stroke(100);
      line(i*xSection, 100, i*xSection, 250);
      stroke(0);
    }
  }
  // Horizontal Pitch Lines
  for (int j = 0; j < 15; j++) {
    stroke(50);
    line(0, 100+(j*10), width, 100+(j*10));
    stroke(0);
  }
  // Draw Borders
  stroke(100);
  line(0, 100, width, 100);
  line(0, 250, width, 250);
  stroke(0);
}

void drawChordsGrid() {
  long xSection = (width/sequencer.getTickLength());
  // Vertical Timing Lines
  for (int i = 1; i < 65; i++) {
    //stroke(0, 0, 255);
    if (i % 16 == 0) {
      stroke(255, 0, 0, 150);
      line(i*xSection, 300, i*xSection, 450);
      stroke(0);
    } else if (i % 4 == 0) {
      stroke(0, 0, 255, 150); // Make this less saturated
      line(i*xSection, 300, i*xSection, 450);
      stroke(0);
    } else {
      stroke(100);
      line(i*xSection, 300, i*xSection, 450);
      stroke(0);
    }
  }
  // Horizontal Pitch Lines
  for (int j = 0; j < 15; j++) {
    stroke(50);
    line(0, 300+(j*10), width, 300+(j*10));
    stroke(0);
  }
  // Draw Borders
  stroke(100);
  line(0, 300, width, 300);
  line(0, 450, width, 450);
  stroke(0);
}

void drawPitchBendGrid() {
  long xSection = (width/sequencer.getTickLength());
  // Vertical Timing Lines
  for (int i = 1; i < 65; i++) {
    //stroke(0, 0, 255);
    if (i % 16 == 0) {
      stroke(255, 0, 0, 150);
      line(i*xSection, 500, i*xSection, 650);
      stroke(0);
    } else if (i % 4 == 0) {
      stroke(0, 0, 255, 150); // Make this less saturated
      line(i*xSection, 500, i*xSection, 650);
      stroke(0);
    } else {
      stroke(100);
      line(i*xSection, 500, i*xSection, 650);
      stroke(0);
    }
  }
  // Horizontal Pitch Value Lines
  for (int j = 0; j < 10; j++) {
    stroke(50);
    line(0, 500+(j*15), width, 500+(j*15));
    stroke(0);
  }
  // Draw Borders
  stroke(100);
  line(0, 500, width, 500);
  line(0, 650, width, 650);
  stroke(0);
  // Draw Central Pitch Line
  stroke(255);
  strokeWeight(4);
  line(0, 575, width, 575);
  strokeWeight(1);
  stroke(0);
}

// Adds a single note to a track
void addNote(int pitch, int tick) {
  // Add Note On event
  track.add(makeEvent(144, 1, pitch, 100, tick));
  // Add Note Off event
  track.add(makeEvent(128, 1, pitch, 100, tick + 2));
  println("Note Added at tick: " + tick);
}

// Adds a triad chord to a track
void addChord(int[] pitches, int tick) {
  // Add First Note On event
  chordsTrack.add(makeEvent(144, 1, pitches[0], 101, tick));
  // Add First Note Off event
  chordsTrack.add(makeEvent(128, 1, pitches[0], 101, tick + 2));
  // Add Second Note On event
  chordsTrack.add(makeEvent(144, 1, pitches[1], 100, tick));
  // Add Second Note Off event
  chordsTrack.add(makeEvent(128, 1, pitches[1], 100, tick + 2));
  // Add Third Note On event
  chordsTrack.add(makeEvent(144, 1, pitches[2], 100, tick));
  // Add Third Note Off event
  chordsTrack.add(makeEvent(128, 1, pitches[2], 100, tick + 2));
  println("Chord Added at tick: " + tick);
}

// Adds a single pitch bend message to the pitch bend track
void addPitchBend(int pitchValue, int tick) {
  // Add Note On event
  pitchBendTrack.add(makeEvent(224, 1, pitchValue % 128, pitchValue / 128, tick));
  // Add Note Off event
  //track.add(makeEvent(128, 1, pitchValue, 100, tick + 2));
  println("Pitch Bend Added at tick: " + tick);
}

// ####################################################
// MOUSE INTERACTION FUNCTIONS
// This is a good alternative mode of interaction if the user does not wish to use gestures
void mouseClicked() {
  if (editorMode) {
    if (compose && notes) {
      if ((mouseY >= 100) && (mouseY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(mouseY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(mouseY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(mouseY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(mouseY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(mouseY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(mouseY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(mouseY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(mouseY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(mouseY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(mouseY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(mouseY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(mouseY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(mouseY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
        }
        
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        
        addNote(midiPitch, tick);
        
      }
    } else if (delete && notes) {
      if ((mouseY >= 100) && (mouseY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(mouseY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(mouseY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(mouseY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(mouseY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(mouseY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(mouseY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(mouseY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(mouseY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(mouseY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(mouseY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(mouseY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(mouseY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(mouseY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
        }
        
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        for (int i = 0; i < track.size(); i++) {
          if ((track.get(i).getMessage().getMessage()[1] == midiPitch) && ((track.get(i).getTick() == tick) || (track.get(i).getTick() == tick-1))) {
            track.remove(track.get(i));
          }
        }
      }
    } else if (compose && chords) {
      if ((mouseY >= 300) && (mouseY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(mouseY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(mouseY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(mouseY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(mouseY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(mouseY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(mouseY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(mouseY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(mouseY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(mouseY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(mouseY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(mouseY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(mouseY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(mouseY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(mouseY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(mouseY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
        }
        
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addChord(midiPitches, tick);
      }
    } else if (delete && chords) {
      if ((mouseY >= 300) && (mouseY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(mouseY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(mouseY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(mouseY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(mouseY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(mouseY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(mouseY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(mouseY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(mouseY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(mouseY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(mouseY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(mouseY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(mouseY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(mouseY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(mouseY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(mouseY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
        }
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        ArrayList<MidiEvent> notesToRemove = new ArrayList<MidiEvent>();
        for (int i = 0; i < chordsTrack.size(); i++) {
          if (((chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[0]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[1]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[2])) && ((chordsTrack.get(i).getTick() == tick) || (chordsTrack.get(i).getTick() == tick-1))) {
            notesToRemove.add(chordsTrack.get(i));
          }
        }
        for (int j = 0; j < notesToRemove.size(); j++) {
          // Remove
          chordsTrack.remove(notesToRemove.get(j));
        }
      }
    } else if (compose && pitchBend) {
      if ((mouseY >= 500) && (mouseY <= 650)) {
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        int pitchBendValue = (int) map(mouseY, 650, 500, 0, 16383);
        addPitchBend(pitchBendValue, tick);
      }
    } else if (delete && pitchBend) {
      if ((mouseY >= 500) && (mouseY <= 650)) {
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        for (int i = 0; i < pitchBendTrack.size(); i++) {
          if ((pitchBendTrack.get(i).getTick() == tick) && (((pitchBendTrack.get(i).getMessage().getMessage()[2] * 128) + pitchBendTrack.get(i).getMessage().getMessage()[1]) != 8192)) {
            // Only remove if it's not the default pitch bend 8192 message and it's the same tick
            pitchBendTrack.remove(pitchBendTrack.get(i));
          }
        }
      }
    }
  }
}

void mouseDragged() {
  if (liveMode) {
    if (pitchBend) {
      int pointerY = mouseY;
      if (pointerY < 300) {
        pointerY = 300;
      } else if (pointerY > 649) {
        pointerY = 649;
      }
      // Map Mouse Pointer Value to 0 to 16383
      int pitchBendValue = (int) map(pointerY, 649, 300, 0, 16383);
      myBus.sendMessage(224, pitchBendValue % 128, pitchBendValue / 128);
    }
  } else if (editorMode) {
    if ((edit && notes) || (edit && chords)) {
      if (mouseY > 80) {
        // Press and drag mouse to edit
        // On press, if a note exists there, then delete note that was there and draw bar that follows mouse
        fill(175);
        rectMode(CENTER); // IS IT BETTER TO CENTER NOTE WHEN IT'S PICKED UP?
        rect(((int) mouseX) + ((width/sequencer.getTickLength() / 2)), ((int) mouseY), 2*(width/sequencer.getTickLength()), 10);
        rectMode(CORNER);
        fill(255);
      }
    } else if (edit && pitchBend) {
      if (mouseY > 80) {
        fill(175);
        int currentPitchBendEditTickX = (int) (width/sequencer.getTickLength()) * currentPitchBendEditTick;
        if ((mouseY < 575) && (mouseY >= 500)) {
          rect(currentPitchBendEditTickX, ((int) mouseY), width/sequencer.getTickLength(), abs(mouseY - 575));
        } else if (mouseY < 500) {
          // Mouse has been dragged above pitch bend grid, hence just draw rectangle to limits of the grid
          rect(currentPitchBendEditTickX, 500, width/sequencer.getTickLength(), 75);
        } else if ((mouseY > 575) && (mouseY <= 650)) {
          rect(currentPitchBendEditTickX, 575, width/sequencer.getTickLength(), abs(mouseY - 575));
        } else if (mouseY > 650) {
          // Mouse has been dragged above pitch bend grid, hence just draw rectangle to limits of the grid
          rect(currentPitchBendEditTickX, 575, width/sequencer.getTickLength(), 75);
        }
        fill(255);
      }
    }
  }
}

void mousePressed() {
  if (liveMode) {
    if (notes) {
      if ((mouseY >= 300) && (mouseY < 650)) {
        // Convert Mouse Y Point
        int convertedYPos = 0;
        if ((mouseY >= 300) && (mouseY < 350)) {
          convertedYPos = 375;
        } else if ((mouseY >= 350) && (mouseY < 400)) {
          convertedYPos = 325;
        } else if ((mouseY >= 400) && (mouseY < 450)) {
          convertedYPos = 275;
        } else if ((mouseY >= 450) && (mouseY < 500)) {
          convertedYPos = 225;
        } else if ((mouseY >= 500) && (mouseY < 550)) {
          convertedYPos = 175;
        } else if ((mouseY >= 550) && (mouseY < 600)) {
          convertedYPos = 125;
        } else if ((mouseY >= 600) && (mouseY < 650)) {
          convertedYPos = 75;
        }
        // Convert Mouse X Point
        int convertedXPos = 0;
        if (mouseX < (width/2)) {
          convertedXPos = -50;
        } else if (mouseX >= (width/2)) {
          convertedXPos = 50;
        }
        // Get Pitch
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 1:
            midiPitch = getCMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 4:
            midiPitch = getDMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 5:
            midiPitch = getDMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 8:
            midiPitch = getEMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 9:
            midiPitch = getEMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 10:
            midiPitch = getFMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 11:
            midiPitch = getFMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 14:
            midiPitch = getGMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 15:
            midiPitch = getGMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 18:
            midiPitch = getAMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 19:
            midiPitch = getAMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNote(convertedXPos, convertedYPos);
            break;
          case 22:
            midiPitch = getBMajorScaleNote(convertedXPos, convertedYPos);
            break;
          case 23:
            midiPitch = getBMinorScaleNote(convertedXPos, convertedYPos);
            break;
          default:
            midiPitch = getCMajorScaleNote(convertedXPos, convertedYPos);
        }
        
        if (!active[midiPitch]) {
          active[midiPitch] = true;
          myBus.sendNoteOn(1, midiPitch, 127);
          println("Note On");
          // Set Timer
          currentMIDINote = new MIDINote(1, midiPitch, 127);
          //noteTimer = 5;
        }
        drawWaterRipple(mouseX, mouseY);
      }
    } else if (chords) {
      if ((mouseY >= 300) && (mouseY < 650)) {
        // Convert Mouse Y Point
        int convertedYPos = 0;
        if ((mouseY >= 300) && (mouseY < 350)) {
          convertedYPos = 375;
        } else if ((mouseY >= 350) && (mouseY < 400)) {
          convertedYPos = 325;
        } else if ((mouseY >= 400) && (mouseY < 450)) {
          convertedYPos = 275;
        } else if ((mouseY >= 450) && (mouseY < 500)) {
          convertedYPos = 225;
        } else if ((mouseY >= 500) && (mouseY < 550)) {
          convertedYPos = 175;
        } else if ((mouseY >= 550) && (mouseY < 600)) {
          convertedYPos = 125;
        } else if ((mouseY >= 600) && (mouseY < 650)) {
          convertedYPos = 75;
        }
        // Convert Mouse X Point
        int convertedXPos = 0;
        if (mouseX < (width/2)) {
          convertedXPos = -50;
        } else if (mouseX >= (width/2)) {
          convertedXPos = 50;
        }
        // Get Pitches
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 1:
            midiPitches = getCMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 4:
            midiPitches = getDMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 5:
            midiPitches = getDMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 8:
            midiPitches = getEMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 9:
            midiPitches = getEMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 10:
            midiPitches = getFMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 11:
            midiPitches = getFMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 14:
            midiPitches = getGMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 15:
            midiPitches = getGMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 18:
            midiPitches = getAMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 19:
            midiPitches = getAMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChord(convertedXPos, convertedYPos);
            break;
          case 22:
            midiPitches = getBMajorScaleChord(convertedXPos, convertedYPos);
            break;
          case 23:
            midiPitches = getBMinorScaleChord(convertedXPos, convertedYPos);
            break;
          default:
            midiPitches = getCMajorScaleChord(convertedXPos, convertedYPos);
        }
        
        if (!active[midiPitches[0]]) {
          active[midiPitches[0]] = true;
          myBus.sendNoteOn(1, midiPitches[0], 127);
          println("Note On");
        }
        if (!active[midiPitches[1]]) {
          active[midiPitches[1]] = true;
          myBus.sendNoteOn(1, midiPitches[1], 127);
          println("Note On");
        }
        if (!active[midiPitches[2]]) {
          active[midiPitches[2]] = true;
          myBus.sendNoteOn(1, midiPitches[2], 127);
          println("Note On");
        }
        currentMIDIChord = new MIDIChord(1, midiPitches, 127);
        drawWaterRipple(mouseX, mouseY);
      }
    } else if (pitchBend) {
      if ((mouseY >= 300) && (mouseY < 650)) {
        // Map Mouse Pointer Value to 0 to 16383
        int pitchBendValue = (int) map(mouseY, 649, 300, 0, 16383);
        myBus.sendMessage(224, pitchBendValue % 128, pitchBendValue / 128);
      }
    }
    
  } else if (editorMode) {
    if (edit && notes) {
      if ((mouseY >= 100) && (mouseY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(mouseY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(mouseY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(mouseY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(mouseY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(mouseY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(mouseY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(mouseY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(mouseY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(mouseY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(mouseY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(mouseY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(mouseY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(mouseY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
        }
        
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        for (int i = 0; i < track.size(); i++) {
          if ((track.get(i).getMessage().getMessage()[1] == midiPitch) && ((track.get(i).getTick() == tick) || (track.get(i).getTick() == tick-1))) {
            track.remove(track.get(i));
          }
        }
      }
    } else if (edit && chords) {
      if ((mouseY >= 300) && (mouseY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(mouseY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(mouseY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(mouseY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(mouseY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(mouseY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(mouseY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(mouseY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(mouseY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(mouseY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(mouseY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(mouseY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(mouseY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(mouseY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(mouseY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(mouseY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
        }
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        ArrayList<MidiEvent> notesToRemove = new ArrayList<MidiEvent>();
        for (int i = 0; i < chordsTrack.size(); i++) {
          if (((chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[0]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[1]) || (chordsTrack.get(i).getMessage().getMessage()[1] == midiPitches[2])) && ((chordsTrack.get(i).getTick() == tick) || (chordsTrack.get(i).getTick() == tick-1))) {
            notesToRemove.add(chordsTrack.get(i));
          }
        }
        for (int j = 0; j < notesToRemove.size(); j++) {
          // Remove all notes that make up a chord
          chordsTrack.remove(notesToRemove.get(j));
        }
      }
    } else if (edit && pitchBend) {
      if ((mouseY >= 500) && (mouseY <= 650)) {
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        currentPitchBendEditTick = tick;
        for (int i = 0; i < pitchBendTrack.size(); i++) {
          if ((pitchBendTrack.get(i).getTick() == tick) && (((pitchBendTrack.get(i).getMessage().getMessage()[2] * 128) + pitchBendTrack.get(i).getMessage().getMessage()[1]) != 8192)) {
            // Only remove if it's not the default pitch bend 8192 message and it's the same tick
            pitchBendTrack.remove(pitchBendTrack.get(i));
          }
        }
      }
    }
  }
}

void mouseReleased() {
  if (liveMode) {
    if (notes) {
      turnNoteOff(currentMIDINote);
      currentMIDINote = null; // Prevents unwanted Note Off messages
    } else if (chords) {
      turnChordOff(currentMIDIChord);
      currentMIDIChord = null; // Prevents unwanted Note Off messages
    } else if (pitchBend) {
      // Default to no pitch bend which is the value 8192
      myBus.sendMessage(224, 8192 % 128, 8192 / 128);
    }
  } else if (editorMode) {
    if (edit && notes) {
      if ((mouseY >= 100) && (mouseY <= 250)) {
        int midiPitch;
        switch (selectedMusicalKey) {
          case 0:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
            break;
          case 1:
            midiPitch = getCMinorScaleNoteFromEditor(mouseY);
            break;
          case 2:
            midiPitch = getCSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 3:
            midiPitch = getCSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 4:
            midiPitch = getDMajorScaleNoteFromEditor(mouseY);
            break;
          case 5:
            midiPitch = getDMinorScaleNoteFromEditor(mouseY);
            break;
          case 6:
            midiPitch = getDSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 7:
            midiPitch = getDSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 8:
            midiPitch = getEMajorScaleNoteFromEditor(mouseY);
            break;
          case 9:
            midiPitch = getEMinorScaleNoteFromEditor(mouseY);
            break;
          case 10:
            midiPitch = getFMajorScaleNoteFromEditor(mouseY);
            break;
          case 11:
            midiPitch = getFMinorScaleNoteFromEditor(mouseY);
            break;
          case 12:
            midiPitch = getFSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 13:
            midiPitch = getFSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 14:
            midiPitch = getGMajorScaleNoteFromEditor(mouseY);
            break;
          case 15:
            midiPitch = getGMinorScaleNoteFromEditor(mouseY);
            break;
          case 16:
            midiPitch = getGSharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 17:
            midiPitch = getGSharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 18:
            midiPitch = getAMajorScaleNoteFromEditor(mouseY);
            break;
          case 19:
            midiPitch = getAMinorScaleNoteFromEditor(mouseY);
            break;
          case 20:
            midiPitch = getASharpMajorScaleNoteFromEditor(mouseY);
            break;
          case 21:
            midiPitch = getASharpMinorScaleNoteFromEditor(mouseY);
            break;
          case 22:
            midiPitch = getBMajorScaleNoteFromEditor(mouseY);
            break;
          case 23:
            midiPitch = getBMinorScaleNoteFromEditor(mouseY);
            break;
          default:
            midiPitch = getCMajorScaleNoteFromEditor(mouseY);
        }
        
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addNote(midiPitch, tick);
      }
    } else if (edit && chords) {
      if ((mouseY >= 300) && (mouseY <= 450)) {
        int[] midiPitches = new int[3];
        switch (selectedMusicalKey) {
          case 0:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
            break;
          case 1:
            midiPitches = getCMinorScaleChordFromEditor(mouseY);
            break;
          case 2:
            midiPitches = getCSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 3:
            midiPitches = getCSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 4:
            midiPitches = getDMajorScaleChordFromEditor(mouseY);
            break;
          case 5:
            midiPitches = getDMinorScaleChordFromEditor(mouseY);
            break;
          case 6:
            midiPitches = getDSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 7:
            midiPitches = getDSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 8:
            midiPitches = getEMajorScaleChordFromEditor(mouseY);
            break;
          case 9:
            midiPitches = getEMinorScaleChordFromEditor(mouseY);
            break;
          case 10:
            midiPitches = getFMajorScaleChordFromEditor(mouseY);
            break;
          case 11:
            midiPitches = getFMinorScaleChordFromEditor(mouseY);
            break;
          case 12:
            midiPitches = getFSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 13:
            midiPitches = getFSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 14:
            midiPitches = getGMajorScaleChordFromEditor(mouseY);
            break;
          case 15:
            midiPitches = getGMinorScaleChordFromEditor(mouseY);
            break;
          case 16:
            midiPitches = getGSharpMajorScaleChordFromEditor(mouseY);
            break;
          case 17:
            midiPitches = getGSharpMinorScaleChordFromEditor(mouseY);
            break;
          case 18:
            midiPitches = getAMajorScaleChordFromEditor(mouseY);
            break;
          case 19:
            midiPitches = getAMinorScaleChordFromEditor(mouseY);
            break;
          case 20:
            midiPitches = getASharpMajorScaleChordFromEditor(mouseY);
            break;
          case 21:
            midiPitches = getASharpMinorScaleChordFromEditor(mouseY);
            break;
          case 22:
            midiPitches = getBMajorScaleChordFromEditor(mouseY);
            break;
          case 23:
            midiPitches = getBMinorScaleChordFromEditor(mouseY);
            break;
          default:
            midiPitches = getCMajorScaleChordFromEditor(mouseY);
        }
        int tick = (int) (mouseX/(width/sequencer.getTickLength()));
        // Prevents users from adding notes outside the loop accidentally
        if (tick >= 62) {
          tick = 62;
        }
        addChord(midiPitches, tick);
      }
    } else if (edit && pitchBend) {
      if ((mouseY >= 500) && (mouseY <= 650)) {
        int pitchBendValue = (int) map(mouseY, 650, 500, 0, 16383);
        addPitchBend(pitchBendValue, currentPitchBendEditTick);
      } else if ((mouseY < 500) && (mouseY > 450)) {
        // If a user drags mouse up to chords grid and beyond, cancel
        // Prevents unwanted actions when users click options in header
        int pitchBendValue = 16383;
        addPitchBend(pitchBendValue, currentPitchBendEditTick);
      } else if (mouseY > 650) {
        int pitchBendValue = 0;
        addPitchBend(pitchBendValue, currentPitchBendEditTick);
      }
    }
  }
}
// ####################################################

// ####################################################
// LOAD/SAVE MIDI FILES

// Save MIDI in the editor to a MIDI file
// Automatically called when the exportMIDI button is pressed
void exportMIDI() {
  JFileChooser fileChooser = new JFileChooser();
  if (fileChooser.showSaveDialog(null) == JFileChooser.APPROVE_OPTION) {
    File file = fileChooser.getSelectedFile();
    // Save to MIDI file
    try {
      MidiSystem.write(sequence, 1, file);
    } catch (IOException ioe) {
      ioe.printStackTrace();
    }
  }
}

// Load MIDI into the editor from a MIDI file
// Automatically called when the loadMIDI button is pressed
void loadMIDI() {
  JFileChooser fileChooser = new JFileChooser();
  if (fileChooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
    File file = fileChooser.getSelectedFile();
    // Load from MIDI file
    try {
      sequence = MidiSystem.getSequence(file);
      if (sequence.getTracks().length == 1) {
        track = sequence.getTracks()[0];
      } else if (sequence.getTracks().length > 1) {
        track = sequence.getTracks()[0];
        chordsTrack = sequence.getTracks()[1];
        pitchBendTrack = sequence.getTracks()[2];
      }
      sequencer.setSequence(sequence); // Important to now set the sequencer up with this loaded sequence
    } catch (IOException ioe) {
      ioe.printStackTrace();
    } catch (InvalidMidiDataException imde) {
      imde.printStackTrace();
    }
  }
}
// ####################################################

// ####################################################
// EDITOR MIDI NOTE & CHORD METHODS

public int getCMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 48;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 50;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 52;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 53;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 55;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 57;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 59;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 60;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 62;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 64;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 65;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 67;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 69;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 71;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 72;
  } else {
    return -1;
  }
}

public int getCMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 48;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 50;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 51;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 53;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 55;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 56;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 58;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 60;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 62;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 63;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 65;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 67;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 68;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 70;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 72;
  } else {
    return -1;
  }
}

public int getCSharpMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 49;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 51;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 53;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 54;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 56;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 58;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 60;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 61;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 63;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 65;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 66;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 68;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 70;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 72;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 73;
  } else {
    return -1;
  }
}

public int getCSharpMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 49;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 51;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 52;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 54;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 56;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 57;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 59;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 61;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 63;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 64;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 66;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 68;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 69;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 71;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 73;
  } else {
    return -1;
  }
}

public int getDMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 50;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 52;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 54;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 55;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 57;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 59;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 61;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 62;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 64;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 66;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 67;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 69;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 71;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 73;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 74;
  } else {
    return -1;
  }
}

public int getDMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 50;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 52;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 53;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 55;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 57;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 58;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 60;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 62;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 64;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 65;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 67;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 69;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 70;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 72;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 74;
  } else {
    return -1;
  }
}

public int getDSharpMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 51;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 53;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 55;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 56;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 58;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 60;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 62;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 63;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 65;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 67;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 68;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 70;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 72;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 74;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 75;
  } else {
    return -1;
  }
}

public int getDSharpMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 51;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 53;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 54;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 56;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 58;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 59;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 61;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 63;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 65;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 66;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 68;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 70;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 71;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 73;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 75;
  } else {
    return -1;
  }
}

public int getEMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 52;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 54;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 56;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 57;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 59;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 61;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 63;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 64;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 66;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 68;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 69;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 71;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 73;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 75;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 76;
  } else {
    return -1;
  }
}

public int getEMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 52;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 54;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 55;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 57;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 59;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 60;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 62;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 64;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 66;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 67;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 69;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 71;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 72;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 74;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 76;
  } else {
    return -1;
  }
}

public int getFMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 53;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 55;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 57;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 58;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 60;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 62;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 64;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 65;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 67;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 69;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 70;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 72;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 74;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 76;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 77;
  } else {
    return -1;
  }
}

public int getFMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 53;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 55;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 56;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 58;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 60;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 61;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 63;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 65;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 67;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 68;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 70;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 72;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 73;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 75;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 77;
  } else {
    return -1;
  }
}

public int getFSharpMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 54;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 56;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 58;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 59;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 61;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 63;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 65;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 66;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 68;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 70;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 71;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 73;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 75;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 77;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 78;
  } else {
    return -1;
  }
}

public int getFSharpMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 54;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 56;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 57;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 59;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 61;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 62;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 64;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 66;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 68;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 69;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 71;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 73;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 74;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 76;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 78;
  } else {
    return -1;
  }
}

public int getGMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 55;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 57;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 59;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 60;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 62;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 64;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 66;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 67;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 69;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 71;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 72;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 74;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 76;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 78;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 79;
  } else {
    return -1;
  }
}

public int getGMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 55;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 57;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 58;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 60;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 62;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 63;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 65;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 67;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 69;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 70;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 72;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 74;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 75;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 77;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 79;
  } else {
    return -1;
  }
}

public int getGSharpMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 56;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 58;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 60;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 61;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 63;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 65;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 67;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 68;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 70;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 72;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 73;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 75;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 77;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 79;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 80;
  } else {
    return -1;
  }
}

public int getGSharpMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 56;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 58;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 59;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 61;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 63;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 64;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 66;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 68;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 70;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 71;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 73;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 75;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 76;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 78;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 80;
  } else {
    return -1;
  }
}

public int getAMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 57;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 59;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 61;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 62;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 64;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 66;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 68;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 69;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 71;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 73;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 74;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 76;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 78;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 80;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 81;
  } else {
    return -1;
  }
}

public int getAMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 57;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 59;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 60;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 62;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 64;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 65;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 67;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 69;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 71;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 72;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 74;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 76;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 77;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 79;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 81;
  } else {
    return -1;
  }
}

public int getASharpMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 58;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 60;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 62;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 63;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 65;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 67;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 69;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 70;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 72;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 74;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 75;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 77;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 79;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 81;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 82;
  } else {
    return -1;
  }
}

public int getASharpMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 58;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 60;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 61;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 63;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 65;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 66;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 68;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 70;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 72;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 73;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 75;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 77;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 78;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 80;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 82;
  } else {
    return -1;
  }
}

public int getBMajorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 59;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 61;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 63;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 64;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 66;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 68;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 70;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 71;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 73;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 75;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 76;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 78;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 80;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 82;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 83;
  } else {
    return -1;
  }
}

public int getBMinorScaleNoteFromEditor(float yPoint) {
  if ((yPoint >= 240) && (yPoint < 250)) {
    return 59;
  } else if ((yPoint >= 230) && (yPoint < 240)) {
    return 61;
  } else if ((yPoint >= 220) && (yPoint < 230)) {
    return 62;
  } else if ((yPoint >= 210) && (yPoint < 220)) {
    return 64;
  } else if ((yPoint >= 200) && (yPoint < 210)) {
    return 66;
  } else if ((yPoint >= 190) && (yPoint < 200)) {
    return 67;
  } else if ((yPoint >= 180) && (yPoint < 190)) {
    return 69;
  } else if ((yPoint >= 170) && (yPoint < 180)) {
    return 71;
  } else if ((yPoint >= 160) && (yPoint < 170)) {
    return 73;
  } else if ((yPoint >= 150) && (yPoint < 160)) {
    return 74;
  } else if ((yPoint >= 140) && (yPoint < 150)) {
    return 76;
  } else if ((yPoint >= 130) && (yPoint < 140)) {
    return 78;
  } else if ((yPoint >= 120) && (yPoint < 130)) {
    return 79;
  } else if ((yPoint >= 110) && (yPoint < 120)) {
    return 81;
  } else if ((yPoint >= 100) && (yPoint < 110)) {
    return 83;
  } else {
    return -1;
  }
}

// EDITOR MIDI CHORD METHODS

public int[] getCMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {36,40,43};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {38,41,45};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {40,43,47};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {41,45,48};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {43,47,50};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {47,50,53};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {59,62,65};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {36,39,43};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {38,41,44};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {39,43,46};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {41,44,48};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {43,46,50};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {44,48,51};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {50,53,56};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCSharpMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {37,41,44};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {39,42,46};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {41,44,48};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {42,46,49};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {44,48,51};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {48,51,54};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {60,63,66};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getCSharpMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {37,40,44};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {39,42,45};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {40,44,47};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {42,45,49};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {44,47,51};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {45,49,52};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {51,54,57};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {38,42,45};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {40,43,47};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {42,45,49};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {43,47,50};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {45,49,52};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {49,52,55};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {61,64,67};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {38,41,45};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {40,43,46};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {41,45,48};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {43,46,50};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {52,55,58};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {62,65,69};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDSharpMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {39,43,46};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {41,44,48};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {43,46,50};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {44,48,51};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {50,53,56};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {62,65,68};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {63,67,70};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getDSharpMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {39,42,46};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {41,44,47};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {42,46,49};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {44,47,51};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {53,56,59};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {63,66,70};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getEMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {40,44,47};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {42,45,49};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {44,47,51};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {45,49,52};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {51,54,57};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {63,66,69};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {64,68,71};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getEMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {40,43,47};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {42,45,48};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {43,47,50};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {54,57,60};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {64,67,71};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {41,45,48};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {43,46,50};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {52,55,58};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {62,65,69};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {64,67,70};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {65,69,72};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {41,44,48};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {43,46,49};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {44,48,51};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {55,58,61};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {63,67,70};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {65,68,72};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFSharpMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {42,46,49};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {44,47,51};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {53,56,59};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {63,66,70};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {65,68,71};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {66,70,73};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getFSharpMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {42,45,49};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {44,47,50};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {45,49,52};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {56,59,62};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {64,68,71};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {66,69,73};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {43,47,50};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {54,57,60};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {64,67,71};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {66,69,72};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {67,71,74};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {43,46,50};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {45,48,51};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {57,60,63};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {62,65,69};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {63,67,70};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {65,69,72};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {67,70,74};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGSharpMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {44,48,51};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {55,58,61};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {63,67,70};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {65,68,72};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {67,70,73};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {68,72,75};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getGSharpMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {44,47,51};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {46,49,52};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {58,61,64};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {63,66,70};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {64,68,71};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {66,70,73};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {68,71,75};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getAMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {45,49,52};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {56,59,62};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {64,68,71};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {66,69,73};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {68,71,74};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {69,73,76};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getAMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {45,48,52};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {47,50,53};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {48,52,55};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {57,60,64};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {59,62,65};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {60,64,67};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {62,65,69};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {64,67,71};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {65,69,72};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {67,71,74};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {69,72,76};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getASharpMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {46,50,53};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {48,51,55};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {50,53,57};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {51,55,58};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {53,57,60};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {55,58,62};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {57,60,63};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {58,62,65};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {60,63,67};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {62,65,69};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {63,67,70};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {65,69,72};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {67,70,74};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {69,72,75};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {70,74,77};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getASharpMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {46,49,53};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {48,51,54};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {49,53,56};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {53,56,60};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {56,60,63};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {58,61,65};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {60,63,66};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {61,65,68};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {63,66,70};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {65,68,72};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {66,70,73};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {68,72,75};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {70,73,77};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getBMajorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {47,51,54};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {49,52,56};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {51,54,58};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {52,56,59};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {54,58,61};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {56,59,63};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {58,61,64};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {59,63,66};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {61,64,68};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {63,66,70};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {64,68,71};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {66,70,73};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {68,71,75};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {70,73,76};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {71,75,78};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public int[] getBMinorScaleChordFromEditor(float yPoint) {
  if ((yPoint >= 440) && (yPoint < 450)) {
    int[] pitches = {47,50,54};
    return pitches;
  } else if ((yPoint >= 430) && (yPoint < 440)) {
    int[] pitches = {49,52,55};
    return pitches;
  } else if ((yPoint >= 420) && (yPoint < 430)) {
    int[] pitches = {50,54,57};
    return pitches;
  } else if ((yPoint >= 410) && (yPoint < 420)) {
    int[] pitches = {52,55,59};
    return pitches;
  } else if ((yPoint >= 400) && (yPoint < 410)) {
    int[] pitches = {54,57,61};
    return pitches;
  } else if ((yPoint >= 390) && (yPoint < 400)) {
    int[] pitches = {55,59,62};
    return pitches;
  } else if ((yPoint >= 380) && (yPoint < 390)) {
    int[] pitches = {57,61,64};
    return pitches;
  } else if ((yPoint >= 370) && (yPoint < 380)) {
    int[] pitches = {59,62,66};
    return pitches;
  } else if ((yPoint >= 360) && (yPoint < 370)) {
    int[] pitches = {61,64,67};
    return pitches;
  } else if ((yPoint >= 350) && (yPoint < 360)) {
    int[] pitches = {62,66,69};
    return pitches;
  } else if ((yPoint >= 340) && (yPoint < 350)) {
    int[] pitches = {64,67,71};
    return pitches;
  } else if ((yPoint >= 330) && (yPoint < 340)) {
    int[] pitches = {66,69,73};
    return pitches;
  } else if ((yPoint >= 320) && (yPoint < 330)) {
    int[] pitches = {67,71,74};
    return pitches;
  } else if ((yPoint >= 310) && (yPoint < 320)) {
    int[] pitches = {69,73,76};
    return pitches;
  } else if ((yPoint >= 300) && (yPoint < 310)) {
    int[] pitches = {71,74,78};
    return pitches;
  } else {
    int[] pitches = {-1,-1,-1};
    return pitches;
  }
}

public String getPitchNoteText(int pitch) {
  String textToReturn = "";
  switch (pitch) {
    case 36:
      textToReturn = "C2";
      break;
    case 37:
      textToReturn = "C#2";
      break;
    case 38:
      textToReturn = "D2";
      break;
    case 39:
      textToReturn = "D#2";
      break;
    case 40:
      textToReturn = "E2";
      break;
    case 41:
      textToReturn = "F2";
      break;
    case 42:
      textToReturn = "F#2";
      break;
    case 43:
      textToReturn = "G2";
      break;
    case 44:
      textToReturn = "G#2";
      break;
    case 45:
      textToReturn = "A2";
      break;
    case 46:
      textToReturn = "A#2";
      break;
    case 47:
      textToReturn = "B2";
      break;
    case 48:
      textToReturn = "C3";
      break;
    case 49:
      textToReturn = "C#3";
      break;
    case 50:
      textToReturn = "D3";
      break;
    case 51:
      textToReturn = "D#3";
      break;
    case 52:
      textToReturn = "E3";
      break;
    case 53:
      textToReturn = "F3";
      break;
    case 54:
      textToReturn = "F#3";
      break;
    case 55:
      textToReturn = "G3";
      break;
    case 56:
      textToReturn = "G#3";
      break;
    case 57:
      textToReturn = "A3";
      break;
    case 58:
      textToReturn = "A#3";
      break;
    case 59:
      textToReturn = "B3";
      break;
    case 60:
      textToReturn = "C4";
      break;
    case 61:
      textToReturn = "C#4";
      break;
    case 62:
      textToReturn = "D4";
      break;
    case 63:
      textToReturn = "D#4";
      break;
    case 64:
      textToReturn = "E4";
      break;
    case 65:
      textToReturn = "F4";
      break;
    case 66:
      textToReturn = "F#4";
      break;
    case 67:
      textToReturn = "G4";
      break;
    case 68:
      textToReturn = "G#4";
      break;
    case 69:
      textToReturn = "A4";
      break;
    case 70:
      textToReturn = "A#4";
      break;
    case 71:
      textToReturn = "B4";
      break;
    case 72:
      textToReturn = "C5";
      break;
    case 73:
      textToReturn = "C#5";
      break;
    case 74:
      textToReturn = "D5";
      break;
    case 75:
      textToReturn = "D#5";
      break;
    case 76:
      textToReturn = "E5";
      break;
    case 77:
      textToReturn = "F5";
      break;
    case 78:
      textToReturn = "F#5";
      break;
    case 79:
      textToReturn = "G5";
      break;
    case 80:
      textToReturn = "G#5";
      break;
    case 81:
      textToReturn = "A5";
      break;
    case 82:
      textToReturn = "A#5";
      break;
    case 83:
      textToReturn = "B5";
      break;
    default:
      textToReturn = "";
  }
  return textToReturn;
}

public String getChordTypeText(int yPos) {
  if (selectedMusicalKey % 2 == 0) {
    return getMajorKeyChordTypeText(yPos);
  } else {
    return getMinorKeyChordTypeText(yPos);
  }
}

public String getMajorKeyChordTypeText(int yPos) {
  String textToReturn = "";
  if (yPos == 300) {
    textToReturn = "Maj";
  } else if (yPos == 310) {
    textToReturn = "Dim";
  } else if (yPos == 320) {
    textToReturn = "Min";
  } else if (yPos == 330) {
    textToReturn = "Maj";
  } else if (yPos == 340) {
    textToReturn = "Maj";
  } else if (yPos == 350) {
    textToReturn = "Min";
  } else if (yPos == 360) {
    textToReturn = "Min";
  } else if (yPos == 370) {
    textToReturn = "Maj";
  } else if (yPos == 380) {
    textToReturn = "Dim";
  } else if (yPos == 390) {
    textToReturn = "Min";
  } else if (yPos == 400) {
    textToReturn = "Maj";
  } else if (yPos == 410) {
    textToReturn = "Maj";
  } else if (yPos == 420) {
    textToReturn = "Min";
  } else if (yPos == 430) {
    textToReturn = "Min";
  } else if (yPos == 440) {
    textToReturn = "Maj";
  } else {
    textToReturn = "";
  }
  return textToReturn;
}

public String getMinorKeyChordTypeText(int yPos) {
  String textToReturn = "";
  if (yPos == 300) {
    textToReturn = "Min";
  } else if (yPos == 310) {
    textToReturn = "Maj";
  } else if (yPos == 320) {
    textToReturn = "Maj";
  } else if (yPos == 330) {
    textToReturn = "Min";
  } else if (yPos == 340) {
    textToReturn = "Min";
  } else if (yPos == 350) {
    textToReturn = "Maj";
  } else if (yPos == 360) {
    textToReturn = "Dim";
  } else if (yPos == 370) {
    textToReturn = "Min";
  } else if (yPos == 380) {
    textToReturn = "Maj";
  } else if (yPos == 390) {
    textToReturn = "Maj";
  } else if (yPos == 400) {
    textToReturn = "Min";
  } else if (yPos == 410) {
    textToReturn = "Min";
  } else if (yPos == 420) {
    textToReturn = "Maj";
  } else if (yPos == 430) {
    textToReturn = "Dim";
  } else if (yPos == 440) {
    textToReturn = "Min";
  } else {
    textToReturn = "";
  }
  return textToReturn;
}

// ####################################################
