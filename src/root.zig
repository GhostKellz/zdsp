//! zdsp - Digital Signal Processing library for audio
const std = @import("std");

pub const filters = @import("filters.zig");
pub const effects = @import("effects.zig");
pub const synthesis = @import("synthesis.zig");

pub const SampleType = f32;

pub const Frame = struct {
    left: SampleType,
    right: SampleType,

    pub fn init(left: SampleType, right: SampleType) Frame {
        return Frame{ .left = left, .right = right };
    }

    pub fn mono(value: SampleType) Frame {
        return Frame{ .left = value, .right = value };
    }

    pub fn add(self: Frame, other: Frame) Frame {
        return Frame{
            .left = self.left + other.left,
            .right = self.right + other.right,
        };
    }

    pub fn multiply(self: Frame, gain: SampleType) Frame {
        return Frame{
            .left = self.left * gain,
            .right = self.right * gain,
        };
    }
};

pub const AudioBuffer = struct {
    frames: []Frame,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, size: usize) !AudioBuffer {
        const frames = try allocator.alloc(Frame, size);
        @memset(frames, Frame.mono(0.0));
        return AudioBuffer{
            .frames = frames,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AudioBuffer) void {
        self.allocator.free(self.frames);
    }

    pub fn clear(self: *AudioBuffer) void {
        @memset(self.frames, Frame.mono(0.0));
    }

    pub fn len(self: AudioBuffer) usize {
        return self.frames.len;
    }
};

test "Frame operations" {
    const frame1 = Frame.init(0.5, -0.3);
    const frame2 = Frame.mono(0.2);

    const sum = frame1.add(frame2);
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.7), sum.left, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, -0.1), sum.right, 1e-6);

    const scaled = frame1.multiply(2.0);
    try std.testing.expectApproxEqAbs(@as(SampleType, 1.0), scaled.left, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, -0.6), scaled.right, 1e-6);
}

test "AudioBuffer basic functionality" {
    const allocator = std.testing.allocator;

    var buffer = try AudioBuffer.init(allocator, 1024);
    defer buffer.deinit();

    try std.testing.expect(buffer.len() == 1024);

    buffer.frames[0] = Frame.init(0.5, -0.5);
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.5), buffer.frames[0].left, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, -0.5), buffer.frames[0].right, 1e-6);

    buffer.clear();
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), buffer.frames[0].left, 1e-6);
    try std.testing.expectApproxEqAbs(@as(SampleType, 0.0), buffer.frames[0].right, 1e-6);
}
