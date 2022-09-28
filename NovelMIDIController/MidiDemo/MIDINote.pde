// MIDINote Class
// Author = Joseph Cameron
// Part of The Novel MIDI Controller
// This class is responsible for holding MIDI info for notes

final class MIDINote {
  
  int channel, note, velocity;
  
  public MIDINote(int channel, int note, int velocity) {
    this.channel = channel;
    this.note = note;
    this.velocity = velocity;
  }
  
  public int getChannel() {
    return channel;
  }
  
  public int getNote() {
    return note;
  }
  
  public int getVelocity() {
    return velocity;
  }
  
}
