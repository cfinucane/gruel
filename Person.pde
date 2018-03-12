import ddf.minim.*;
import ddf.minim.ugens.*;

class Scale {
  String[] notes = {"Bb4", "Gb3", "Eb4", "Db4", "Ab4", "Bb4"};
  int index;
  
  Scale() {
    index = -1;
  }
  
  String nextPitch() {
    index++;

    if (index >= notes.length) {
      index = 0;
    }
    
    return notes[index];
  }
  
  float nextMultiple() {
    switch(int(random(4))) {
      case 0:
        return 200f;
      case 1:
        return 1600f;
      case 2:
        return 800f;
      case 3:
        return 400f;
    }
    return 200f;
  }
  
  Wavetable nextWaveform() {
    switch(int(random(4))) {
      case 0:
        return Waves.sawh(10);
      case 1:
        return Waves.randomNOddHarms(6);
      case 2:
        return Waves.randomNHarms(6);
      case 3:
        return Waves.triangleh(4);
    }
    
    return Waves.SINE;
  }
}

Scale s = new Scale();

class Person {
  Waveform oscWave, lfoWave;
  Delay delay;
  BitCrush crush;
  Oscil osc, lfo;
  AudioOutput output;
  Gain g;
  float pitchRange;
  
  Person(float delaytime, float lfoDepth, float lfoFreq, float freq, AudioOutput out) {
    output = out;
    
    delay = new Delay(1.0, 0.8, true, true );
    delay.setDelTime(delaytime);
    
    Waveform oscWave = s.nextWaveform();

    pitchRange = s.nextMultiple();
    osc = new Oscil( freq*pitchRange, 0.2, oscWave );
    
    lfoWave = Waves.sawh( 10 );
    lfo = new Oscil(lfoFreq , lfoDepth, lfoWave );
    
    lfo.offset.setLastValue( 0.3 );
    lfo.patch( osc.amplitude );
    
    crush = new BitCrush(bitRes, 44100.0);
    
    g = new Gain(-20.0);
    
    osc.patch(delay).patch(g).patch(output);
  }
  
  void updateParameters(float delaytime, float lfoDepth, float lfoFreq, float freq) {
    delay.setDelTime(delaytime);
    lfo.setAmplitude(lfoDepth);
    lfo.setFrequency(lfoFreq);
    osc.setFrequency(freq*pitchRange);
  }
  
  void stop() {
    delay.unpatch(output);
  }
}