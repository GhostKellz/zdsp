const std = @import("std");
const root = @import("root.zig");
const SampleType = root.SampleType;
const Frame = root.Frame;

pub const Delay = struct {
    buffer: []Frame,
    write_index: usize = 0,
    delay_samples: usize,
    feedback: SampleType = 0.3,
    wet_mix: SampleType = 0.5,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, max_delay_samples: usize) !Delay {
        const buffer = try allocator.alloc(Frame, max_delay_samples);
        @memset(buffer, Frame.mono(0.0));

        return Delay{
            .buffer = buffer,
            .delay_samples = max_delay_samples / 2,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Delay) void {
        self.allocator.free(self.buffer);
    }

    pub fn setDelayTime(self: *Delay, delay_samples: usize) void {
        self.delay_samples = @min(delay_samples, self.buffer.len - 1);
    }

    pub fn setFeedback(self: *Delay, feedback: SampleType) void {
        self.feedback = std.math.clamp(feedback, 0.0, 0.95);
    }

    pub fn setWetMix(self: *Delay, wet_mix: SampleType) void {
        self.wet_mix = std.math.clamp(wet_mix, 0.0, 1.0);
    }

    pub fn process(self: *Delay, input: Frame) Frame {
        const read_index = if (self.write_index >= self.delay_samples)
            self.write_index - self.delay_samples
        else
            self.buffer.len - (self.delay_samples - self.write_index);

        const delayed = self.buffer[read_index];

        const feedback_signal = delayed.multiply(self.feedback);
        const buffer_input = input.add(feedback_signal);

        self.buffer[self.write_index] = buffer_input;

        self.write_index = (self.write_index + 1) % self.buffer.len;

        const dry_mix = 1.0 - self.wet_mix;
        const dry_signal = input.multiply(dry_mix);
        const wet_signal = delayed.multiply(self.wet_mix);

        return dry_signal.add(wet_signal);
    }

    pub fn clear(self: *Delay) void {
        @memset(self.buffer, Frame.mono(0.0));
        self.write_index = 0;
    }
};

test "Delay basic functionality" {
    const allocator = std.testing.allocator;

    var delay = try Delay.init(allocator, 1000);
    defer delay.deinit();

    delay.setDelayTime(10);
    delay.setFeedback(0.5);
    delay.setWetMix(1.0);

    const impulse = Frame.mono(1.0);
    const silence = Frame.mono(0.0);

    var output = delay.process(impulse);
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), output.left, 1e-6);

    for (0..9) |_| {
        output = delay.process(silence);
        try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), output.left, 1e-6);
    }

    output = delay.process(silence);
    try std.testing.expect(output.left > 0.9);
}

test "Delay wet/dry mix" {
    const allocator = std.testing.allocator;

    var delay = try Delay.init(allocator, 100);
    defer delay.deinit();

    delay.setDelayTime(1);
    delay.setWetMix(0.5);

    const input = Frame.mono(1.0);

    _ = delay.process(input);
    const output = delay.process(Frame.mono(0.0));

    try std.testing.expect(output.left > 0.0);
    try std.testing.expect(output.left < 1.0);
}