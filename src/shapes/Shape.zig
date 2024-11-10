const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const RenderFn = fn (*anyopaque, i32, i32, raylib.Color) void;
const DeinitFn = fn (*anyopaque, std.mem.Allocator) void;

x: i32,
y: i32,
color: raylib.Color,
alloc: std.mem.Allocator,
data: *anyopaque,
renderFn: *const RenderFn,
deinitFn: *const DeinitFn,

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
        pub fn render(self: *anyopaque, px: i32, py: i32, color: raylib.Color) void {
            const shapeData: *ShapeType = @alignCast(@ptrCast(self));
            shapeData.render(px, py, color);
        }
        pub fn deinit(self: *anyopaque, allocator: std.mem.Allocator) void {
            const shapeData: *ShapeType = @alignCast(@ptrCast(self));
            if (@hasDecl(ShapeType, "deinit")) {
                shapeData.deinit(allocator);
            }
            allocator.destroy(shapeData);
        }
    };

    const data = try alloc.create(@TypeOf(shape));
    data.* = shape;

    return This{
        .x = x,
        .y = y,
        .color = raylib.Color.white,
        .alloc = alloc,
        .data = data,
        .renderFn = &Wrapper.render,
        .deinitFn = &Wrapper.deinit,
    };
}

pub fn render(self: This) void {
    self.renderFn(self.data, self.x, self.y, self.color);
}

pub fn renderColored(self: This, color: raylib.Color) void {
    self.renderFn(self.data, self.x, self.y, color);
}

pub fn deinit(self: This) void {
    self.deinitFn(self.data, self.alloc);
}
