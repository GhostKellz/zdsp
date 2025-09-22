const std = @import("std");
const zdsp = @import("zdsp");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    std.debug.print("zdsp - Digital Signal Processing Library\n", .{});
    std.debug.print("========================================\n\n", .{});

    var osc = zdsp.synthesis.Oscillator.init(44100.0);
    osc.setFrequency(440.0);
    osc.setAmplitude(0.8);

    var filter = zdsp.filters.BiquadFilter{};
    filter.setLowpass(44100.0, 1000.0, 0.707);

    var delay = try zdsp.effects.Delay.init(allocator, 4410);
    defer delay.deinit();
    delay.setDelayTime(2205);
    delay.setFeedback(0.4);
    delay.setWetMix(0.3);

    std.debug.print("Processing 1000 samples through sine -> lowpass -> delay chain:\n", .{});

    for (0..1000) |i| {
        const sine_wave = osc.sineFrame();

        const filtered = filter.process(sine_wave);

        const delayed = delay.process(filtered);

        if (i % 100 == 0) {
            std.debug.print("Sample {}: {d:.6} -> {d:.6} -> {d:.6}\n", .{ i, sine_wave.left, filtered.left, delayed.left });
        }
    }

    std.debug.print("\nLibrary components ready:\n", .{});
    std.debug.print("- Audio buffers and frame types\n", .{});
    std.debug.print("- Biquad filters (lowpass, highpass, peaking EQ)\n", .{});
    std.debug.print("- Delay effect with feedback\n", .{});
    std.debug.print("- Oscillators (sine, saw, square, triangle)\n", .{});
    std.debug.print("- Noise generator\n", .{});
    std.debug.print("\nRun 'zig build test' to verify all components!\n", .{});
}
