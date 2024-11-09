const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Line = @import("../shapes/Line.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,

linex: i32 = 0,
liney: i32 = 0,
line: ?Line = null,
points: std.ArrayList(raylib.Vector2),

pub fn init(allocator: std.mem.Allocator, context: QDraw.Context) This {
    return This{
        .context = context,
        .allocator = allocator,
        .points = std.ArrayList(raylib.Vector2).init(allocator),
    };
}

pub fn tick(self: *This) !void {
    if (raylib.isMouseButtonDown(.mouse_button_left)) {
        const mpos = raylib.getScreenToWorld2D(raylib.getMousePosition(), self.context.camera.*);
        if (self.line == null) {
            self.linex = @intFromFloat(mpos.x);
            self.liney = @intFromFloat(mpos.y);
            self.line = Line.init(self.points.items);
        }
        if (self.points.items.len == 0 or self.points.items[self.points.items.len - 1].distance(mpos) > 10) {
            try self.points.append(mpos.subtract(raylib.Vector2.init(@floatFromInt(self.linex), @floatFromInt(self.liney))));
            self.line.?.points = self.points.items;
        }
    } else {
        if (self.line) |*line| {
            line.points = try self.points.toOwnedSlice();
            try self.context.canvas.shapes.append(try Shape.init(line.*, self.linex, self.liney, self.context.qdraw.allocator));
            self.context.canvas.requestRerender();
            self.line = null;
            self.context.releaseFocus(self);
        }
    }
}

pub fn listen(self: *This) void {
    if (raylib.isMouseButtonDown(.mouse_button_left)) {
        self.context.requestFocus(self);
    }
}

pub fn render(self: *This) void {
    if (self.line) |s| {
        s.render(self.linex, self.liney);
    }
}
