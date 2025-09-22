const std = @import("std");
const root = @import("root.zig");
const SampleType = root.SampleType;
const Frame = root.Frame;

pub const Oscillator = struct {
    phase: SampleType = 0.0,
    frequency: SampleType = 440.0,
    sample_rate: SampleType = 44100.0,
    amplitude: SampleType = 1.0,

    pub fn init(sample_rate: SampleType) Oscillator {
        return Oscillator{
            .sample_rate = sample_rate,
        };
    }

    pub fn setFrequency(self: *Oscillator, frequency: SampleType) void {
        self.frequency = frequency;
    }

    pub fn setAmplitude(self: *Oscillator, amplitude: SampleType) void {
        self.amplitude = amplitude;
    }

    pub fn reset(self: *Oscillator) void {
        self.phase = 0.0;
    }

    fn advance(self: *Oscillator) void {
        const phase_increment = self.frequency / self.sample_rate;
        self.phase += phase_increment;
        if (self.phase >= 1.0) {
            self.phase -= 1.0;
        }
    }

    pub fn sine(self: *Oscillator) SampleType {
        const output = self.amplitude * @sin(2.0 * std.math.pi * self.phase);
        self.advance();
        return output;
    }

    pub fn sineFrame(self: *Oscillator) Frame {
        const sample = self.sine();
        return Frame.mono(sample);
    }

    pub fn saw(self: *Oscillator) SampleType {
        const output = self.amplitude * (2.0 * self.phase - 1.0);
        self.advance();
        return output;
    }

    pub fn sawFrame(self: *Oscillator) Frame {
        const sample = self.saw();
        return Frame.mono(sample);
    }

    pub fn square(self: *Oscillator) SampleType {
        const output = if (self.phase < 0.5) self.amplitude else -self.amplitude;
        self.advance();
        return output;
    }

    pub fn squareFrame(self: *Oscillator) Frame {
        const sample = self.square();
        return Frame.mono(sample);
    }

    pub fn triangle(self: *Oscillator) SampleType {
        const output = if (self.phase < 0.5)
            self.amplitude * (4.0 * self.phase - 1.0)
        else
            self.amplitude * (3.0 - 4.0 * self.phase);
        self.advance();
        return output;
    }

    pub fn triangleFrame(self: *Oscillator) Frame {
        const sample = self.triangle();
        return Frame.mono(sample);
    }
};

pub const NoiseGenerator = struct {
    rng: std.Random.DefaultPrng,
    amplitude: SampleType = 1.0,

    pub fn init(seed: u64) NoiseGenerator {
        return NoiseGenerator{
            .rng = std.Random.DefaultPrng.init(seed),
        };
    }

    pub fn setAmplitude(self: *NoiseGenerator, amplitude: SampleType) void {
        self.amplitude = amplitude;
    }

    pub fn white(self: *NoiseGenerator) SampleType {
        const random_value = self.rng.random().float(SampleType);
        return self.amplitude * (2.0 * random_value - 1.0);
    }

    pub fn whiteFrame(self: *NoiseGenerator) Frame {
        const sample = self.white();
        return Frame.mono(sample);
    }
};

test "Oscillator sine wave" {
    var osc = Oscillator.init(44100.0);
    osc.setFrequency(440.0);
    osc.setAmplitude(1.0);

    const sample1 = osc.sine();
    const sample2 = osc.sine();

    try std.testing.expect(@abs(sample1) <= 1.0);
    try std.testing.expect(@abs(sample2) <= 1.0);
    try std.testing.expect(sample1 != sample2);
}

test "Oscillator square wave" {
    var osc = Oscillator.init(44100.0);
    osc.setFrequency(1.0);
    osc.setAmplitude(1.0);

    const sample1 = osc.square();
    for (0..22049) |_| {
        _ = osc.square();
    }
    const sample2 = osc.square();

    try std.testing.expectApproxEqAbs(@as(SampleType, 1.0), sample1, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, -1.0), sample2, 1e-6);
}

test "NoiseGenerator basic functionality" {
    var noise = NoiseGenerator.init(12345);
    noise.setAmplitude(0.5);

    const sample1 = noise.white();
    const sample2 = noise.white();

    try std.testing.expect(@abs(sample1) <= 0.5);
    try std.testing.expect(@abs(sample2) <= 0.5);
    try std.testing.expect(sample1 != sample2);
}