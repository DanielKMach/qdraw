const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Square = @import("../shapes/Square.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,
trigger_key: raylib.KeyboardKey,
squarex: i32 = 0,
squarey: i32 = 0,
square: ?Square = null,

pub fn init(allocator: std.mem.Allocator, trigger_key: raylib.KeyboardKey, context: QDraw.Context) This {
    return This{
        .context = context,
        .trigger_key = trigger_key,
        .allocator = allocator,
    };
}

pub fn tick(self: *This) void {
    if (raylib.isKeyDown(self.trigger_key)) {
        if (self.square == null) {
            // std.debug.print("mouse = ({d}, {d})\r\n", .{@intFromFloat(raylib.getMousePosition().x), @intFromFloat(raylib.getMousePosition().y)});
            self.squarex = raylib.getMouseX();
            self.squarey = raylib.getMouseY();
            self.square = Square.init(0, 0);
        }
        self.square.?.width = raylib.getMouseX() - self.squarex;
        self.square.?.height = raylib.getMouseY() - self.squarey;
    } else {
        if (self.square) |sqr| {
            self.context.canvas.shapes.append(Shape.init(sqr, self.squarex, self.squarey, self.context.qdraw.allocator) catch unreachable) catch unreachable;
            self.context.canvas.requestRerender();
            self.square = null;
            self.context.releaseFocus(self);
        }
    }
}

pub fn listen(self: *This) void {
    if (raylib.isKeyPressed(self.trigger_key)) {
        self.context.requestFocus(self);
    }
}

pub fn render(self: *This) void {
    if (self.square) |s| {
        s.render(self.squarex, self.squarey);
    }
}
