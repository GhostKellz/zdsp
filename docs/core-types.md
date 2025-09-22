# Core Types

The foundation of zdsp's audio processing system.

## SampleType

```zig
pub const SampleType = f32;
```

All audio samples in zdsp use 32-bit floating point values, typically in the range [-1.0, 1.0].

## Frame

Represents a single stereo audio frame (left and right channels).

```zig
pub const Frame = struct {
    left: SampleType,
    right: SampleType,
};
```

### Methods

#### `init(left: SampleType, right: SampleType) Frame`
Create a stereo frame with specific left/right values.

```zig
const frame = Frame.init(0.5, -0.3);
```

#### `mono(value: SampleType) Frame`
Create a mono frame (same value for both channels).

```zig
const frame = Frame.mono(0.7);
```

#### `add(self: Frame, other: Frame) Frame`
Add two frames together.

```zig
const sum = frame1.add(frame2);
```

#### `multiply(self: Frame, gain: SampleType) Frame`
Multiply frame by a gain value.

```zig
const scaled = frame.multiply(0.5); // 50% volume
```

## AudioBuffer

Dynamic audio buffer for storing multiple frames.

```zig
pub const AudioBuffer = struct {
    frames: []Frame,
    allocator: std.mem.Allocator,
};
```

### Methods

#### `init(allocator: std.mem.Allocator, size: usize) !AudioBuffer`
Create a new audio buffer.

```zig
var buffer = try AudioBuffer.init(allocator, 1024);
defer buffer.deinit();
```

#### `deinit(self: *AudioBuffer) void`
Free the buffer memory.

#### `clear(self: *AudioBuffer) void`
Clear all frames to silence.

#### `len(self: AudioBuffer) usize`
Get the buffer size in frames.

## Example Usage

```zig
const std = @import("std");
const zdsp = @import("zdsp");

pub fn processAudio() !void {
    const allocator = std.heap.page_allocator;

    // Create a buffer
    var buffer = try zdsp.AudioBuffer.init(allocator, 512);
    defer buffer.deinit();

    // Fill with some audio
    for (buffer.frames, 0..) |*frame, i| {
        const t = @as(f32, @floatFromInt(i)) / 512.0;
        frame.* = zdsp.Frame.mono(@sin(2.0 * std.math.pi * 440.0 * t));
    }

    // Process each frame
    for (buffer.frames) |frame| {
        const processed = frame.multiply(0.5); // Reduce volume
        // ... further processing
    }
}
```