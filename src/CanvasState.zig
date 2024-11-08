const raylib = @import("raylib");
const std = @import("std");

const This = @This();
const Shape = @import("shapes/Shape.zig");
const Tool = @import("tools/Tool.zig");

shapes: std.ArrayList(Shape),
allocator: std.mem.Allocator,
texture: raylib.RenderTexture,
rerender: bool = true,

pub fn init(allocator: std.mem.Allocator) !This {
    const texture = raylib.RenderTexture.init(
        raylib.getScreenWidth(),
        raylib.getScreenHeight(),
    );

    return This{
        .shapes = std.ArrayList(Shape).init(allocator),
        .allocator = allocator,
        .texture = texture,
    };
}

pub fn requestRerender(self: *This) void {
    std.debug.print("Requested rerender\r\n", .{});
    self.rerender = true;
}

pub fn render(self: *This) void {
    if (self.rerender) {
        defer self.rerender = false;
        self.texture.begin();
        defer self.texture.end();
        raylib.clearBackground(raylib.Color.init(10, 10, 10, 255));
        for (self.shapes.items) |shape| {
            shape.render();
        }
        std.debug.print("Rerendered {d} shapes\r\n", .{self.shapes.items.len});
    }

    const source = raylib.Rectangle.init(0, 0, @floatFromInt(self.texture.texture.width), @floatFromInt(-self.texture.texture.height));
    raylib.drawTextureRec(self.texture.texture, source, raylib.Vector2.init(0, 0), raylib.Color.white);
}