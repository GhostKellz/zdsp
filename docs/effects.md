# Effects

Real-time audio effects for creative sound processing.

## Delay

A delay effect with feedback and wet/dry mix controls. Creates echoes, slapback delay, and spacious ambience.

```zig
pub const Delay = struct {
    buffer: []Frame,
    write_index: usize,
    delay_samples: usize,
    feedback: SampleType,   // 0.0 - 0.95
    wet_mix: SampleType,    // 0.0 - 1.0
    allocator: std.mem.Allocator,
};
```

### Methods

#### `init(allocator: std.mem.Allocator, max_delay_samples: usize) !Delay`
Create a delay effect with specified maximum delay time.

```zig
// Max delay of 0.1 seconds at 44.1kHz = 4410 samples
var delay = try Delay.init(allocator, 4410);
defer delay.deinit();
```

#### `deinit(self: *Delay) void`
Free the delay buffer memory.

#### `setDelayTime(self: *Delay, delay_samples: usize) void`
Set the delay time in samples.

```zig
// 50ms delay at 44.1kHz
delay.setDelayTime(2205);
```

#### `setFeedback(self: *Delay, feedback: SampleType) void`
Set the feedback amount (0.0 - 0.95).

- `0.0`: Single echo
- `0.3`: Light repetition
- `0.7`: Multiple echoes
- `0.95`: Almost infinite feedback

```zig
delay.setFeedback(0.4); // Moderate feedback
```

#### `setWetMix(self: *Delay, wet_mix: SampleType) void`
Set the wet/dry mix (0.0 - 1.0).

- `0.0`: Only dry signal (no delay)
- `0.5`: Equal mix
- `1.0`: Only wet signal (delay only)

```zig
delay.setWetMix(0.3); // 30% delayed signal, 70% original
```

#### `process(self: *Delay, input: Frame) Frame`
Process a single audio frame.

```zig
const output = delay.process(input_frame);
```

#### `clear(self: *Delay) void`
Clear the delay buffer and reset state.

```zig
delay.clear(); // Remove all echoes
```

## Example Usage

### Basic Delay Setup
```zig
const std = @import("std");
const zdsp = @import("zdsp");

pub fn delayExample() !void {
    const allocator = std.heap.page_allocator;

    // Create delay with max 200ms at 44.1kHz
    var delay = try zdsp.effects.Delay.init(allocator, 8820);
    defer delay.deinit();

    // Configure delay
    delay.setDelayTime(4410);    // 100ms delay
    delay.setFeedback(0.4);      // Moderate feedback
    delay.setWetMix(0.25);       // 25% wet, 75% dry

    // Process audio
    for (input_buffer) |input_frame| {
        const output = delay.process(input_frame);
        // ... use output
    }
}
```

### Common Delay Settings

| Effect Type | Delay Time | Feedback | Wet Mix | Use Case |
|-------------|------------|----------|---------|----------|
| Slapback | 50-150ms | 0.0-0.2 | 0.1-0.3 | Vocals, guitar |
| Echo | 200-500ms | 0.3-0.6 | 0.2-0.4 | Ambience, space |
| Ping-pong | 150-300ms | 0.4-0.7 | 0.3-0.5 | Stereo width |
| Reverb-like | 50-100ms | 0.6-0.8 | 0.3-0.6 | Dense reflections |

### Converting Time to Samples

```zig
fn msToSamples(ms: f32, sample_rate: f32) usize {
    return @intFromFloat(ms * sample_rate / 1000.0);
}

// Examples at 44.1kHz
const delay_50ms = msToSamples(50.0, 44100.0);   // 2205 samples
const delay_100ms = msToSamples(100.0, 44100.0); // 4410 samples
```

### Creative Applications

#### Doubling Effect
```zig
delay.setDelayTime(msToSamples(15.0, 44100.0)); // Very short delay
delay.setFeedback(0.0);                          // No feedback
delay.setWetMix(0.5);                            // Equal mix
```

#### Rhythmic Delay
```zig
// Sync to 120 BPM: quarter note = 500ms
const quarter_note = msToSamples(500.0, 44100.0);
delay.setDelayTime(quarter_note);
delay.setFeedback(0.5);
delay.setWetMix(0.3);
```

#### Spacious Ambience
```zig
delay.setDelayTime(msToSamples(250.0, 44100.0)); // Long delay
delay.setFeedback(0.7);                           // High feedback
delay.setWetMix(0.4);                             // Prominent wet signal
```