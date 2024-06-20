//////////////////////////////////////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////////////////////////////////////
pub const WaylandMouseButton = enum {
    unknown,
    left,
    right,
    middle,
};
pub const WaylandMouseState = enum { pressed, released, moved };
pub const WaylandMousePosition = struct {
    x: i32,
    y: i32,

    pub fn new(x: i32, y: i32) WaylandMousePosition {
        return .{ .x = x, .y = y };
    }
};

pub const WaylandMouse = struct {
    pub fn init() WaylandMouse {
        return .{};
    }

    pub fn deinit(self: *WaylandMouse) void {
        _ = self;
        // nothing to do yet...
        return;
    }

    ///////////////////////////////////////////////////////////////////////////
    // CONTROL
    ///////////////////////////////////////////////////////////////////////////
    pub fn getPosition(self: *WaylandMouse) WaylandMousePosition {
        _ = self;
        return WaylandMousePosition.new(0, 0);
    }

    pub fn moveTo(self: *WaylandMouse, x: i32, y: i32) !void {
        _ = self;
        _ = x;
        _ = y;
    }

    pub fn moveBy(self: *WaylandMouse, dx: i32, dy: i32) !void {
        _ = self;
        _ = dx;
        _ = dy;
    }

    pub fn scroll(self: *WaylandMouse, dx: i32, dy: i32) !void {
        _ = self;
        _ = dx;
        _ = dy;
    }

    pub fn press(self: *WaylandMouse, button: WaylandMouseButton) !void {
        _ = self;
        _ = button;
    }

    pub fn pressAt(self: *WaylandMouse, button: WaylandMouseButton, x: i32, y: i32) !void {
        try self.moveTo(x, y);
        try self.press(button);
    }

    pub fn release(self: *WaylandMouse, button: WaylandMouseButton) !void {
        _ = self;
        _ = button;
    }

    pub fn releaseAt(self: *WaylandMouse, button: WaylandMouseButton, x: i32, y: i32) !void {
        try self.moveTo(x, y);
        try self.release(button);
    }

    pub fn click(self: *WaylandMouse, button: WaylandMouseButton) !void {
        try self.press(button);
        try self.release(button);
    }

    pub fn clickAt(self: *WaylandMouse, button: WaylandMouseButton, x: i32, y: i32) !void {
        try self.pressAt(button, x, y);
        try self.releaseAt(button, x, y);
    }
};

///////////////////////////////////////////////////////////////////////////////
// LISTENER
///////////////////////////////////////////////////////////////////////////////
