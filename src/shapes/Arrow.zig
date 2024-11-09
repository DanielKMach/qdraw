const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const Line = @import("Line.zig");

line: Line,

pub fn init(points: []raylib.Vector2) This {
    return This{
        .line = Line.init(points),
    };
}

pub fn render(self: This, x: i32, y: i32) void {
    const offset = raylib.Vector2.init(@floatFromInt(x), @floatFromInt(y));
    const points = self.line.points;
    self.line.render(x, y);

    // Draw tip
    const tip = points[points.len - 1];
    var before: raylib.Vector2 = undefined;
    for (1..points.len) |i| {
        before = points[points.len - i];
        if (before.distance(tip) > 10) break;
    }
    const dir = before.subtract(tip);
    const dirn = dir.normalize();
    const tip1 = tip.add(dirn.rotate(45 * std.math.rad_per_deg).scale(20));
    raylib.drawLineEx(tip.add(offset), tip1.add(offset), 5, raylib.Color.white);
    const tip2 = tip.add(dirn.rotate(-45 * std.math.rad_per_deg).scale(20));
    raylib.drawLineEx(tip.add(offset), tip2.add(offset), 5, raylib.Color.white);
}

pub fn deinit(self: This, alloc: std.mem.Allocator) void {
    self.line.deinit(alloc);
}
