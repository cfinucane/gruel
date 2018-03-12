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
  
  Wavetable nextWaveform() {
    switch(int(random(5))) {
      case 0:
        return Waves.sawh(10);
      case 1:
        return Waves.randomNOddHarms(6);
      case 2:
        return Waves.randomNHarms(6);
      case 3:
        return Waves.triangleh(4);
      case 4:
        return Waves.randomNoise();
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
  
  Person(float delaytime, float feedback, float lfoFreq, float bitRes, AudioOutput out) {
    output = out;
    
    delay = new Delay(1.0, feedback, true, true );
    delay.setDelTime(delaytime);
    
    String pitch = s.nextPitch();
    Waveform oscWave = s.nextWaveform();
    print(pitch);
    osc = new Oscil( Frequency.ofPitch(pitch), 0.2, oscWave );
    
    lfoWave = Waves.square( 0.9 );
    lfo = new Oscil(lfoFreq , 0.3, lfoWave );
    
    lfo.offset.setLastValue( 0.3 );
    lfo.patch( osc.amplitude );
    
    crush = new BitCrush(bitRes, 44100.0);
    
    osc.patch(crush).patch(delay).patch(output);
  }
  
  void updateParameters(float delaytime, float feedback, float lfoFreq, float bitRes) {
    delay.setDelTime(delaytime);
    delay.setDelAmp(feedback);
    lfo.setFrequency(lfoFreq);
    crush.setBitRes(bitRes);
  }
  
  void stop() {
    delay.unpatch(output);
  }
}