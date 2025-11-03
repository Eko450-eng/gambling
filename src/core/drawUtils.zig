const std = @import("std");
const doctorsandman = @import("doctorsandman");
const rl = @import("raylib");

pub const ScaleInfo = struct { scale: f32, offset_x: f32, offset_y: f32 };

pub fn loadTextures(texture: [:0]const u8) !rl.Texture {
    const BookImage = try rl.loadImage(texture);
    const BookTexture = try rl.loadTextureFromImage(BookImage);
    rl.unloadImage(BookImage);
    return BookTexture;
}

pub fn drawScaledBackground(image: rl.Texture) ScaleInfo {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const image_width = @as(f32, @floatFromInt(image.width));
    const image_height = @as(f32, @floatFromInt(image.height));

    const scale_x: f32 = screen_width / image_width;
    const scale_y: f32 = screen_height / image_height;
    const scale: f32 = @min(scale_x, scale_y);

    const new_width = image_width * scale;
    const new_height = image_height * scale;

    const pos_x = (screen_width - new_width) / 2;
    const pos_y = (screen_height - new_height) / 2;

    rl.drawTexturePro(
        image,
        rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = image_width,
            .height = image_height,
        },
        rl.Rectangle{
            .x = pos_x,
            .y = pos_y,
            .width = new_width,
            .height = new_height,
        },
        rl.Vector2{ .x = 0, .y = 0 },
        0,
        rl.Color.white,
    );

    return .{ .scale = scale, .offset_x = pos_x, .offset_y = pos_y };
}

pub const TextPosInfo = struct {
    x: f32,
    y: f32,
    font_size: f32,
};

pub fn drawScaledText(original_x: f32, original_y: f32, original_font_size: i32, scale_info: ScaleInfo) TextPosInfo {
    const scaled_x = original_x * scale_info.scale + scale_info.offset_x;
    const scaled_y = original_y * scale_info.scale + scale_info.offset_y;
    const scaled_font_size = @as(f32, @floatFromInt(original_font_size)) * scale_info.scale;

    return TextPosInfo{
        .x = scaled_x,
        .y = scaled_y,
        .font_size = scaled_font_size,
    };
}

pub fn centerWindow() void {
    const monitor_width = rl.getMonitorWidth(0);
    const monitor_height = rl.getMonitorHeight(0);
    const window_width = rl.getScreenWidth();
    const window_height = rl.getScreenHeight();

    const x = (monitor_width - window_width) / 2;
    const y = (monitor_height - window_height) / 2;

    rl.setWindowPosition(x, y);
}
