const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const RenderFn = fn (self: *anyopaque, x: i32, y: i32) void;

x: i32,
y: i32,
alloc: std.mem.Allocator,
data: *anyopaque,
renderFn: *const RenderFn,

pub fn init(shape: anytype, x: i32, y: i32, alloc: std.mem.Allocator) !This {
    const ShapeType = @TypeOf(shape);
    const typeInfo = @typeInfo(ShapeType);

    if (typeInfo != .Struct) {
        @compileError(@typeName(ShapeType) ++ " must be a struct");
    }

    if (!@hasDecl(ShapeType, "render")) {
        @compileError(@typeName(ShapeType) ++ " must have a render function");
    }

    const Wrapper = struct {
        pub fn render(self: *anyopaque, px: i32, py: i32) void {
            const shapeData: *ShapeType = @alignCast(@ptrCast(self));
            shapeData.render(px, py);
        }
    };

    const data = try alloc.create(@TypeOf(shape));
    data.* = shape;

    return This{
        .x = x,
        .y = y,
        .alloc = alloc,
        .data = data,
        .renderFn = &Wrapper.render,
    };
}

pub fn render(self: This) void {
    self.renderFn(self.data, self.x, self.y);
}

pub fn deinit(self: This) void {
    self.alloc.destroy(self.data);
}
