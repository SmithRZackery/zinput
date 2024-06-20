//! A wrapper around xdo.h
const x11 = @cImport(@cInclude("xdo.h"));

// TODO: delete me
const std = @import("std");

//////////////////////////////////////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////////////////////////////////////
pub const X11MouseButton = enum(c_int) {
    unknown = 0,
    left = 1,
    right = 3,
    middle = 2,
};
pub const X11MouseState = enum { pressed, released, moved };
pub const X11MousePosition = struct {
    x: i32,
    y: i32,

    pub fn new(x: i32, y: i32) X11MousePosition {
        return .{ .x = x, .y = y };
    }
};

pub const X11Mouse = struct {
    xdo: *x11.xdo_t = undefined,

    pub fn init() X11Mouse {
        return .{ .xdo = x11.xdo_new(null) };
    }

    pub fn deinit(self: *X11Mouse) void {
        x11.xdo_free(self.xdo);
    }

    ///////////////////////////////////////////////////////////////////////////
    // CONTROL
    ///////////////////////////////////////////////////////////////////////////
    pub fn getPosition(self: *X11Mouse) X11MousePosition {
        var x: c_int = undefined;
        var y: c_int = undefined;
        var screen_num: c_int = undefined;
        _ = x11.xdo_get_mouse_location(self.xdo, &x, &y, &screen_num);
        return X11MousePosition.new(x, y);
    }

    pub fn moveTo(self: *X11Mouse, x: i32, y: i32) !void {
        _ = x11.xdo_move_mouse(self.xdo, x, y, x11.CURRENTWINDOW);
    }

    pub fn moveBy(self: *X11Mouse, dx: i32, dy: i32) !void {
        _ = x11.xdo_move_mouse_relative(self.xdo, dx, dy);
    }

    pub fn scroll(self: *X11Mouse, dx: i32, dy: i32) !void {
        _ = self;
        _ = dx;
        _ = dy;
        std.debug.print("scroll: NOT IMPLEMENTED\n", .{});
    }

    pub fn press(self: *X11Mouse, button: X11MouseButton) !void {
        _ = x11.xdo_mouse_down(self.xdo, x11.CURRENTWINDOW, @intFromEnum(button));
    }

    pub fn pressAt(self: *X11Mouse, button: X11MouseButton, x: i32, y: i32) !void {
        try self.moveTo(x, y);
        try self.press(button);
    }

    pub fn release(self: *X11Mouse, button: X11MouseButton) !void {
        _ = x11.xdo_mouse_up(self.xdo, x11.CURRENTWINDOW, @intFromEnum(button));
    }

    pub fn releaseAt(self: *X11Mouse, button: X11MouseButton, x: i32, y: i32) !void {
        try self.moveTo(x, y);
        try self.release(button);
    }

    pub fn click(self: *X11Mouse, button: X11MouseButton) !void {
        try self.press(button);
        try self.release(button);
    }

    pub fn clickAt(self: *X11Mouse, button: X11MouseButton, x: i32, y: i32) !void {
        try self.pressAt(button, x, y);
        try self.releaseAt(button, x, y);
    }
};

///////////////////////////////////////////////////////////////////////////////
// LISTENER
///////////////////////////////////////////////////////////////////////////////
