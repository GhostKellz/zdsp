# Filters

Digital filters for frequency response and equalization.

## BiquadFilter

A versatile second-order IIR filter that can implement lowpass, highpass, and peaking EQ responses.

```zig
pub const BiquadFilter = struct {
    // Filter coefficients (configured by setup methods)
    a0: SampleType, a1: SampleType, a2: SampleType,
    b0: SampleType, b1: SampleType, b2: SampleType,

    // Internal state (stereo)
    x1: Frame, x2: Frame, y1: Frame, y2: Frame,
};
```

### Methods

#### `process(self: *BiquadFilter, input: Frame) Frame`
Process a single audio frame through the filter.

```zig
var filter = BiquadFilter{};
filter.setLowpass(44100.0, 1000.0, 0.707);

const output = filter.process(input_frame);
```

#### `reset(self: *BiquadFilter) void`
Clear the filter's internal state.

```zig
filter.reset(); // Remove any ringing/delay
```

#### `setLowpass(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType) void`
Configure as a lowpass filter.

- `sample_rate`: Audio sample rate (e.g., 44100.0)
- `frequency`: Cutoff frequency in Hz
- `q`: Quality factor (0.707 for Butterworth response)

```zig
filter.setLowpass(44100.0, 1000.0, 0.707); // 1kHz lowpass
```

#### `setHighpass(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType) void`
Configure as a highpass filter.

```zig
filter.setHighpass(44100.0, 80.0, 0.707); // 80Hz highpass
```

#### `setPeaking(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType, gain_db: SampleType) void`
Configure as a peaking EQ filter.

- `gain_db`: Gain in decibels (positive = boost, negative = cut)

```zig
filter.setPeaking(44100.0, 1000.0, 2.0, 6.0); // +6dB boost at 1kHz
```

## Example Usage

### Basic Lowpass Filtering
```zig
const std = @import("std");
const zdsp = @import("zdsp");

pub fn filterExample() void {
    var filter = zdsp.filters.BiquadFilter{};

    // Configure 1kHz lowpass filter
    filter.setLowpass(44100.0, 1000.0, 0.707);

    // Process audio frames
    for (input_buffer) |input_frame| {
        const filtered = filter.process(input_frame);
        // ... use filtered output
    }
}
```

### EQ Chain
```zig
pub fn eqExample() void {
    // Create EQ chain
    var low_shelf = zdsp.filters.BiquadFilter{};
    var mid_peak = zdsp.filters.BiquadFilter{};
    var high_shelf = zdsp.filters.BiquadFilter{};

    // Configure bands
    low_shelf.setLowpass(44100.0, 200.0, 0.707);
    mid_peak.setPeaking(44100.0, 1000.0, 2.0, 3.0); // +3dB at 1kHz
    high_shelf.setHighpass(44100.0, 8000.0, 0.707);

    // Process through chain
    for (input_buffer) |input_frame| {
        var signal = input_frame;
        signal = low_shelf.process(signal);
        signal = mid_peak.process(signal);
        signal = high_shelf.process(signal);
        // ... use processed signal
    }
}
```

### Filter Response Characteristics

| Filter Type | Use Case | Typical Q Values |
|-------------|----------|------------------|
| Lowpass | Remove high frequencies, anti-aliasing | 0.5 - 2.0 |
| Highpass | Remove low frequencies, rumble filtering | 0.5 - 2.0 |
| Peaking EQ | Boost/cut specific frequency bands | 0.5 - 10.0 |

**Q Factor Guidelines:**
- **0.5-0.7**: Gentle, musical filtering
- **0.707**: Butterworth (maximally flat) response
- **1.0-2.0**: Standard EQ curves
- **5.0+**: Very narrow, surgical EQ cuts/boosts