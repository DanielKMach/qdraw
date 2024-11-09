const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const Shape = @import("Shape.zig");

points: []raylib.Vector2,

pub fn init(points: []raylib.Vector2) This {
    return This{
        .points = points,
    };
}

pub fn render(self: This, x: i32, y: i32) void {
    const offset = raylib.Vector2.init(@floatFromInt(x), @floatFromInt(y));
    if (self.points.len == 0) return;
    drawLineTip(self.points[0].add(offset), 5, raylib.Color.white);
    for (0..self.points.len) |i| {
        if (i == 0) continue;
        drawLine(self.points[i].add(offset), self.points[i - 1].add(offset), 5, raylib.Color.white);
    }
}

pub fn deinit(self: This, alloc: std.mem.Allocator) void {
    alloc.free(self.points);
}

pub fn drawLine(start: raylib.Vector2, end: raylib.Vector2, thickness: f32, color: raylib.Color) void {
    raylib.drawLineEx(start, end, thickness, color);
    drawLineTip(end, thickness, color);
}

pub fn drawLineTip(pos: raylib.Vector2, thickness: f32, color: raylib.Color) void {
    raylib.drawCircleV(pos, thickness / 2, color);
}
