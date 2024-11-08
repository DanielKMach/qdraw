const std = @import("std");
const raylib = @import("raylib");

const Square = @import("shapes/Square.zig");
const Shape = @import("shapes/Shape.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    const allocator = std.heap.page_allocator;
    const square = Square.init(100, 100);
    const squareShape = try Shape.init(square, 100, 100, allocator);
    defer squareShape.deinit();

    raylib.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer raylib.closeWindow();

    raylib.setTargetFPS(60);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.black);

        squareShape.render();
    }
}
