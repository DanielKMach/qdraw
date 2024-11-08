const std = @import("std");
const raylib = @import("raylib");

const Square = @import("shapes/Square.zig");
const Shape = @import("shapes/Shape.zig");
const QDraw = @import("QDraw.zig");
const BoxTool = @import("tools/BoxTool.zig");
const ArrowTool = @import("tools/ArrowTool.zig");
const Tool = @import("tools/Tool.zig");

pub fn main() anyerror!void {
    const screenWidth = 1080;
    const screenHeight = 720;

    raylib.setConfigFlags(.{ .window_resizable = true });
    raylib.initWindow(screenWidth, screenHeight, "QDraw");
    defer raylib.closeWindow();

    raylib.setTargetFPS(60);

    const allocator = std.heap.page_allocator;
    var qdraw = try QDraw.init(allocator);
    const box_tool = BoxTool.init(allocator, .key_s, QDraw.Context.init(&qdraw));
    const arrow_tool = ArrowTool.init(allocator, .key_a, QDraw.Context.init(&qdraw));
    try qdraw.tools.append(try Tool.init(box_tool, allocator));
    try qdraw.tools.append(try Tool.init(arrow_tool, allocator));

    while (!raylib.windowShouldClose()) {
        qdraw.tick();

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.init(32, 32, 32, 255));
        qdraw.render();
    }
}
