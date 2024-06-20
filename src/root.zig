const std = @import("std");

const backend = @import("backend.zig");
pub const Mouse = backend.Mouse;
pub const MouseButton = backend.MouseButton;
pub const MouseButtonState = backend.MouseButtonState;
pub const MousePosition = backend.MousePosition;

test {
    std.testing.refAllDecls(@This());
}
