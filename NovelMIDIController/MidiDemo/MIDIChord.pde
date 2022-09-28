// MIDIChord Class
// Author = Joseph Cameron
// Part of The Novel MIDI Controller
// This class is responsible for holding MIDI info for chords

final class MIDIChord {
  
  int channel, velocity;
  int[] notes;
  
  public MIDIChord(int channel, int[] notes, int velocity) {
    this.channel = channel;
    this.notes = notes;
    this.velocity = velocity;
  }
  
  public int getChannel() {
    return channel;
  }
  
  public int[] getNotes() {
    return notes;
  }
  
  public int getVelocity() {
    return velocity;
  }
  
}
