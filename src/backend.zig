const std = @import("std");
const builtin = @import("builtin");

const backend = switch (builtin.os.tag) {
    .windows => @import("backends/win32/backend.zig"),
    .macos => @import("backends/macos/backend.zig"),
    .linux, .freebsd => @import("backends/linux/backend.zig"),
    else => @compileError(std.fmt.comptimePrint("Unsupported OS: {}", .{builtin.os.tag})),
};
// import backend into the namespace, simplifies backend calles from:
// `backend.backend.somefunction` to `backend.somefunction`
pub usingnamespace backend;

test "sanity: Ensure selected backend compiles" {
    std.testing.refAllDecls(backend);

    std.debug.print("PASSED\n", .{});
}
