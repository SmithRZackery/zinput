//! A thin wrapper around the x11 and wayland backends.
//! Providing support for both in the same binary.

const mouse_backend = @import("mouse.zig");
pub const Mouse = mouse_backend.LinuxMouse;
pub const MouseButton = mouse_backend.LinuxMouseButton;
pub const MouseButtonState = mouse_backend.LinuxMouseButtonState;
pub const MousePosition = mouse_backend.LinuxMousePosition;
