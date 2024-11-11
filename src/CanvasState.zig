const raylib = @import("raylib");
const std = @import("std");

const This = @This();
const Shape = @import("shapes/Shape.zig");
const Tool = @import("tools/Tool.zig");

const log = std.log.scoped(.canvas);

shapes: std.ArrayList(Shape),
allocator: std.mem.Allocator,
texture: raylib.RenderTexture,
obj_map: raylib.Image,
redraw_requested: bool = true,

pub fn init(allocator: std.mem.Allocator, width: i32, height: i32) !This {
    const texture = raylib.RenderTexture.init(width, height);
    const obj_map = raylib.Image.fromTexture(texture.texture);

    return This{
        .shapes = std.ArrayList(Shape).init(allocator),
        .allocator = allocator,
        .texture = texture,
        .obj_map = obj_map,
    };
}

pub fn requestRedraw(self: *This) void {
    self.redraw_requested = true;
    log.info("Redraw requested", .{});
}

pub fn pickShape(self: *This, x: i32, y: i32) ?*Shape {
    const sample_color: u32 = @bitCast(self.obj_map.getColor(x, @as(i32, @intCast(self.obj_map.height)) - y).toInt());
    if (sample_color != 0) {
        const index = @bitReverse(sample_color & 0xFFFFFF00);
        if (index >= 0 and index < self.shapes.items.len) {
            return &self.shapes.items[index];
        }
    }
    return null;
}

pub fn pickShapeV(self: *This, v: raylib.Vector2) ?*Shape {
    return self.pickShape(@intFromFloat(v.x), @intFromFloat(v.y));
}

pub fn redraw(self: *This) void {
    if (!self.redraw_requested) return;
    defer self.redraw_requested = false;
    {
        self.texture.begin();
        defer self.texture.end();

        raylib.clearBackground(raylib.Color.blank);
        for (0..self.shapes.items.len) |i| {
            const shape = &self.shapes.items[i];

            const color_hex: u32 = @bitReverse(@as(u32, @intCast(i)) | 0xFF000000);
            shape.renderColored(raylib.Color.fromInt(color_hex));
        }
    }
    self.obj_map.unload();
    self.obj_map = raylib.Image.fromTexture(self.texture.texture);
    {
        self.texture.begin();
        defer self.texture.end();

        raylib.gl.rlEnableSmoothLines();
        defer raylib.gl.rlDisableSmoothLines();

        raylib.clearBackground(raylib.Color.init(10, 10, 10, 255));
        for (self.shapes.items) |shape| {
            shape.render();
        }
    }
    log.info("Redrawn {d} shapes", .{self.shapes.items.len});
}

pub fn render(self: *This) void {
    if (self.redraw_requested) {
        self.redraw();
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
