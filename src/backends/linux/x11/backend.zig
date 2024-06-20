const mouse_backend = @import("mouse.zig");
pub const Mouse = mouse_backend.X11Mouse;
pub const MouseButton = mouse_backend.X11MouseButton;
pub const MouseButtonState = mouse_backend.X11MouseButtonState;
pub const MousePosition = mouse_backend.X11MousePosition;
