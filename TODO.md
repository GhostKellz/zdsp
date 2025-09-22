**Functionality:** Audio effects, analysis, synthesis, real-time processing
- Effects (reverb, delay, distortion, EQ, compressor, limiter)
- Filters (IIR/FIR, butterworth, chebyshev, custom kernels)
- Analysis (FFT/IFFT, spectral analysis, pitch/onset detection)
- Synthesis (oscillators, noise generators, granular synthesis)
- Real-time convolution, impulse response processing

## Overview of our Audio Libraries (We want to avoid overlap if we can help it)
## Audio Ecosystem (Should Be Separate Libraries)

### beatZ: Audio Device I/O & Midi Processing
**Functionality:** Cross-platform audio device abstraction and real-time I/O
- Platform backends (WASAPI, CoreAudio, ALSA/PulseAudio)
- Device enumeration, capability detection, hotplug support
- Ultra-low latency streams (<10ms), lock-free ring buffers
- Sample rate conversion, format conversion
- Multi-device routing, channel mapping
**Functionality:** MIDI I/O, sequencing, virtual instruments
- Hardware device support, virtual MIDI ports
- Pattern recording, playback, quantization
- MIDI 2.0/2.0 support, MPE (MIDI Polyphonic Expression)
- Clock sync (internal/external), tempo changes
- Basic synthesizers, sample playback


### zcodec: Audio Format Processing
**Functionality:** Audio file formats, encoding/decoding, metadata
- Lossless formats (WAV, AIFF, FLAC, APE, WavPack)
- Lossy formats (MP3, AAC, Ogg Vorbis, Opus)
- Metadata handling (ID3, Vorbis Comments, APE tags, cover art)
- Progressive decoding, seeking, gapless playback
- High-quality encoding with psychoacoustic models

### zdsp: Digital Signal Processing
**Functionality:** Audio effects, analysis, synthesis, real-time processing
- Effects (reverb, delay, distortion, EQ, compressor, limiter)
- Filters (IIR/FIR, butterworth, chebyshev, custom kernels)
- Analysis (FFT/IFFT, spectral analysis, pitch/onset detection)
- Synthesis (oscillators, noise generators, granular synthesis)
- Real-time convolution, impulse response processing


