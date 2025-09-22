# Synthesis

Audio synthesis components for generating waveforms and sounds.

## Oscillator

A versatile oscillator that generates common waveforms for synthesis and testing.

```zig
pub const Oscillator = struct {
    phase: SampleType,      // Current phase (0.0 - 1.0)
    frequency: SampleType,  // Frequency in Hz
    sample_rate: SampleType,// Sample rate in Hz
    amplitude: SampleType,  // Output amplitude
};
```

### Methods

#### `init(sample_rate: SampleType) Oscillator`
Create an oscillator for the given sample rate.

```zig
var osc = Oscillator.init(44100.0);
```

#### `setFrequency(self: *Oscillator, frequency: SampleType) void`
Set the oscillator frequency in Hz.

```zig
osc.setFrequency(440.0); // A4 note
```

#### `setAmplitude(self: *Oscillator, amplitude: SampleType) void`
Set the output amplitude (typically 0.0 - 1.0).

```zig
osc.setAmplitude(0.8); // 80% amplitude
```

#### `reset(self: *Oscillator) void`
Reset the oscillator phase to zero.

```zig
osc.reset(); // Start from beginning of waveform
```

### Waveform Generation

#### `sine(self: *Oscillator) SampleType`
Generate a sine wave sample.

```zig
const sample = osc.sine();
```

#### `sineFrame(self: *Oscillator) Frame`
Generate a mono sine wave frame.

```zig
const frame = osc.sineFrame();
```

#### `saw(self: *Oscillator) SampleType`
Generate a sawtooth wave sample.

```zig
const sample = osc.saw();
```

#### `square(self: *Oscillator) SampleType`
Generate a square wave sample.

```zig
const sample = osc.square();
```

#### `triangle(self: *Oscillator) SampleType`
Generate a triangle wave sample.

```zig
const sample = osc.triangle();
```

## NoiseGenerator

White noise generator for percussion, textures, and testing.

```zig
pub const NoiseGenerator = struct {
    rng: std.Random.DefaultPrng,
    amplitude: SampleType,
};
```

### Methods

#### `init(seed: u64) NoiseGenerator`
Create a noise generator with specified seed.

```zig
var noise = NoiseGenerator.init(12345);
```

#### `setAmplitude(self: *NoiseGenerator, amplitude: SampleType) void`
Set the noise amplitude.

```zig
noise.setAmplitude(0.5);
```

#### `white(self: *NoiseGenerator) SampleType`
Generate a white noise sample.

```zig
const sample = noise.white();
```

#### `whiteFrame(self: *NoiseGenerator) Frame`
Generate a mono white noise frame.

```zig
const frame = noise.whiteFrame();
```

## Example Usage

### Basic Tone Generation
```zig
const std = @import("std");
const zdsp = @import("zdsp");

pub fn toneExample() void {
    var osc = zdsp.synthesis.Oscillator.init(44100.0);
    osc.setFrequency(440.0);  // A4
    osc.setAmplitude(0.7);

    // Generate 1 second of audio
    for (0..44100) |_| {
        const sample = osc.sine();
        // ... output sample
    }
}
```

### Chord Generation
```zig
pub fn chordExample() void {
    // Create oscillators for major triad
    var osc1 = zdsp.synthesis.Oscillator.init(44100.0);
    var osc2 = zdsp.synthesis.Oscillator.init(44100.0);
    var osc3 = zdsp.synthesis.Oscillator.init(44100.0);

    // C major chord (C4, E4, G4)
    osc1.setFrequency(261.63); // C4
    osc2.setFrequency(329.63); // E4
    osc3.setFrequency(392.00); // G4

    // Equal amplitude
    const amp = 0.3; // Lower to avoid clipping
    osc1.setAmplitude(amp);
    osc2.setAmplitude(amp);
    osc3.setAmplitude(amp);

    for (0..44100) |_| {
        const sample1 = osc1.sine();
        const sample2 = osc2.sine();
        const sample3 = osc3.sine();
        const mixed = sample1 + sample2 + sample3;
        // ... output mixed sample
    }
}
```

### Noise-based Percussion
```zig
pub fn drumExample() void {
    var noise = zdsp.synthesis.NoiseGenerator.init(54321);
    var filter = zdsp.filters.BiquadFilter{};

    // Configure for snare-like sound
    filter.setLowpass(44100.0, 2000.0, 0.5);
    noise.setAmplitude(1.0);

    // Generate short burst with envelope
    for (0..4410) |i| { // 0.1 second
        const t = @as(f32, @floatFromInt(i)) / 4410.0;
        const envelope = @exp(-t * 8.0); // Exponential decay

        var sample = noise.white() * envelope;
        const frame = zdsp.Frame.mono(sample);
        const filtered = filter.process(frame);
        // ... output filtered.left
    }
}
```

## Musical Note Frequencies

| Note | Frequency (Hz) | MIDI |
|------|----------------|------|
| C4   | 261.63         | 60   |
| C#4  | 277.18         | 61   |
| D4   | 293.66         | 62   |
| D#4  | 311.13         | 63   |
| E4   | 329.63         | 64   |
| F4   | 349.23         | 65   |
| F#4  | 369.99         | 66   |
| G4   | 392.00         | 67   |
| G#4  | 415.30         | 68   |
| A4   | 440.00         | 69   |
| A#4  | 466.16         | 70   |
| B4   | 493.88         | 71   |

### MIDI to Frequency Conversion
```zig
fn midiToFreq(midi_note: f32) f32 {
    return 440.0 * std.math.pow(f32, 2.0, (midi_note - 69.0) / 12.0);
}

// Example usage
const freq_c4 = midiToFreq(60); // 261.63 Hz
```

## Waveform Characteristics

| Waveform | Harmonic Content | Use Cases |
|----------|------------------|-----------|
| Sine | Fundamental only | Pure tones, sub bass, modulation |
| Sawtooth | All harmonics | Bright leads, brass, strings |
| Square | Odd harmonics only | Hollow sounds, woodwinds |
| Triangle | Odd harmonics (rolled off) | Mellow leads, flutes |
| Noise | All frequencies | Percussion, textures, effects |