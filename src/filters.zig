const std = @import("std");
const root = @import("root.zig");
const SampleType = root.SampleType;
const Frame = root.Frame;

pub const BiquadFilter = struct {
    a0: SampleType = 1.0,
    a1: SampleType = 0.0,
    a2: SampleType = 0.0,
    b0: SampleType = 1.0,
    b1: SampleType = 0.0,
    b2: SampleType = 0.0,

    x1: Frame = Frame.mono(0.0),
    x2: Frame = Frame.mono(0.0),
    y1: Frame = Frame.mono(0.0),
    y2: Frame = Frame.mono(0.0),

    pub fn process(self: *BiquadFilter, input: Frame) Frame {
        const output = Frame{
            .left = (self.b0 * input.left + self.b1 * self.x1.left + self.b2 * self.x2.left - self.a1 * self.y1.left - self.a2 * self.y2.left) / self.a0,
            .right = (self.b0 * input.right + self.b1 * self.x1.right + self.b2 * self.x2.right - self.a1 * self.y1.right - self.a2 * self.y2.right) / self.a0,
        };

        self.x2 = self.x1;
        self.x1 = input;
        self.y2 = self.y1;
        self.y1 = output;

        return output;
    }

    pub fn reset(self: *BiquadFilter) void {
        self.x1 = Frame.mono(0.0);
        self.x2 = Frame.mono(0.0);
        self.y1 = Frame.mono(0.0);
        self.y2 = Frame.mono(0.0);
    }

    pub fn setLowpass(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType) void {
        const omega = 2.0 * std.math.pi * frequency / sample_rate;
        const sin_omega = @sin(omega);
        const cos_omega = @cos(omega);
        const alpha = sin_omega / (2.0 * q);

        const b0 = (1.0 - cos_omega) / 2.0;
        const b1 = 1.0 - cos_omega;
        const b2 = (1.0 - cos_omega) / 2.0;
        const a0 = 1.0 + alpha;
        const a1 = -2.0 * cos_omega;
        const a2 = 1.0 - alpha;

        self.a0 = a0;
        self.a1 = a1;
        self.a2 = a2;
        self.b0 = b0;
        self.b1 = b1;
        self.b2 = b2;
    }

    pub fn setHighpass(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType) void {
        const omega = 2.0 * std.math.pi * frequency / sample_rate;
        const sin_omega = @sin(omega);
        const cos_omega = @cos(omega);
        const alpha = sin_omega / (2.0 * q);

        const b0 = (1.0 + cos_omega) / 2.0;
        const b1 = -(1.0 + cos_omega);
        const b2 = (1.0 + cos_omega) / 2.0;
        const a0 = 1.0 + alpha;
        const a1 = -2.0 * cos_omega;
        const a2 = 1.0 - alpha;

        self.a0 = a0;
        self.a1 = a1;
        self.a2 = a2;
        self.b0 = b0;
        self.b1 = b1;
        self.b2 = b2;
    }

    pub fn setPeaking(self: *BiquadFilter, sample_rate: SampleType, frequency: SampleType, q: SampleType, gain_db: SampleType) void {
        const A = std.math.pow(SampleType, 10.0, gain_db / 40.0);
        const omega = 2.0 * std.math.pi * frequency / sample_rate;
        const sin_omega = @sin(omega);
        const cos_omega = @cos(omega);
        const alpha = sin_omega / (2.0 * q);

        const b0 = 1.0 + alpha * A;
        const b1 = -2.0 * cos_omega;
        const b2 = 1.0 - alpha * A;
        const a0 = 1.0 + alpha / A;
        const a1 = -2.0 * cos_omega;
        const a2 = 1.0 - alpha / A;

        self.a0 = a0;
        self.a1 = a1;
        self.a2 = a2;
        self.b0 = b0;
        self.b1 = b1;
        self.b2 = b2;
    }
};

test "BiquadFilter lowpass basic functionality" {
    var filter = BiquadFilter{};
    filter.setLowpass(44100.0, 1000.0, 0.707);

    const impulse = Frame.mono(1.0);
    const silence = Frame.mono(0.0);

    const output1 = filter.process(impulse);
    const output2 = filter.process(silence);
    const output3 = filter.process(silence);

    try std.testing.expect(output1.left > 0.0);
    try std.testing.expect(@abs(output2.left) < @abs(output1.left));
    try std.testing.expect(@abs(output3.left) < @abs(output2.left));
}

test "BiquadFilter reset functionality" {
    var filter = BiquadFilter{};
    filter.setLowpass(44100.0, 1000.0, 0.707);

    _ = filter.process(Frame.mono(1.0));
    _ = filter.process(Frame.mono(0.5));

    filter.reset();

    try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), filter.x1.left, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), filter.y1.left, 1e-6);
}