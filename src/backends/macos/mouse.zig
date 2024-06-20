// TODO: Convert f64 to i32 somehow. Every other system uses i3 to represent
//       mouse position, other than MacOS which uses f64.

const cg = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
});

///////////////////////////////////////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////////////////////////////////////
pub const MacosMouseButton = enum {
    /// An unknown button
    unknown = 3,
    /// Left click, also known as LMB
    left = cg.kCGMouseButtonLeft,
    /// Right click, also know as RMB
    right = cg.kCGMouseButtonRight,
    /// Middle click, also known as MMB
    middle = cg.kCGMouseButtonCenter,
};
pub const MacosMouseButtonState = enum { pressed, released, moved };
pub const MacosMousePosition = struct {
    x: f64,
    y: f64,

    pub fn new(x: f64, y: f64) MacosMousePosition {
        return .{ .x = x, .y = y };
    }
};

pub const MacosMouse = struct {
    pub fn init() MacosMouse {
        return .{};
    }

    pub fn deinit(_: *MacosMouse) void {
        // nothing to deinit
        return;
    }

    ///////////////////////////////////////////////////////////////////////////
    // CONTROL
    ///////////////////////////////////////////////////////////////////////////
    /// Returns the current position of the mouse pointer.
    pub fn getPosition(_: *MacosMouse) MacosMousePosition {
        const event: cg.CGEventRef = cg.CGEventCreate(null);
        const pos: cg.CGPoint = cg.CGEventGetLocation(event);
        cg.CFRelease(event);

        return MacosMousePosition.new(pos.x, pos.y);
    }

    /// Moves the mouse pointer to a given position.
    pub fn moveTo(_: *MacosMouse, x: f64, y: f64) !void {
        const event: cg.CGEventRef = cg.CGEventCreateMouseEvent(
            null,
            cg.kCGEventMouseMoved,
            cg.CGPointMake(x, y),
            cg.kCGMouseButtonLeft, // irrelevant for a move event
        );
        if (event == null) return error.EventCreationFailure;

        cg.CGEventPost(cg.kCGSessionEventTap, event);
        cg.CFRelease(event);
    }

    /// Moves the mouse pointer a number of pixels from its current position.
    /// This function is not to be confused with `moveTo`!
    pub fn moveBy(self: *MacosMouse, dx: f64, dy: f64) !void {
        const pos = self.getPosition();
        try self.moveTo(pos.x + dx, pos.y + dy);
    }

    /// Send scroll event.
    pub fn scroll(_: *MacosMouse, dx: f64, dy: f64) !void {
        const event: cg.CGEventRef = cg.CGEventCreateScrollWheelEvent(
            null,
            cg.kCGScrollEventUnitLine,
            2,
            dy,
            dx,
        );
        if (event == null) return error.EventCreationFailure;

        cg.CGEventPost(cg.kCGHIDEventTap, event);
        cg.CFRelease(event);
    }

    /// Emits a button press event at the current position.
    pub fn press(self: *MacosMouse, button: MacosMouseButton) !void {
        const pos = self.getPosition();
        self.pressAt(button, pos.x, pos.y);
    }

    /// Emits a button press event at a given position.
    pub fn pressAt(_: *MacosMouse, button: MacosMouseButton, x: f64, y: f64) !void {
        const point = cg.CGPointMake(x, y);
        const event: cg.CGEventRef = cg.CGEventCreateMouseEvent(
            null,
            switch (button) {
                .left => cg.kCGEventLeftMouseDown,
                .right => cg.kCGEventRightMouseDown,
                else => cg.kCGEventOtherMouseDown,
            },
            point,
            @intFromEnum(button),
        );
        if (event == null) return error.EventCreationFailure;

        cg.CGEventPost(cg.kCGHIDEventTap, event);
        cg.CFRelease(event);
    }

    /// Emits a button release event at the current position.
    pub fn release(self: *MacosMouse, button: MacosMouseButton) !void {
        const pos = self.getPosition();
        self.releaseAt(button, pos.x, pos.y);
    }

    /// Emits a button press event at a given position.
    pub fn releaseAt(_: *MacosMouse, button: MacosMouseButton, x: f64, y: f64) !void {
        const point = cg.CGPointMake(x, y);
        const event: cg.CGEventRef = cg.CGEventCreateMouseEvent(
            null,
            switch (button) {
                .left => cg.kCGEventLeftMouseUp,
                .right => cg.kCGEventRightMouseUp,
                else => cg.kCGEventOtherMouseUp,
            },
            point,
            @intFromEnum(button),
        );
        if (event == null) return error.EventCreationFailure;

        cg.CGEventPost(cg.kCGHIDEventTap, event);
        cg.CFRelease(event);
    }

    /// Emits a button press AND release event at the current position.
    pub fn click(self: *MacosMouse, button: MacosMouseButton) !void {
        const pos = try self.getPosition();
        self.clickAt(button, pos.x, pos.y);
    }

    /// Emits a button press AND release event at a given position.
    pub fn clickAt(self: *MacosMouse, button: MacosMouseButton, x: f64, y: f64) !void {
        try self.pressAt(button, x, y);
        try self.releaseAt(button, x, y);
    }
};

///////////////////////////////////////////////////////////////////////////////
// LISTENER
///////////////////////////////////////////////////////////////////////////////
