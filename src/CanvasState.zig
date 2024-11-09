const raylib = @import("raylib");
const std = @import("std");

const This = @This();
const Shape = @import("shapes/Shape.zig");
const Tool = @import("tools/Tool.zig");

const log = std.log.scoped(.canvas);

shapes: std.ArrayList(Shape),
allocator: std.mem.Allocator,
texture: raylib.RenderTexture,
redraw: bool = true,

pub fn init(allocator: std.mem.Allocator, width: i32, height: i32) !This {
    const texture = raylib.RenderTexture.init(width, height);

    return This{
        .shapes = std.ArrayList(Shape).init(allocator),
        .allocator = allocator,
        .texture = texture,
    };
}

pub fn requestRedraw(self: *This) void {
    log.info("Redraw requested", .{});
    self.redraw = true;
}

pub fn render(self: *This) void {
    if (self.redraw) {
        defer self.redraw = false;
        self.texture.begin();
        defer self.texture.end();
        raylib.clearBackground(raylib.Color.init(10, 10, 10, 255));
        for (self.shapes.items) |shape| {
            shape.render();
        }
        log.info("Redrawn {d} shapes", .{self.shapes.items.len});
    }

    const source = raylib.Rectangle.init(0, 0, @floatFromInt(self.texture.texture.width), @floatFromInt(-self.texture.texture.height));
    raylib.drawTextureRec(self.texture.texture, source, raylib.Vector2.init(0, 0), raylib.Color.white);
}

pub fn clear(self: *This) void {
    for (self.shapes.items) |shape| {
        shape.deinit();
    }
    self.shapes.clearAndFree();
    self.requestRedraw();
}
