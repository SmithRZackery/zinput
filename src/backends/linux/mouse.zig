const std = @import("std");

// BOTH x11 and wayland backends must be included in the binary
const x11_backend = @import("x11/backend.zig");
const wayland_backend = @import("wayland/backend.zig");

const LinuxMouseBackend = union(enum) {
    x11: x11_backend.Mouse,
    wayland: wayland_backend.Mouse,
};

///////////////////////////////////////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////////////////////////////////////
pub const LinuxMouseButton = enum {
    unknown,
    left,
    right,
    middle,

    pub fn toX11(self: LinuxMouseButton) x11_backend.MouseButton {
        return switch (self) {
            .unknown => x11_backend.MouseButton.unknown,
            .left => x11_backend.MouseButton.left,
            .right => x11_backend.MouseButton.right,
            .middle => x11_backend.MouseButton.middle,
        };
    }

    pub fn toWayland(self: LinuxMouseButton) wayland_backend.MouseButton {
        return switch (self) {
            .unknown => wayland_backend.MouseButton.unknown,
            .left => wayland_backend.MouseButton.left,
            .right => wayland_backend.MouseButton.right,
            .middle => wayland_backend.MouseButton.middle,
        };
    }
};
pub const LinuxMouseButtonState = enum { pressed, released, moved };
pub const LinuxMousePosition = struct {
    x: i32,
    y: i32,

    pub fn new(x: i32, y: i32) LinuxMousePosition {
        return .{ .x = x, .y = y };
    }
};

pub const LinuxMouse = struct {
    inner: LinuxMouseBackend,

    pub fn init() LinuxMouse {
        const xdg_session_type = std.posix.getenv("XDG_SESSION_TYPE");
        if (xdg_session_type != null) {
            if (std.mem.eql(u8, "x11", xdg_session_type.?)) {
                return .{
                    .inner = .{
                        .x11 = x11_backend.Mouse.init(),
                    },
                };
            }

            if (std.mem.eql(u8, "wayland", xdg_session_type.?)) {
                return .{
                    .inner = .{
                        .wayland = wayland_backend.Mouse.init(),
                    },
                };
            }
        }

        @panic("No supported linux backend found!");
    }

    pub fn deinit(self: *LinuxMouse) void {
        switch (self.inner) {
            .x11 => self.inner.x11.deinit(),
            .wayland => self.inner.wayland.deinit(),
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // CONTROL
    ///////////////////////////////////////////////////////////////////////////
    /// Returns the current position of the mouse pointer.
    pub fn getPosition(self: *LinuxMouse) LinuxMousePosition {
        switch (self.inner) {
            .x11 => {
                const pos = self.inner.x11.getPosition();
                return LinuxMousePosition.new(pos.x, pos.y);
            },
            .wayland => {
                const pos = self.inner.wayland.getPosition();
                return LinuxMousePosition.new(pos.x, pos.y);
            },
        }
    }

    /// Moves the mouse pointer to a given position.
    pub fn moveTo(self: *LinuxMouse, x: i32, y: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.moveTo(x, y),
            .wayland => try self.inner.wayland.moveTo(x, y),
        }
    }

    /// Moves the mouse pointer a number of pixels from its current position.
    /// This function is not to be confused with `moveTo`!
    pub fn moveBy(self: *LinuxMouse, dx: i32, dy: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.moveBy(dx, dy),
            .wayland => try self.inner.wayland.moveBy(dx, dy),
        }
    }

    // NOTE: Maybe I should add "scroll buttons" into the Button enum
    /// Send scroll event.
    pub fn scroll(self: *LinuxMouse, dx: i32, dy: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.scroll(dx, dy),
            .wayland => try self.inner.wayland.scroll(dx, dy),
        }
    }

    /// Emits a button press event at the current position.
    pub fn press(self: *LinuxMouse, button: LinuxMouseButton) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.press(button.toX11()),
            .wayland => try self.inner.wayland.press(button.toWayland()),
        }
    }

    /// Emits a button press event at a given position.
    pub fn pressAt(self: *LinuxMouse, button: LinuxMouseButton, x: i32, y: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.pressAt(button.toX11(), x, y),
            .wayland => try self.inner.wayland.press(button.toWayland(), x, y),
        }
    }

    /// Emits a button release event at the current position.
    pub fn release(self: *LinuxMouse, button: LinuxMouseButton) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.release(button.toX11()),
            .wayland => try self.inner.wayland.release(button.toWayland()),
        }
    }

    /// Emits a button press event at a given position.
    pub fn releaseAt(self: *LinuxMouse, button: LinuxMouseButton, x: i32, y: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.releaseAt(button.toX11(), x, y),
            .wayland => try self.inner.wayland.releaseAt(button.toWayland(), x, y),
        }
    }

    /// Emits a button press AND release event at the current position.
    pub fn click(self: *LinuxMouse, button: LinuxMouseButton) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.click(button.toX11()),
            .wayland => try self.inner.wayland.press(button.toWayland()),
        }
    }

    /// Emits a button press AND release event at a given position.
    pub fn clickAt(self: *LinuxMouse, button: LinuxMouseButton, x: i32, y: i32) !void {
        switch (self.inner) {
            .x11 => try self.inner.x11.clickAt(button.toX11(), x, y),
            .wayland => try self.inner.wayland.clickAt(button.toWayland(), x, y),
        }
    }
};

///////////////////////////////////////////////////////////////////////////////
// LISTENER
///////////////////////////////////////////////////////////////////////////////
