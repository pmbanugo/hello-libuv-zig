const std = @import("std");
const uv = @cImport({
    @cInclude("uv.h");
});

const TimerContext = struct {
    timer: *uv.uv_timer_t,
    loop: *uv.uv_loop_t,
    count: u8,
};

pub fn main() !void {
    // Setup libuv loop and timer
    const loop = uv.uv_default_loop();
    var timer: uv.uv_timer_t = undefined;
    var ctx = TimerContext{
        .timer = &timer,
        .loop = loop,
        .count = 0,
    };
    timer.data = &ctx;
    const rc = uv.uv_timer_init(loop, &timer);
    if (rc != 0) {
        std.debug.print("Failed to init timer: {d}\n", .{rc});
        return;
    }
    const start_rc = uv.uv_timer_start(&timer, timer_cb, 0, 2000);
    if (start_rc != 0) {
        std.debug.print("Failed to start timer: {d}\n", .{start_rc});
        return;
    }
    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}

fn timer_cb(handle: [*c]uv.uv_timer_t) callconv(.C) void {
    var ctx: *TimerContext = @alignCast(@ptrCast(handle.?.*.data));
    ctx.count += 1;
    // print the count
    std.debug.print("Timer callback called {d} times.\n", .{ctx.count});

    if (ctx.count >= 3) {
        _ = uv.uv_timer_stop(handle);
        uv.uv_close(@ptrCast(handle), null);
        std.debug.print("Timer closed after 3 executions.\n", .{});
    }
}
