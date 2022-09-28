// Interface Keyboard Class
// Author = Joseph Cameron
// Part of The Novel MIDI Controller
// This class is responsible for drawing the correct information for every key

final class InterfaceKeyboard {
  
  int scaleSelected;
  
  public InterfaceKeyboard(int scaleSelected) {
    this.scaleSelected = scaleSelected;
  }
  
  void draw() {
    if (selectedMusicalKey == 0) {
      // C Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: C Major", width/2, 125);
        text("Characteristics of C Major: Happy, Innocent, and Childlike", width/2, 175);
        text("Example of music written in C Major: Piano Man by Billy Joel", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("B3", width/4, 325);
          text("A3", width/4, 375);
          text("G3", width/4, 425);
          text("F3", width/4, 475);
          text("E3", width/4, 525);
          text("D3", width/4, 575);
          text("C3", width/4, 625);
          
          text("B4", 3*(width/4), 325);
          text("A4", 3*(width/4), 375);
          text("G4", 3*(width/4), 425);
          text("F4", 3*(width/4), 475);
          text("E4", 3*(width/4), 525);
          text("D4", 3*(width/4), 575);
          text("C4", 3*(width/4), 625);
        } else if (chords) {
          text("B2 Diminished", width/4, 325);
          text("A2 Minor", width/4, 375);
          text("G2 Major", width/4, 425);
          text("F2 Major", width/4, 475);
          text("E2 Minor", width/4, 525);
          text("D2 Minor", width/4, 575);
          text("C2 Major", width/4, 625);
          
          text("B3 Diminished", 3*(width/4), 325);
          text("A3 Minor", 3*(width/4), 375);
          text("G3 Major", 3*(width/4), 425);
          text("F3 Major", 3*(width/4), 475);
          text("E3 Minor", 3*(width/4), 525);
          text("D3 Minor", 3*(width/4), 575);
          text("C3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("C5", 5, 107);
        text("B4", 5, 117);
        text("A4", 5, 127);
        text("G4", 5, 137);
        text("F4", 5, 147);
        text("E4", 5, 157);
        text("D4", 5, 167);
        text("C4", 5, 177);
        text("B3", 5, 187);
        text("A3", 5, 197);
        text("G3", 5, 207);
        text("F3", 5, 217);
        text("E3", 5, 227);
        text("D3", 5, 237);
        text("C3", 5, 247);
        
        text("C4 Maj", 5, 307);
        text("B3 Dim", 5, 317);
        text("A3 Min", 5, 327);
        text("G3 Maj", 5, 337);
        text("F3 Maj", 5, 347);
        text("E3 Min", 5, 357);
        text("D3 Min", 5, 367);
        text("C3 Maj", 5, 377);
        text("B2 Dim", 5, 387);
        text("A2 Min", 5, 397);
        text("G2 Maj", 5, 407);
        text("F2 Maj", 5, 417);
        text("E2 Min", 5, 427);
        text("D2 Min", 5, 437);
        text("C2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 1) {
      // C Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: C Minor", width/2, 125);
        text("Characteristics of C Minor: Sad, Innocent, and Lovesick", width/2, 175);
        text("Example of music written in C Minor: Symphony No. 5 by Beethoven", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("A#3", width/4, 325);
          text("G#3", width/4, 375);
          text("G3", width/4, 425);
          text("F3", width/4, 475);
          text("D#3", width/4, 525);
          text("D3", width/4, 575);
          text("C3", width/4, 625);
          
          text("A#4", 3*(width/4), 325);
          text("G#4", 3*(width/4), 375);
          text("G4", 3*(width/4), 425);
          text("F4", 3*(width/4), 475);
          text("D#4", 3*(width/4), 525);
          text("D4", 3*(width/4), 575);
          text("C4", 3*(width/4), 625);
        } else if (chords) {
          text("A#2 Major", width/4, 325);
          text("G#2 Major", width/4, 375);
          text("G2 Minor", width/4, 425);
          text("F2 Minor", width/4, 475);
          text("D#2 Major", width/4, 525);
          text("D2 Diminished", width/4, 575);
          text("C2 Minor", width/4, 625);
          
          text("A#3 Major", 3*(width/4), 325);
          text("G#3 Major", 3*(width/4), 375);
          text("G3 Minor", 3*(width/4), 425);
          text("F3 Minor", 3*(width/4), 475);
          text("D#3 Major", 3*(width/4), 525);
          text("D3 Diminished", 3*(width/4), 575);
          text("C3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("C5", 5, 107);
        text("A#4", 5, 117);
        text("G#4", 5, 127);
        text("G4", 5, 137);
        text("F4", 5, 147);
        text("D#4", 5, 157);
        text("D4", 5, 167);
        text("C4", 5, 177);
        text("A#3", 5, 187);
        text("G#3", 5, 197);
        text("G3", 5, 207);
        text("F3", 5, 217);
        text("D#3", 5, 227);
        text("D3", 5, 237);
        text("C3", 5, 247);
        
        text("C4 Min", 5, 307);
        text("A#3 Maj", 5, 317);
        text("G#3 Maj", 5, 327);
        text("G3 Min", 5, 337);
        text("F3 Min", 5, 347);
        text("D#3 Maj", 5, 357);
        text("D3 Dim", 5, 367);
        text("C3 Min", 5, 377);
        text("A#2 Maj", 5, 387);
        text("G#2 Maj", 5, 397);
        text("G2 Min", 5, 407);
        text("F2 Min", 5, 417);
        text("D#2 Maj", 5, 427);
        text("D2 Dim", 5, 437);
        text("C2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 2) {
      // C Sharp Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: C# Major", width/2, 125);
        text("Characteristics of C# Major: Grieving, Leering, and Unusual", width/2, 175);
        text("Example of music written in C# Major: Clair de Lune by Claude Debussy", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("C4", width/4, 325);
          text("A#3", width/4, 375);
          text("G#3", width/4, 425);
          text("F#3", width/4, 475);
          text("F3", width/4, 525);
          text("D#3", width/4, 575);
          text("C#3", width/4, 625);
          
          text("C5", 3*(width/4), 325);
          text("A#4", 3*(width/4), 375);
          text("G#4", 3*(width/4), 425);
          text("F#4", 3*(width/4), 475);
          text("F4", 3*(width/4), 525);
          text("D#4", 3*(width/4), 575);
          text("C#4", 3*(width/4), 625);
        } else if (chords) {
          text("C3 Diminished", width/4, 325);
          text("A#2 Minor", width/4, 375);
          text("G#2 Major", width/4, 425);
          text("F#2 Major", width/4, 475);
          text("F2 Minor", width/4, 525);
          text("D#2 Minor", width/4, 575);
          text("C#2 Major", width/4, 625);
          
          text("C4 Diminished", 3*(width/4), 325);
          text("A#3 Minor", 3*(width/4), 375);
          text("G#3 Major", 3*(width/4), 425);
          text("F#3 Major", 3*(width/4), 475);
          text("F3 Minor", 3*(width/4), 525);
          text("D#3 Minor", 3*(width/4), 575);
          text("C#3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("C#5", 5, 107);
        text("C5", 5, 117);
        text("A#4", 5, 127);
        text("G#4", 5, 137);
        text("F#4", 5, 147);
        text("F4", 5, 157);
        text("D#4", 5, 167);
        text("C#4", 5, 177);
        text("C4", 5, 187);
        text("A#3", 5, 197);
        text("G#3", 5, 207);
        text("F#3", 5, 217);
        text("F3", 5, 227);
        text("D#3", 5, 237);
        text("C#3", 5, 247);
        
        text("C#4 Maj", 5, 307);
        text("C4 Dim", 5, 317);
        text("A#3 Min", 5, 327);
        text("G#3 Maj", 5, 337);
        text("F#3 Maj", 5, 347);
        text("F3 Min", 5, 357);
        text("D#3 Min", 5, 367);
        text("C#3 Maj", 5, 377);
        text("C3 Dim", 5, 387);
        text("A#2 Min", 5, 397);
        text("G#2 Maj", 5, 407);
        text("F#2 Maj", 5, 417);
        text("F2 Min", 5, 427);
        text("D#2 Min", 5, 437);
        text("C#2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 3) {
      // C Sharp Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: C# Minor", width/2, 125);
        text("Characteristics of C# Minor: Passionate, Intimate, and Sad", width/2, 175);
        text("Examples of music written in C# Minor: Levels by Avicii, ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("B3", width/4, 325);
          text("A3", width/4, 375);
          text("G#3", width/4, 425);
          text("F#3", width/4, 475);
          text("E3", width/4, 525);
          text("D#3", width/4, 575);
          text("C#3", width/4, 625);
          
          text("B4", 3*(width/4), 325);
          text("A4", 3*(width/4), 375);
          text("G#4", 3*(width/4), 425);
          text("F#4", 3*(width/4), 475);
          text("E4", 3*(width/4), 525);
          text("D#4", 3*(width/4), 575);
          text("C#4", 3*(width/4), 625);
        } else if (chords) {
          text("B2 Major", width/4, 325);
          text("A2 Major", width/4, 375);
          text("G#2 Minor", width/4, 425);
          text("F#2 Minor", width/4, 475);
          text("E2 Major", width/4, 525);
          text("D#2 Diminished", width/4, 575);
          text("C#2 Minor", width/4, 625);
          
          text("B3 Major", 3*(width/4), 325);
          text("A3 Major", 3*(width/4), 375);
          text("G#3 Minor", 3*(width/4), 425);
          text("F#3 Minor", 3*(width/4), 475);
          text("E3 Major", 3*(width/4), 525);
          text("D#3 Diminished", 3*(width/4), 575);
          text("C#3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("C#5", 5, 107);
        text("B4", 5, 117);
        text("A4", 5, 127);
        text("G#4", 5, 137);
        text("F#4", 5, 147);
        text("E4", 5, 157);
        text("D#4", 5, 167);
        text("C#4", 5, 177);
        text("B3", 5, 187);
        text("A3", 5, 197);
        text("G#3", 5, 207);
        text("F#3", 5, 217);
        text("E3", 5, 227);
        text("D#3", 5, 237);
        text("C#3", 5, 247);
        
        text("C#4 Min", 5, 307);
        text("B3 Maj", 5, 317);
        text("A3 Maj", 5, 327);
        text("G#3 Min", 5, 337);
        text("F#3 Min", 5, 347);
        text("E3 Maj", 5, 357);
        text("D#3 Dim", 5, 367);
        text("C#3 Min", 5, 377);
        text("B2 Maj", 5, 387);
        text("A2 Maj", 5, 397);
        text("G#2 Min", 5, 407);
        text("F#2 Min", 5, 417);
        text("E2 Maj", 5, 427);
        text("D#2 Dim", 5, 437);
        text("C#2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 4) {
      // D Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: D Major", width/2, 125);
        text("Characteristics of D Major: Triumphant, Rejoiceful, and Victorious", width/2, 175);
        text("Example of music written in D Major: Comfortably Numb by Pink Floyd", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("C#4", width/4, 325);
          text("B3", width/4, 375);
          text("A3", width/4, 425);
          text("G3", width/4, 475);
          text("F#3", width/4, 525);
          text("E3", width/4, 575);
          text("D3", width/4, 625);
          
          text("C#5", 3*(width/4), 325);
          text("B4", 3*(width/4), 375);
          text("A4", 3*(width/4), 425);
          text("G4", 3*(width/4), 475);
          text("F#4", 3*(width/4), 525);
          text("E4", 3*(width/4), 575);
          text("D4", 3*(width/4), 625);
        } else if (chords) {
          text("C#3 Diminished", width/4, 325);
          text("B2 Minor", width/4, 375);
          text("A2 Major", width/4, 425);
          text("G2 Major", width/4, 475);
          text("F#2 Minor", width/4, 525);
          text("E2 Minor", width/4, 575);
          text("D2 Major", width/4, 625);
          
          text("C#4 Diminished", 3*(width/4), 325);
          text("B3 Minor", 3*(width/4), 375);
          text("A3 Major", 3*(width/4), 425);
          text("G3 Major", 3*(width/4), 475);
          text("F#3 Minor", 3*(width/4), 525);
          text("E3 Minor", 3*(width/4), 575);
          text("D3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("D5", 5, 107);
        text("C#5", 5, 117);
        text("B4", 5, 127);
        text("A4", 5, 137);
        text("G4", 5, 147);
        text("F#4", 5, 157);
        text("E4", 5, 167);
        text("D4", 5, 177);
        text("C#4", 5, 187);
        text("B3", 5, 197);
        text("A3", 5, 207);
        text("G3", 5, 217);
        text("F#3", 5, 227);
        text("E3", 5, 237);
        text("D3", 5, 247);
        
        text("D4 Maj", 5, 307);
        text("C#4 Dim", 5, 317);
        text("B3 Min", 5, 327);
        text("A3 Maj", 5, 337);
        text("G3 Maj", 5, 347);
        text("F#3 Min", 5, 357);
        text("E3 Min", 5, 367);
        text("D3 Maj", 5, 377);
        text("C#3 Dim", 5, 387);
        text("B2 Min", 5, 397);
        text("A2 Maj", 5, 407);
        text("G2 Maj", 5, 417);
        text("F#2 Min", 5, 427);
        text("E2 Min", 5, 437);
        text("D2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 5) {
      // D Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: D Minor", width/2, 125);
        text("Characteristics of D Minor: Melancholic, Anxious, and Serious", width/2, 175);
        text("Example of music written in D Minor: In the Air Tonight by Phil Collins", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("C4", width/4, 325);
          text("A#3", width/4, 375);
          text("A3", width/4, 425);
          text("G3", width/4, 475);
          text("F3", width/4, 525);
          text("E3", width/4, 575);
          text("D3", width/4, 625);
          
          text("C5", 3*(width/4), 325);
          text("A#4", 3*(width/4), 375);
          text("A4", 3*(width/4), 425);
          text("G4", 3*(width/4), 475);
          text("F4", 3*(width/4), 525);
          text("E4", 3*(width/4), 575);
          text("D4", 3*(width/4), 625);
        } else if (chords) {
          text("C3 Major", width/4, 325);
          text("A#2 Major", width/4, 375);
          text("A2 Minor", width/4, 425);
          text("G2 Minor", width/4, 475);
          text("F2 Major", width/4, 525);
          text("E2 Diminished", width/4, 575);
          text("D2 Minor", width/4, 625);
          
          text("C4 Major", 3*(width/4), 325);
          text("A#3 Major", 3*(width/4), 375);
          text("A3 Minor", 3*(width/4), 425);
          text("G3 Minor", 3*(width/4), 475);
          text("F3 Major", 3*(width/4), 525);
          text("E3 Diminished", 3*(width/4), 575);
          text("D3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("D5", 5, 107);
        text("C5", 5, 117);
        text("A#4", 5, 127);
        text("A4", 5, 137);
        text("G4", 5, 147);
        text("F4", 5, 157);
        text("E4", 5, 167);
        text("D4", 5, 177);
        text("C4", 5, 187);
        text("A#3", 5, 197);
        text("A3", 5, 207);
        text("G3", 5, 217);
        text("F3", 5, 227);
        text("E3", 5, 237);
        text("D3", 5, 247);
        
        text("D4 Min", 5, 307);
        text("C4 Maj", 5, 317);
        text("A#3 Maj", 5, 327);
        text("A3 Min", 5, 337);
        text("G3 Min", 5, 347);
        text("F3 Maj", 5, 357);
        text("E3 Dim", 5, 367);
        text("D3 Min", 5, 377);
        text("C3 Maj", 5, 387);
        text("A#2 Maj", 5, 397);
        text("A2 Min", 5, 407);
        text("G2 Min", 5, 417);
        text("F2 Maj", 5, 427);
        text("E2 Dim", 5, 437);
        text("D2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 6) {
      // D Sharp Major / Eb Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: D# Major / Eb Major", width/2, 125);
        text("Characteristics of D# Major / Eb Major: Loving, Devoted, and Religious", width/2, 175);
        //text("Example of music written in D# Major / Eb Major: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("D4", width/4, 325);
          text("C4", width/4, 375);
          text("A#3", width/4, 425);
          text("G#3", width/4, 475);
          text("G3", width/4, 525);
          text("F3", width/4, 575);
          text("D#3", width/4, 625);
          
          text("D5", 3*(width/4), 325);
          text("C5", 3*(width/4), 375);
          text("A#4", 3*(width/4), 425);
          text("G#4", 3*(width/4), 475);
          text("G4", 3*(width/4), 525);
          text("F4", 3*(width/4), 575);
          text("D#4", 3*(width/4), 625);
        } else if (chords) {
          text("D3 Diminished", width/4, 325);
          text("C3 Minor", width/4, 375);
          text("A#2 Major", width/4, 425);
          text("G#2 Major", width/4, 475);
          text("G2 Minor", width/4, 525);
          text("F2 Minor", width/4, 575);
          text("D#2 Major", width/4, 625);
          
          text("D4 Diminished", 3*(width/4), 325);
          text("C4 Minor", 3*(width/4), 375);
          text("A#3 Major", 3*(width/4), 425);
          text("G#3 Major", 3*(width/4), 475);
          text("G3 Minor", 3*(width/4), 525);
          text("F3 Minor", 3*(width/4), 575);
          text("D#3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("D#5", 5, 107);
        text("D5", 5, 117);
        text("C5", 5, 127);
        text("A#4", 5, 137);
        text("G#4", 5, 147);
        text("G4", 5, 157);
        text("F4", 5, 167);
        text("D#4", 5, 177);
        text("D4", 5, 187);
        text("C4", 5, 197);
        text("A#3", 5, 207);
        text("G#3", 5, 217);
        text("G3", 5, 227);
        text("F3", 5, 237);
        text("D#3", 5, 247);
        
        text("D#4 Maj", 5, 307);
        text("D4 Dim", 5, 317);
        text("C4 Min", 5, 327);
        text("A#3 Maj", 5, 337);
        text("G#3 Maj", 5, 347);
        text("G3 Min", 5, 357);
        text("F3 Min", 5, 367);
        text("D#3 Maj", 5, 377);
        text("D3 Dim", 5, 387);
        text("C3 Min", 5, 397);
        text("A#2 Maj", 5, 407);
        text("G#2 Maj", 5, 417);
        text("G2 Min", 5, 427);
        text("F2 Min", 5, 437);
        text("D#2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 7) {
      // D Sharp Minor / Eb Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: D# Minor", width/2, 125);
        text("Characteristics of D# Minor: Fearful, Distressed, and Existentially Terrified", width/2, 175);
        text("Example of music written in D# Minor: Take Five by Dave Brubeck", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("C#4", width/4, 325);
          text("B3", width/4, 375);
          text("A#3", width/4, 425);
          text("G#3", width/4, 475);
          text("F#3", width/4, 525);
          text("F3", width/4, 575);
          text("D#3", width/4, 625);
          
          text("C#5", 3*(width/4), 325);
          text("B4", 3*(width/4), 375);
          text("A#4", 3*(width/4), 425);
          text("G#4", 3*(width/4), 475);
          text("F#4", 3*(width/4), 525);
          text("F4", 3*(width/4), 575);
          text("D#4", 3*(width/4), 625);
        } else if (chords) {
          text("C#3 Major", width/4, 325);
          text("B2 Major", width/4, 375);
          text("A#2 Minor", width/4, 425);
          text("G#2 Minor", width/4, 475);
          text("F#2 Major", width/4, 525);
          text("F2 Diminished", width/4, 575);
          text("D#2 Minor", width/4, 625);
          
          text("C#4 Major", 3*(width/4), 325);
          text("B3 Major", 3*(width/4), 375);
          text("A#3 Minor", 3*(width/4), 425);
          text("G#3 Minor", 3*(width/4), 475);
          text("F#3 Major", 3*(width/4), 525);
          text("F3 Diminished", 3*(width/4), 575);
          text("D#3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("D#5", 5, 107);
        text("C#5", 5, 117);
        text("B4", 5, 127);
        text("A#4", 5, 137);
        text("G#4", 5, 147);
        text("F#4", 5, 157);
        text("F4", 5, 167);
        text("D#4", 5, 177);
        text("C#4", 5, 187);
        text("B3", 5, 197);
        text("A#3", 5, 207);
        text("G#3", 5, 217);
        text("F#3", 5, 227);
        text("F3", 5, 237);
        text("D#3", 5, 247);
        
        text("D#4 Min", 5, 307);
        text("C#4 Maj", 5, 317);
        text("B3 Maj", 5, 327);
        text("A#3 Min", 5, 337);
        text("G#3 Min", 5, 347);
        text("F#3 Maj", 5, 357);
        text("F3 Dim", 5, 367);
        text("D#3 Min", 5, 377);
        text("C#3 Maj", 5, 387);
        text("B2 Maj", 5, 397);
        text("A#2 Min", 5, 407);
        text("G#2 Min", 5, 417);
        text("F#2 Maj", 5, 427);
        text("F2 Dim", 5, 437);
        text("D#2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 8) {
      // E Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: E Major", width/2, 125);
        text("Characteristics of E Major: Delightful, Joyous, and Full of Pleasure", width/2, 175);
        text("Example of music written in E Major: Peer Gynt Suite No. 1 by Edvard Grieg", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("D#4", width/4, 325);
          text("C#4", width/4, 375);
          text("B3", width/4, 425);
          text("A3", width/4, 475);
          text("G#3", width/4, 525);
          text("F#3", width/4, 575);
          text("E3", width/4, 625);
          
          text("D#5", 3*(width/4), 325);
          text("C#5", 3*(width/4), 375);
          text("B4", 3*(width/4), 425);
          text("A4", 3*(width/4), 475);
          text("G#4", 3*(width/4), 525);
          text("F#4", 3*(width/4), 575);
          text("E4", 3*(width/4), 625);
        } else if (chords) {
          text("D#3 Diminished", width/4, 325);
          text("C#3 Minor", width/4, 375);
          text("B2 Major", width/4, 425);
          text("A2 Major", width/4, 475);
          text("G#2 Minor", width/4, 525);
          text("F#2 Minor", width/4, 575);
          text("E2 Major", width/4, 625);
          
          text("D#4 Diminished", 3*(width/4), 325);
          text("C#4 Minor", 3*(width/4), 375);
          text("B3 Major", 3*(width/4), 425);
          text("A3 Major", 3*(width/4), 475);
          text("G#3 Minor", 3*(width/4), 525);
          text("F#3 Minor", 3*(width/4), 575);
          text("E3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("E5", 5, 107);
        text("D#5", 5, 117);
        text("C#5", 5, 127);
        text("B4", 5, 137);
        text("A4", 5, 147);
        text("G#4", 5, 157);
        text("F#4", 5, 167);
        text("E4", 5, 177);
        text("D#4", 5, 187);
        text("C#4", 5, 197);
        text("B3", 5, 207);
        text("A3", 5, 217);
        text("G#3", 5, 227);
        text("F#3", 5, 237);
        text("E3", 5, 247);
        
        text("E4 Maj", 5, 307);
        text("D#4 Dim", 5, 317);
        text("C#4 Min", 5, 327);
        text("B3 Maj", 5, 337);
        text("A3 Maj", 5, 347);
        text("G#3 Min", 5, 357);
        text("F#3 Min", 5, 367);
        text("E3 Maj", 5, 377);
        text("D#3 Dim", 5, 387);
        text("C#3 Min", 5, 397);
        text("B2 Maj", 5, 407);
        text("A2 Maj", 5, 417);
        text("G#2 Min", 5, 427);
        text("F#2 Min", 5, 437);
        text("E2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 9) {
      // E Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: E Minor", width/2, 125);
        text("Characteristics of E Minor: Sad, Mournful, and Restless", width/2, 175);
        text("Example of music written in E Minor: The Chain by Fleetwood Mac", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("D4", width/4, 325);
          text("C4", width/4, 375);
          text("B3", width/4, 425);
          text("A3", width/4, 475);
          text("G3", width/4, 525);
          text("F#3", width/4, 575);
          text("E3", width/4, 625);
          
          text("D5", 3*(width/4), 325);
          text("C5", 3*(width/4), 375);
          text("B4", 3*(width/4), 425);
          text("A4", 3*(width/4), 475);
          text("G4", 3*(width/4), 525);
          text("F#4", 3*(width/4), 575);
          text("E4", 3*(width/4), 625);
        } else if (chords) {
          text("D3 Major", width/4, 325);
          text("C3 Major", width/4, 375);
          text("B2 Minor", width/4, 425);
          text("A2 Minor", width/4, 475);
          text("G2 Major", width/4, 525);
          text("F#2 Diminished", width/4, 575);
          text("E2 Minor", width/4, 625);
          
          text("D4 Major", 3*(width/4), 325);
          text("C4 Major", 3*(width/4), 375);
          text("B3 Minor", 3*(width/4), 425);
          text("A3 Minor", 3*(width/4), 475);
          text("G3 Major", 3*(width/4), 525);
          text("F#3 Diminished", 3*(width/4), 575);
          text("E3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("E5", 5, 107);
        text("D5", 5, 117);
        text("C5", 5, 127);
        text("B4", 5, 137);
        text("A4", 5, 147);
        text("G4", 5, 157);
        text("F#4", 5, 167);
        text("E4", 5, 177);
        text("D4", 5, 187);
        text("C4", 5, 197);
        text("B3", 5, 207);
        text("A3", 5, 217);
        text("G3", 5, 227);
        text("F#3", 5, 237);
        text("E3", 5, 247);
        
        text("E4 Min", 5, 307);
        text("D4 Maj", 5, 317);
        text("C4 Maj", 5, 327);
        text("B3 Min", 5, 337);
        text("A3 Min", 5, 347);
        text("G3 Maj", 5, 357);
        text("F#3 Dim", 5, 367);
        text("E3 Min", 5, 377);
        text("D3 Maj", 5, 387);
        text("C3 Maj", 5, 397);
        text("B2 Min", 5, 407);
        text("A2 Min", 5, 417);
        text("G2 Maj", 5, 427);
        text("F#2 Dim", 5, 437);
        text("E2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 10) {
      // F Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: F Major", width/2, 125);
        text("Characteristics of F Major: Calm, Complacent, and Angry", width/2, 175);
        text("Example of music written in F Major: Yesterday by The Beatles", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("E4", width/4, 325);
          text("D4", width/4, 375);
          text("C4", width/4, 425);
          text("A#3", width/4, 475);
          text("A3", width/4, 525);
          text("G3", width/4, 575);
          text("F3", width/4, 625);
          
          text("E5", 3*(width/4), 325);
          text("D5", 3*(width/4), 375);
          text("C5", 3*(width/4), 425);
          text("A#4", 3*(width/4), 475);
          text("A4", 3*(width/4), 525);
          text("G4", 3*(width/4), 575);
          text("F4", 3*(width/4), 625);
        } else if (chords) {
          text("E3 Diminished", width/4, 325);
          text("D3 Minor", width/4, 375);
          text("C3 Major", width/4, 425);
          text("A#2 Major", width/4, 475);
          text("A2 Minor", width/4, 525);
          text("G2 Minor", width/4, 575);
          text("F2 Major", width/4, 625);
          
          text("E4 Diminished", 3*(width/4), 325);
          text("D4 Minor", 3*(width/4), 375);
          text("C4 Major", 3*(width/4), 425);
          text("A#3 Major", 3*(width/4), 475);
          text("A3 Minor", 3*(width/4), 525);
          text("G3 Minor", 3*(width/4), 575);
          text("F3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("F5", 5, 107);
        text("E5", 5, 117);
        text("D5", 5, 127);
        text("C5", 5, 137);
        text("A#4", 5, 147);
        text("A4", 5, 157);
        text("G4", 5, 167);
        text("F4", 5, 177);
        text("E4", 5, 187);
        text("D4", 5, 197);
        text("C4", 5, 207);
        text("A#3", 5, 217);
        text("A3", 5, 227);
        text("G3", 5, 237);
        text("F3", 5, 247);
        
        text("F4 Maj", 5, 307);
        text("E4 Dim", 5, 317);
        text("D4 Min", 5, 327);
        text("C4 Maj", 5, 337);
        text("A#3 Maj", 5, 347);
        text("A3 Min", 5, 357);
        text("G3 Min", 5, 367);
        text("F3 Maj", 5, 377);
        text("E3 Dim", 5, 387);
        text("D3 Min", 5, 397);
        text("C3 Maj", 5, 407);
        text("A#2 Maj", 5, 417);
        text("A2 Min", 5, 427);
        text("G2 Min", 5, 437);
        text("F2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 11) {
      // F Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: F Minor", width/2, 125);
        text("Characteristics of F Minor: Harrowing, Melancholic, and Obscure", width/2, 175);
        text("Example of music written in F Minor: Clocks by Coldplay", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("D#4", width/4, 325);
          text("C#4", width/4, 375);
          text("C4", width/4, 425);
          text("A#3", width/4, 475);
          text("G#3", width/4, 525);
          text("G3", width/4, 575);
          text("F3", width/4, 625);
          
          text("D#5", 3*(width/4), 325);
          text("C#5", 3*(width/4), 375);
          text("C5", 3*(width/4), 425);
          text("A#4", 3*(width/4), 475);
          text("G#4", 3*(width/4), 525);
          text("G4", 3*(width/4), 575);
          text("F4", 3*(width/4), 625);
        } else if (chords) {
          text("D#3 Major", width/4, 325);
          text("C#3 Major", width/4, 375);
          text("C3 Minor", width/4, 425);
          text("A#2 Minor", width/4, 475);
          text("G#2 Major", width/4, 525);
          text("G2 Diminished", width/4, 575);
          text("F2 Minor", width/4, 625);
          
          text("D#4 Major", 3*(width/4), 325);
          text("C#4 Major", 3*(width/4), 375);
          text("C4 Minor", 3*(width/4), 425);
          text("A#3 Minor", 3*(width/4), 475);
          text("G#3 Major", 3*(width/4), 525);
          text("G3 Diminished", 3*(width/4), 575);
          text("F3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("F5", 5, 107);
        text("D#5", 5, 117);
        text("C#5", 5, 127);
        text("C5", 5, 137);
        text("A#4", 5, 147);
        text("G#4", 5, 157);
        text("G4", 5, 167);
        text("F4", 5, 177);
        text("D#4", 5, 187);
        text("C#4", 5, 197);
        text("C4", 5, 207);
        text("A#3", 5, 217);
        text("G#3", 5, 227);
        text("G3", 5, 237);
        text("F3", 5, 247);
        
        text("F4 Min", 5, 307);
        text("D#4 Maj", 5, 317);
        text("C#4 Maj", 5, 327);
        text("C4 Min", 5, 337);
        text("A#3 Min", 5, 347);
        text("G#3 Maj", 5, 357);
        text("G3 Dim", 5, 367);
        text("F3 Min", 5, 377);
        text("D#3 Maj", 5, 387);
        text("C#3 Maj", 5, 397);
        text("C3 Min", 5, 407);
        text("A#2 Min", 5, 417);
        text("G#2 Maj", 5, 427);
        text("G2 Dim", 5, 437);
        text("F2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 12) {
      // F Sharp Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: F# Major", width/2, 125);
        text("Characteristics of F# Major: All-Conquering, Victorious, and Relieved", width/2, 175);
        //text("Examples of music written in F# Major: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("F4", width/4, 325);
          text("D#4", width/4, 375);
          text("C#4", width/4, 425);
          text("B3", width/4, 475);
          text("A#3", width/4, 525);
          text("G#3", width/4, 575);
          text("F#3", width/4, 625);
          
          text("F5", 3*(width/4), 325);
          text("D#5", 3*(width/4), 375);
          text("C#5", 3*(width/4), 425);
          text("B4", 3*(width/4), 475);
          text("A#4", 3*(width/4), 525);
          text("G#4", 3*(width/4), 575);
          text("F#4", 3*(width/4), 625);
        } else if (chords) {
          text("F3 Diminished", width/4, 325);
          text("D#3 Minor", width/4, 375);
          text("C#3 Major", width/4, 425);
          text("B2 Major", width/4, 475);
          text("A#2 Minor", width/4, 525);
          text("G#2 Minor", width/4, 575);
          text("F#2 Major", width/4, 625);
          
          text("F4 Diminished", 3*(width/4), 325);
          text("D#4 Minor", 3*(width/4), 375);
          text("C#4 Major", 3*(width/4), 425);
          text("B3 Major", 3*(width/4), 475);
          text("A#3 Minor", 3*(width/4), 525);
          text("G#3 Minor", 3*(width/4), 575);
          text("F#3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("F#5", 5, 107);
        text("F5", 5, 117);
        text("D#5", 5, 127);
        text("C#5", 5, 137);
        text("B4", 5, 147);
        text("A#4", 5, 157);
        text("G#4", 5, 167);
        text("F#4", 5, 177);
        text("F4", 5, 187);
        text("D#4", 5, 197);
        text("C#4", 5, 207);
        text("B3", 5, 217);
        text("A#3", 5, 227);
        text("G#3", 5, 237);
        text("F#3", 5, 247);
        
        text("F#4 Maj", 5, 307);
        text("F4 Dim", 5, 317);
        text("D#4 Min", 5, 327);
        text("C#4 Maj", 5, 337);
        text("B3 Maj", 5, 347);
        text("A#3 Min", 5, 357);
        text("G#3 Min", 5, 367);
        text("F#3 Maj", 5, 377);
        text("F3 Dim", 5, 387);
        text("D#3 Min", 5, 397);
        text("C#3 Maj", 5, 407);
        text("B2 Maj", 5, 417);
        text("A#2 Min", 5, 427);
        text("G#2 Min", 5, 437);
        text("F#2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 13) {
      // F Sharp Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: F# Minor", width/2, 125);
        text("Characteristics of F# Minor: Gloomy, Resentful, and Discontented", width/2, 175);
        //text("Examples of music written in F# Minor: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("E4", width/4, 325);
          text("D4", width/4, 375);
          text("C#4", width/4, 425);
          text("B3", width/4, 475);
          text("A3", width/4, 525);
          text("G#3", width/4, 575);
          text("F#3", width/4, 625);
          
          text("E5", 3*(width/4), 325);
          text("D5", 3*(width/4), 375);
          text("C#5", 3*(width/4), 425);
          text("B4", 3*(width/4), 475);
          text("A4", 3*(width/4), 525);
          text("G#4", 3*(width/4), 575);
          text("F#4", 3*(width/4), 625);
        } else if (chords) {
          text("E3 Major", width/4, 325);
          text("D3 Major", width/4, 375);
          text("C#3 Minor", width/4, 425);
          text("B2 Minor", width/4, 475);
          text("A2 Major", width/4, 525);
          text("G#2 Diminished", width/4, 575);
          text("F#2 Minor", width/4, 625);
          
          text("E4 Major", 3*(width/4), 325);
          text("D4 Major", 3*(width/4), 375);
          text("C#4 Minor", 3*(width/4), 425);
          text("B3 Minor", 3*(width/4), 475);
          text("A3 Major", 3*(width/4), 525);
          text("G#3 Diminished", 3*(width/4), 575);
          text("F#3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("F#5", 5, 107);
        text("E5", 5, 117);
        text("D5", 5, 127);
        text("C#5", 5, 137);
        text("B4", 5, 147);
        text("A4", 5, 157);
        text("G#4", 5, 167);
        text("F#4", 5, 177);
        text("E4", 5, 187);
        text("D4", 5, 197);
        text("C#4", 5, 207);
        text("B3", 5, 217);
        text("A3", 5, 227);
        text("G#3", 5, 237);
        text("F#3", 5, 247);
        
        text("F#4 Min", 5, 307);
        text("E4 Maj", 5, 317);
        text("D4 Maj", 5, 327);
        text("C#4 Min", 5, 337);
        text("B3 Min", 5, 347);
        text("A3 Maj", 5, 357);
        text("G#3 Dim", 5, 367);
        text("F#3 Min", 5, 377);
        text("E3 Maj", 5, 387);
        text("D3 Maj", 5, 397);
        text("C#3 Min", 5, 407);
        text("B2 Min", 5, 417);
        text("A2 Maj", 5, 427);
        text("G#2 Dim", 5, 437);
        text("F#2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 14) {
      // G Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: G Major", width/2, 125);
        text("Characteristics of G Major: Peaceful, Magnificent, and Full of Fantasy", width/2, 175);
        text("Example of music written in G Major: Summer by Calvin Harris", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("F#4", width/4, 325);
          text("E4", width/4, 375);
          text("D4", width/4, 425);
          text("C4", width/4, 475);
          text("B3", width/4, 525);
          text("A3", width/4, 575);
          text("G3", width/4, 625);
          
          text("F#5", 3*(width/4), 325);
          text("E5", 3*(width/4), 375);
          text("D5", 3*(width/4), 425);
          text("C5", 3*(width/4), 475);
          text("B4", 3*(width/4), 525);
          text("A4", 3*(width/4), 575);
          text("G4", 3*(width/4), 625);
        } else if (chords) {
          text("F#3 Diminished", width/4, 325);
          text("E3 Minor", width/4, 375);
          text("D3 Major", width/4, 425);
          text("C3 Major", width/4, 475);
          text("B2 Minor", width/4, 525);
          text("A2 Minor", width/4, 575);
          text("G2 Major", width/4, 625);
          
          text("F#4 Diminished", 3*(width/4), 325);
          text("E4 Minor", 3*(width/4), 375);
          text("D4 Major", 3*(width/4), 425);
          text("C4 Major", 3*(width/4), 475);
          text("B3 Minor", 3*(width/4), 525);
          text("A3 Minor", 3*(width/4), 575);
          text("G3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("G5", 5, 107);
        text("F#5", 5, 117);
        text("E5", 5, 127);
        text("D5", 5, 137);
        text("C5", 5, 147);
        text("B4", 5, 157);
        text("A4", 5, 167);
        text("G4", 5, 177);
        text("F#4", 5, 187);
        text("E4", 5, 197);
        text("D4", 5, 207);
        text("C4", 5, 217);
        text("B3", 5, 227);
        text("A3", 5, 237);
        text("G3", 5, 247);
        
        text("G4 Maj", 5, 307);
        text("F#4 Dim", 5, 317);
        text("E4 Min", 5, 327);
        text("D4 Maj", 5, 337);
        text("C4 Maj", 5, 347);
        text("B3 Min", 5, 357);
        text("A3 Min", 5, 367);
        text("G3 Maj", 5, 377);
        text("F#3 Dim", 5, 387);
        text("E3 Min", 5, 397);
        text("D3 Maj", 5, 407);
        text("C3 Maj", 5, 417);
        text("B2 Min", 5, 427);
        text("A2 Min", 5, 437);
        text("G2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 15) {
      // G Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: G Minor", width/2, 125);
        text("Characteristics of G Minor: Uneasy, Worrisome, and Troubling", width/2, 175);
        //text("Examples of music written in G Minor: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("F4", width/4, 325);
          text("D#4", width/4, 375);
          text("D4", width/4, 425);
          text("C4", width/4, 475);
          text("A#3", width/4, 525);
          text("A3", width/4, 575);
          text("G3", width/4, 625);
          
          text("F5", 3*(width/4), 325);
          text("D#5", 3*(width/4), 375);
          text("D5", 3*(width/4), 425);
          text("C5", 3*(width/4), 475);
          text("A#4", 3*(width/4), 525);
          text("A4", 3*(width/4), 575);
          text("G4", 3*(width/4), 625);
        } else if (chords) {
          text("F3 Major", width/4, 325);
          text("D#3 Major", width/4, 375);
          text("D3 Minor", width/4, 425);
          text("C3 Minor", width/4, 475);
          text("A#2 Major", width/4, 525);
          text("A2 Diminished", width/4, 575);
          text("G2 Minor", width/4, 625);
          
          text("F4 Major", 3*(width/4), 325);
          text("D#4 Major", 3*(width/4), 375);
          text("D4 Minor", 3*(width/4), 425);
          text("C4 Minor", 3*(width/4), 475);
          text("A#3 Major", 3*(width/4), 525);
          text("A3 Diminished", 3*(width/4), 575);
          text("G3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("G5", 5, 107);
        text("F5", 5, 117);
        text("D#5", 5, 127);
        text("D5", 5, 137);
        text("C5", 5, 147);
        text("A#4", 5, 157);
        text("A4", 5, 167);
        text("G4", 5, 177);
        text("F4", 5, 187);
        text("D#4", 5, 197);
        text("D4", 5, 207);
        text("C4", 5, 217);
        text("A#3", 5, 227);
        text("A3", 5, 237);
        text("G3", 5, 247);
        
        text("G4 Min", 5, 307);
        text("F4 Maj", 5, 317);
        text("D#4 Maj", 5, 327);
        text("D4 Min", 5, 337);
        text("C4 Min", 5, 347);
        text("A#3 Maj", 5, 357);
        text("A3 Dim", 5, 367);
        text("G3 Min", 5, 377);
        text("F3 Maj", 5, 387);
        text("D#3 Maj", 5, 397);
        text("D3 Min", 5, 407);
        text("C3 Min", 5, 417);
        text("A#2 Maj", 5, 427);
        text("A2 Dim", 5, 437);
        text("G2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 16) {
      // G Sharp Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: G# Major", width/2, 125);
        text("Characteristics of G# Major: Judgemental, Lingering, and Eternal", width/2, 175);
        //text("Examples of music written in G# Major: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("G4", width/4, 325);
          text("F4", width/4, 375);
          text("D#4", width/4, 425);
          text("C#4", width/4, 475);
          text("C4", width/4, 525);
          text("A#3", width/4, 575);
          text("G#3", width/4, 625);
          
          text("G5", 3*(width/4), 325);
          text("F5", 3*(width/4), 375);
          text("D#5", 3*(width/4), 425);
          text("C#5", 3*(width/4), 475);
          text("C5", 3*(width/4), 525);
          text("A#4", 3*(width/4), 575);
          text("G#4", 3*(width/4), 625);
        } else if (chords) {
          text("G3 Diminished", width/4, 325);
          text("F3 Minor", width/4, 375);
          text("D#3 Major", width/4, 425);
          text("C#3 Major", width/4, 475);
          text("C3 Minor", width/4, 525);
          text("A#2 Minor", width/4, 575);
          text("G#2 Major", width/4, 625);
          
          text("G4 Diminished", 3*(width/4), 325);
          text("F4 Minor", 3*(width/4), 375);
          text("D#4 Major", 3*(width/4), 425);
          text("C#4 Major", 3*(width/4), 475);
          text("C4 Minor", 3*(width/4), 525);
          text("A#3 Minor", 3*(width/4), 575);
          text("G#3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("G#5", 5, 107);
        text("G5", 5, 117);
        text("F5", 5, 127);
        text("D#5", 5, 137);
        text("C#5", 5, 147);
        text("C5", 5, 157);
        text("A#4", 5, 167);
        text("G#4", 5, 177);
        text("G4", 5, 187);
        text("F4", 5, 197);
        text("D#4", 5, 207);
        text("C#4", 5, 217);
        text("C4", 5, 227);
        text("A#3", 5, 237);
        text("G#3", 5, 247);
        
        text("G#4 Maj", 5, 307);
        text("G4 Dim", 5, 317);
        text("F4 Min", 5, 327);
        text("D#4 Maj", 5, 337);
        text("C#4 Maj", 5, 347);
        text("C4 Min", 5, 357);
        text("A#3 Min", 5, 367);
        text("G#3 Maj", 5, 377);
        text("G3 Dim", 5, 387);
        text("F3 Min", 5, 397);
        text("D#3 Maj", 5, 407);
        text("C#3 Maj", 5, 417);
        text("C3 Min", 5, 427);
        text("A#2 Min", 5, 437);
        text("G#2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 17) {
      // G Sharp Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: G# Minor", width/2, 125);
        text("Characteristics of G# Minor: Grumbling, Moaning, and Laborious", width/2, 175);
        //text("Example of music written in G# Minor: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("F#4", width/4, 325);
          text("E4", width/4, 375);
          text("D#4", width/4, 425);
          text("C#4", width/4, 475);
          text("B3", width/4, 525);
          text("A#3", width/4, 575);
          text("G#3", width/4, 625);
          
          text("F#5", 3*(width/4), 325);
          text("E5", 3*(width/4), 375);
          text("D#5", 3*(width/4), 425);
          text("C#5", 3*(width/4), 475);
          text("B4", 3*(width/4), 525);
          text("A#4", 3*(width/4), 575);
          text("G#4", 3*(width/4), 625);
        } else if (chords) {
          text("F#3 Major", width/4, 325);
          text("E3 Major", width/4, 375);
          text("D#3 Minor", width/4, 425);
          text("C#3 Minor", width/4, 475);
          text("B2 Major", width/4, 525);
          text("A#2 Diminished", width/4, 575);
          text("G#2 Minor", width/4, 625);
          
          text("F#4 Major", 3*(width/4), 325);
          text("E4 Major", 3*(width/4), 375);
          text("D#4 Minor", 3*(width/4), 425);
          text("C#4 Minor", 3*(width/4), 475);
          text("B3 Major", 3*(width/4), 525);
          text("A#3 Diminished", 3*(width/4), 575);
          text("G#3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("G#5", 5, 107);
        text("F#5", 5, 117);
        text("E5", 5, 127);
        text("D#5", 5, 137);
        text("C#5", 5, 147);
        text("B4", 5, 157);
        text("A#4", 5, 167);
        text("G#4", 5, 177);
        text("F#4", 5, 187);
        text("E4", 5, 197);
        text("D#4", 5, 207);
        text("C#4", 5, 217);
        text("B3", 5, 227);
        text("A#3", 5, 237);
        text("G#3", 5, 247);
        
        text("G#4 Min", 5, 307);
        text("F#4 Maj", 5, 317);
        text("E4 Maj", 5, 327);
        text("D#4 Min", 5, 337);
        text("C#4 Min", 5, 347);
        text("B3 Maj", 5, 357);
        text("A#3 Dim", 5, 367);
        text("G#3 Min", 5, 377);
        text("F#3 Maj", 5, 387);
        text("E3 Maj", 5, 397);
        text("D#3 Min", 5, 407);
        text("C#3 Min", 5, 417);
        text("B2 Maj", 5, 427);
        text("A#2 Dim", 5, 437);
        text("G#2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 18) {
      // A Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: A Major", width/2, 125);
        text("Characteristics of A Major: Joyful, Youthful, and Loving", width/2, 175);
        //text("Example of music written in A Major: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("G#4", width/4, 325);
          text("F#4", width/4, 375);
          text("E4", width/4, 425);
          text("D4", width/4, 475);
          text("C#4", width/4, 525);
          text("B3", width/4, 575);
          text("A3", width/4, 625);
          
          text("G#5", 3*(width/4), 325);
          text("F#5", 3*(width/4), 375);
          text("E5", 3*(width/4), 425);
          text("D5", 3*(width/4), 475);
          text("C#5", 3*(width/4), 525);
          text("B4", 3*(width/4), 575);
          text("A4", 3*(width/4), 625);
        } else if (chords) {
          text("G#3 Diminished", width/4, 325);
          text("F#3 Minor", width/4, 375);
          text("E3 Major", width/4, 425);
          text("D3 Major", width/4, 475);
          text("C#3 Minor", width/4, 525);
          text("B2 Minor", width/4, 575);
          text("A2 Major", width/4, 625);
          
          text("G#4 Diminished", 3*(width/4), 325);
          text("F#4 Minor", 3*(width/4), 375);
          text("E4 Major", 3*(width/4), 425);
          text("D4 Major", 3*(width/4), 475);
          text("C#4 Minor", 3*(width/4), 525);
          text("B3 Minor", 3*(width/4), 575);
          text("A3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("A5", 5, 107);
        text("G#5", 5, 117);
        text("F#5", 5, 127);
        text("E5", 5, 137);
        text("D5", 5, 147);
        text("C#5", 5, 157);
        text("B4", 5, 167);
        text("A4", 5, 177);
        text("G#4", 5, 187);
        text("F#4", 5, 197);
        text("E4", 5, 207);
        text("D4", 5, 217);
        text("C#4", 5, 227);
        text("B3", 5, 237);
        text("A3", 5, 247);
        
        text("A4 Maj", 5, 307);
        text("G#4 Dim", 5, 317);
        text("F#4 Min", 5, 327);
        text("E4 Maj", 5, 337);
        text("D4 Maj", 5, 347);
        text("C#4 Min", 5, 357);
        text("B3 Min", 5, 367);
        text("A3 Maj", 5, 377);
        text("G#3 Dim", 5, 387);
        text("F#3 Min", 5, 397);
        text("E3 Maj", 5, 407);
        text("D3 Maj", 5, 417);
        text("C#3 Min", 5, 427);
        text("B2 Min", 5, 437);
        text("A2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 19) {
      // A Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: A Minor", width/2, 125);
        text("Characteristics of A Minor: Graceful, Tender, and Pious", width/2, 175);
        text("Example of music written in A Minor: Stairway to Heaven by Led Zeppelin", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("G4", width/4, 325);
          text("F4", width/4, 375);
          text("E4", width/4, 425);
          text("D4", width/4, 475);
          text("C4", width/4, 525);
          text("B3", width/4, 575);
          text("A3", width/4, 625);
          
          text("G5", 3*(width/4), 325);
          text("F5", 3*(width/4), 375);
          text("E5", 3*(width/4), 425);
          text("D5", 3*(width/4), 475);
          text("C5", 3*(width/4), 525);
          text("B4", 3*(width/4), 575);
          text("A4", 3*(width/4), 625);
        } else if (chords) {
          text("G3 Major", width/4, 325);
          text("F3 Major", width/4, 375);
          text("E3 Minor", width/4, 425);
          text("D3 Minor", width/4, 475);
          text("C3 Major", width/4, 525);
          text("B2 Diminished", width/4, 575);
          text("A2 Minor", width/4, 625);
          
          text("G4 Major", 3*(width/4), 325);
          text("F4 Major", 3*(width/4), 375);
          text("E4 Minor", 3*(width/4), 425);
          text("D4 Minor", 3*(width/4), 475);
          text("C4 Major", 3*(width/4), 525);
          text("B3 Diminished", 3*(width/4), 575);
          text("A3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("A5", 5, 107);
        text("G5", 5, 117);
        text("F5", 5, 127);
        text("E5", 5, 137);
        text("D5", 5, 147);
        text("C5", 5, 157);
        text("B4", 5, 167);
        text("A4", 5, 177);
        text("G4", 5, 187);
        text("F4", 5, 197);
        text("E4", 5, 207);
        text("D4", 5, 217);
        text("C4", 5, 227);
        text("B3", 5, 237);
        text("A3", 5, 247);
        
        text("A4 Min", 5, 307);
        text("G4 Maj", 5, 317);
        text("F4 Maj", 5, 327);
        text("E4 Min", 5, 337);
        text("D4 Min", 5, 347);
        text("C4 Maj", 5, 357);
        text("B3 Dim", 5, 367);
        text("A3 Min", 5, 377);
        text("G3 Maj", 5, 387);
        text("F3 Maj", 5, 397);
        text("E3 Min", 5, 407);
        text("D3 Min", 5, 417);
        text("C3 Maj", 5, 427);
        text("B2 Dim", 5, 437);
        text("A2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 20) {
      // A Sharp Major / Bb Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: A# Major / Bb Major", width/2, 125);
        text("Characteristics of A# Major / Bb Major: Aspirational, Cheerful, and Hopeful", width/2, 175);
        text("Example of music written in A# Major / Bb Major: Mr Blue Sky by The Electric Light Orchestra", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("A4", width/4, 325);
          text("G4", width/4, 375);
          text("F4", width/4, 425);
          text("D#4", width/4, 475);
          text("D4", width/4, 525);
          text("C4", width/4, 575);
          text("A#3", width/4, 625);
          
          text("A5", 3*(width/4), 325);
          text("G5", 3*(width/4), 375);
          text("F5", 3*(width/4), 425);
          text("D#5", 3*(width/4), 475);
          text("D5", 3*(width/4), 525);
          text("C5", 3*(width/4), 575);
          text("A#4", 3*(width/4), 625);
        } else if (chords) {
          text("A3 Diminished", width/4, 325);
          text("G3 Minor", width/4, 375);
          text("F3 Major", width/4, 425);
          text("D#3 Major", width/4, 475);
          text("D3 Minor", width/4, 525);
          text("C3 Minor", width/4, 575);
          text("A#2 Major", width/4, 625);
          
          text("A4 Diminished", 3*(width/4), 325);
          text("G4 Minor", 3*(width/4), 375);
          text("F4 Major", 3*(width/4), 425);
          text("D#4 Major", 3*(width/4), 475);
          text("D4 Minor", 3*(width/4), 525);
          text("C4 Minor", 3*(width/4), 575);
          text("A#3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("A#5", 5, 107);
        text("A5", 5, 117);
        text("G5", 5, 127);
        text("F5", 5, 137);
        text("D#5", 5, 147);
        text("D5", 5, 157);
        text("C5", 5, 167);
        text("A#4", 5, 177);
        text("A4", 5, 187);
        text("G4", 5, 197);
        text("F4", 5, 207);
        text("D#4", 5, 217);
        text("D4", 5, 227);
        text("C4", 5, 237);
        text("A#3", 5, 247);
        
        text("A#4 Maj", 5, 307);
        text("A4 Dim", 5, 317);
        text("G4 Min", 5, 327);
        text("F4 Maj", 5, 337);
        text("D#4 Maj", 5, 347);
        text("D4 Min", 5, 357);
        text("C4 Min", 5, 367);
        text("A#3 Maj", 5, 377);
        text("A3 Dim", 5, 387);
        text("G3 Min", 5, 397);
        text("F3 Maj", 5, 407);
        text("D#3 Maj", 5, 417);
        text("D3 Min", 5, 427);
        text("C3 Min", 5, 437);
        text("A#2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 21) {
      // A Sharp Minor / Bb Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: A# Minor / Bb Minor", width/2, 125);
        text("Characteristics of A# Minor / Bb Minor: Dark, Mocking, and Unfriendly", width/2, 175);
        //text("Example of music written in A# Minor / Bb Minor: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("G#4", width/4, 325);
          text("F#4", width/4, 375);
          text("F4", width/4, 425);
          text("D#4", width/4, 475);
          text("C#4", width/4, 525);
          text("C4", width/4, 575);
          text("A#3", width/4, 625);
          
          text("G#5", 3*(width/4), 325);
          text("F#5", 3*(width/4), 375);
          text("F5", 3*(width/4), 425);
          text("D#5", 3*(width/4), 475);
          text("C#5", 3*(width/4), 525);
          text("C5", 3*(width/4), 575);
          text("A#4", 3*(width/4), 625);
        } else if (chords) {
          text("G#3 Major", width/4, 325);
          text("F#3 Major", width/4, 375);
          text("F3 Minor", width/4, 425);
          text("D#3 Minor", width/4, 475);
          text("C#3 Major", width/4, 525);
          text("C3 Diminished", width/4, 575);
          text("A#2 Minor", width/4, 625);
          
          text("G#4 Major", 3*(width/4), 325);
          text("F#4 Major", 3*(width/4), 375);
          text("F4 Minor", 3*(width/4), 425);
          text("D#4 Minor", 3*(width/4), 475);
          text("C#4 Major", 3*(width/4), 525);
          text("C4 Diminished", 3*(width/4), 575);
          text("A#3 Minor", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("A#5", 5, 107);
        text("G#5", 5, 117);
        text("F#5", 5, 127);
        text("F5", 5, 137);
        text("D#5", 5, 147);
        text("C#5", 5, 157);
        text("C5", 5, 167);
        text("A#4", 5, 177);
        text("G#4", 5, 187);
        text("F#4", 5, 197);
        text("F4", 5, 207);
        text("D#4", 5, 217);
        text("C#4", 5, 227);
        text("C4", 5, 237);
        text("A#3", 5, 247);
        
        text("A#4 Min", 5, 307);
        text("G#4 Maj", 5, 317);
        text("F#4 Maj", 5, 327);
        text("F4 Min", 5, 337);
        text("D#4 Min", 5, 347);
        text("C#4 Maj", 5, 357);
        text("C4 Dim", 5, 367);
        text("A#3 Min", 5, 377);
        text("G#3 Maj", 5, 387);
        text("F#3 Maj", 5, 397);
        text("F3 Min", 5, 407);
        text("D#3 Min", 5, 417);
        text("C#3 Maj", 5, 427);
        text("C3 Dim", 5, 437);
        text("A#2 Min", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 22) {
      // B Major
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: B Major", width/2, 125);
        text("Characteristics of B Major: Strong, Wild, and Furious", width/2, 175);
        //text("Examples of music written in B Major: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("A#4", width/4, 325);
          text("G#4", width/4, 375);
          text("F#4", width/4, 425);
          text("E4", width/4, 475);
          text("D#4", width/4, 525);
          text("C#4", width/4, 575);
          text("B3", width/4, 625);
          
          text("A#5", 3*(width/4), 325);
          text("G#5", 3*(width/4), 375);
          text("F#5", 3*(width/4), 425);
          text("E5", 3*(width/4), 475);
          text("D#5", 3*(width/4), 525);
          text("C#5", 3*(width/4), 575);
          text("B4", 3*(width/4), 625);
        } else if (chords) {
          text("A#3 Diminished", width/4, 325);
          text("G#3 Minor", width/4, 375);
          text("F#3 Major", width/4, 425);
          text("E3 Major", width/4, 475);
          text("D#3 Minor", width/4, 525);
          text("C#3 Minor", width/4, 575);
          text("B2 Major", width/4, 625);
          
          text("A#4 Diminished", 3*(width/4), 325);
          text("G#4 Minor", 3*(width/4), 375);
          text("F#4 Major", 3*(width/4), 425);
          text("E4 Major", 3*(width/4), 475);
          text("D#4 Minor", 3*(width/4), 525);
          text("C#4 Minor", 3*(width/4), 575);
          text("B3 Major", 3*(width/4), 625);
        }
      } else if (editorMode) {
        
        textSize(9);
        
        text("B5", 5, 107);
        text("A#5", 5, 117);
        text("G#5", 5, 127);
        text("F#5", 5, 137);
        text("E5", 5, 147);
        text("D#5", 5, 157);
        text("C#5", 5, 167);
        text("B4", 5, 177);
        text("A#4", 5, 187);
        text("G#4", 5, 197);
        text("F#4", 5, 207);
        text("E4", 5, 217);
        text("D#4", 5, 227);
        text("C#4", 5, 237);
        text("B3", 5, 247);
        
        text("B4 Maj", 5, 307);
        text("A#4 Dim", 5, 317);
        text("G#4 Min", 5, 327);
        text("F#4 Maj", 5, 337);
        text("E4 Maj", 5, 347);
        text("D#4 Min", 5, 357);
        text("C#4 Min", 5, 367);
        text("B3 Maj", 5, 377);
        text("A#3 Dim", 5, 387);
        text("G#3 Min", 5, 397);
        text("F#3 Maj", 5, 407);
        text("E3 Maj", 5, 417);
        text("D#3 Min", 5, 427);
        text("C#3 Min", 5, 437);
        text("B2 Maj", 5, 447);
        
      }
      
    } else if (selectedMusicalKey == 23) {
      // B Minor
      if (liveMode) {
        noFill();
        stroke(255);
        
        if (!pitchBend) {
          rect(0, 300, width/2, 50);
          rect(0, 350, width/2, 50);
          rect(0, 400, width/2, 50);
          rect(0, 450, width/2, 50);
          rect(0, 500, width/2, 50);
          rect(0, 550, width/2, 50);
          rect(0, 600, width/2, 50);
          
          rect(width/2, 300, width/2, 50);
          rect(width/2, 350, width/2, 50);
          rect(width/2, 400, width/2, 50);
          rect(width/2, 450, width/2, 50);
          rect(width/2, 500, width/2, 50);
          rect(width/2, 550, width/2, 50);
          rect(width/2, 600, width/2, 50);
        } else {
          strokeWeight(4);
          rect(0, 300, width, 350);
          line(0, 475, width, 475);
          strokeWeight(1);
          stroke(100);
          line(0, 335, width, 335);
          line(0, 370, width, 370);
          line(0, 405, width, 405);
          line(0, 440, width, 440);
          line(0, 510, width, 510);
          line(0, 545, width, 545);
          line(0, 580, width, 580);
          line(0, 615, width, 615);
          stroke(255);
          textAlign(CENTER);
          text("+ 80% - 100%", width/2, 318);
          text("+ 60% - 80%", width/2, 353);
          text("+ 40% - 60%", width/2, 388);
          text("+ 20% - 40%", width/2, 423);
          text("+ 0% - 20%", width/2, 458);
          text("- 80% - 100%", width/2, 633);
          text("- 60% - 80%", width/2, 598);
          text("- 40% - 60%", width/2, 563);
          text("- 20% - 40%", width/2, 528);
          text("- 0% - 20%", width/2, 493);
          textAlign(LEFT);
        }
        
        textAlign(CENTER);
        textSize(20);
        text("Selected Key: B Minor", width/2, 125);
        text("Characteristics of B Minor: Patient and Calm", width/2, 175);
        //text("Examples of music written in B Minor: ", width/2, 225);
        textSize(12);
        textAlign(LEFT);
        
        if (notes) {
          text("A4", width/4, 325);
          text("G4", width/4, 375);
          text("F#4", width/4, 425);
          text("E4", width/4, 475);
          text("D4", width/4, 525);
          text("C#4", width/4, 575);
          text("B3", width/4, 625);
          
          text("A5", 3*(width/4), 325);
          text("G5", 3*(width/4), 375);
          text("F#5", 3*(width/4), 425);
          text("E5", 3*(width/4), 475);
          text("D5", 3*(width/4), 525);
          text("C#5", 3*(width/4), 575);
          text("B4", 3*(width/4), 625);
        } else if (chords) {
          text("A3 Major", width/4, 325);
          text("G3 Major", width/4, 375);
          text("F#3 Minor", width/4, 425);
          text("E3 Minor", width/4, 475);
          text("D3 Major", width/4, 525);
          text("C#3 Diminished", width/4, 575);
          text("B2 Minor", width/4, 625);
          
          text("A4 Major", 3*(width/4), 325);
          text("G4 Major", 3*(width/4), 375);
          text("F#4 Minor", 3*(width/4), 425);
          text("E4 Minor", 3*(width/4), 475);
          text("D4 Major", 3*(width/4), 525);
          text("C#4 Diminished", 3*(width/4), 575);
          text("B3 Minor", 3*(width/4), 625);
        }  
      } else if (editorMode) {
        
        textSize(9);
        
        text("B5", 5, 107);
        text("A5", 5, 117);
        text("G5", 5, 127);
        text("F#5", 5, 137);
        text("E5", 5, 147);
        text("D5", 5, 157);
        text("C#5", 5, 167);
        text("B4", 5, 177);
        text("A4", 5, 187);
        text("G4", 5, 197);
        text("F#4", 5, 207);
        text("E4", 5, 217);
        text("D4", 5, 227);
        text("C#4", 5, 237);
        text("B3", 5, 247);
        
        text("B4 Min", 5, 307);
        text("A4 Maj", 5, 317);
        text("G4 Maj", 5, 327);
        text("F#4 Min", 5, 337);
        text("E4 Min", 5, 347);
        text("D4 Maj", 5, 357);
        text("C#4 Dim", 5, 367);
        text("B3 Min", 5, 377);
        text("A3 Maj", 5, 387);
        text("G3 Maj", 5, 397);
        text("F#3 Min", 5, 407);
        text("E3 Min", 5, 417);
        text("D3 Maj", 5, 427);
        text("C#3 Dim", 5, 437);
        text("B2 Min", 5, 447);
        
      }
      
    }
  }
  
  int selection(int pitch) {
    if (pitch == 71) {
      return 1;
    } else {
      return 1000;
    }
  }
  
}
