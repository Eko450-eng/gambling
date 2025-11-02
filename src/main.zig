const std = @import("std");
const doctorsandman = @import("doctorsandman");
const rl = @import("raylib");
const Player = @import("core/player.zig").Player;
const SlotMachineReworked = @import("core/slotMachineReworked.zig").SlotMachine;
const Translations = @import("core/translations/game_text.zig");

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

pub const INTEREST: f32 = 1.6;
pub const INTEREST_DAYS: i32 = 3;

pub const FONT_SIZE: i32 = 26;
pub const IMAGE_SIZE: i32 = 1147;

pub const WinColor = rl.Color.gold;
pub const LooseColor = rl.Color.white;
pub const NeutralColor = rl.Color.white;
pub const DarkenBackgroundColor = rl.Color{ .a = 200, .b = 0, .g = 0, .r = 0 };

const FADE_TIME: f32 = 255.0;

const CONFIG_PATH = std.fs.path.basename("/home/eko/.config/doctorsandman/config.json");

const Views = enum(i8) {
    load = 1,
    gambling = 2,
    main = 3,
    book = 4,
};

const GameState = struct {
    viewState: Views,
    dialog: i32,
};

const LanguageState = struct {
    language: []const u8,
};

fn create_config(language: []const u8) !void {
    const file = try std.fs.cwd().createFile(CONFIG_PATH, .{});
    defer file.close();
    _ = try file.write(language);
}

// fn setup_game() []u8 {
//     // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     // defer _ = gpa.deinit();
//     // const allocator = gpa.allocator();
//     //
//     // const file = try std.fs.cwd().openFile(CONFIG_PATH, .{});
//     // defer file.close();
//
//     // Read entire file into allocated memory
//     // return try file.readToEndAlloc(allocator, 1024 * 100);
//     return "en";
// }

pub fn main() !void {
    // const language = setup_game();
    const language = "en";

    var translator = Translations.Translator.init(language);

    rl.initWindow(1147, 777, translator.translate("title"));
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var gameState = GameState{ .viewState = Views.load, .dialog = 0 };

    rl.initAudioDevice(); // Initialize audio device
    defer rl.closeAudioDevice(); // Close audio device (music streaming is automatically stopped)

    const music: rl.Music = try rl.loadMusicStream("assets/intro_melancholy_melody.mp3");
    defer rl.unloadMusicStream(music); // Unload music stream buffers from RAM

    rl.playMusicStream(music);

    var timePlayed: f32 = 0; // Time played normalized [0.0f..1.0f]
    var fadeTime: f32 = FADE_TIME; // Time played normalized [0.0f..1.0f]
    var pause: bool = false; // Music playing paused

    // var slotMachineReworked = SlotMachineReworked.init(10);
    // var player = Player.init(100);

    // const FieldImage = try rl.loadImage("assets/tile.png");
    // const FieldTexture = try rl.loadTextureFromImage(FieldImage);
    // rl.unloadImage(FieldImage);
    //
    // const IconImages = try rl.loadImage("assets/iconsnew.png");
    // const IconTextures = try rl.loadTextureFromImage(IconImages);
    // rl.unloadImage(IconImages);

    const BookImage = try rl.loadImage("assets/BookOpened.png");
    const BookTexture = try rl.loadTextureFromImage(BookImage);
    rl.unloadImage(BookImage);

    const SittingDetectiveImage = try rl.loadImage("assets/SittingDetective.png");
    const SittingDetectiveTexture = try rl.loadTextureFromImage(SittingDetectiveImage);
    rl.unloadImage(SittingDetectiveImage);

    const font_ttf = try rl.loadFontEx("assets/handWritten.ttf", 26, null);
    defer rl.unloadFont(font_ttf);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        rl.updateMusicStream(music); // Update music buffer with new stream data
        if (rl.isKeyPressed(.space)) {
            rl.stopMusicStream(music);
            rl.playMusicStream(music);
        }

        // Pause/Resume music playing
        if (rl.isKeyPressed(.p)) {
            pause = !pause;

            if (pause) {
                rl.pauseMusicStream(music);
            } else {
                rl.resumeMusicStream(music);
            }
        }

        // Get normalized time played for current music stream
        timePlayed = rl.getMusicTimePlayed(music) / rl.getMusicTimeLength(music);

        if (timePlayed > 1.0) {
            timePlayed = 1.0; // Make sure time played is no longer than music
        }

        //          ╭─────────────────────────────────────────────────────────╮
        //          │                         Scaling                         │
        //          ╰─────────────────────────────────────────────────────────╯
        const currentScreenWidth = rl.getScreenWidth();
        const scaleFactor = @as(f32, @floatFromInt(currentScreenWidth)) / 1147.0;
        var scaledFontSize = FONT_SIZE * scaleFactor;

        if (scaledFontSize < 16) {
            scaledFontSize = 16;
        }

        var scale_info: ScaleInfo = undefined;
        scale_info = drawScaledBackground(BookTexture);
        _ = drawScaledBackground(SittingDetectiveTexture);

        var text: [:0]const u8 = undefined;

        switch (gameState.viewState) {
            .load => {
                rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), DarkenBackgroundColor);
                const textScaleInfo = drawScaledText(138.0, 66.0, FONT_SIZE, scale_info);
                const startText = "Good morning Detective\nHit enter to wake up";
                const text_size = rl.measureTextEx(font_ttf, startText, textScaleInfo.font_size, 2);
                const x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2 - text_size.x / 2;
                const y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2 - text_size.y / 2;
                rl.drawTextEx(font_ttf, startText, .{ .x = x, .y = y }, textScaleInfo.font_size, 2, .white);

                if (rl.isKeyPressed(.enter)) gameState.viewState = .book;

                if (rl.isKeyPressed(.e)) {
                    try create_config("en");
                    rl.closeWindow();
                }
                if (rl.isKeyPressed(.d)) {
                    try create_config("de");
                    rl.closeWindow();
                }
                // const text = translator.translate("pressSpaceToStart");
                // const fontSize = 30;
                // const textWidth = rl.measureText(text, fontSize);
                // rl.drawText(text, @divTrunc(rl.getScreenWidth() - textWidth, 2), @divFloor(rl.getScreenHeight(), 2), 30, .white);
                // if (rl.isKeyPressed(.space)) {
                //     gameState.viewState = .gambling;
                // }
                // if (rl.isKeyPressed(.enter)) gameState.viewState = .main;
            },
            .gambling => {
                // if (rl.isKeyPressed(.space)) slotMachineReworked.action(&player, 10);
                // slotMachineReworked.draw(FieldTexture, IconTextures);
                // player.drawGambling(&translator);
            },
            .main => {},
            .book => {
                _ = drawScaledBackground(SittingDetectiveTexture);
                rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), DarkenBackgroundColor);

                switch (gameState.dialog) {
                    1 => text = translator.translate("cutSceneIntro2"),
                    2 => text = translator.translate("cutSceneIntro3"),
                    else => text = translator.translate("cutSceneIntro1"),
                }

                const textScaleInfo = drawScaledText(138.0, 66.0, FONT_SIZE, scale_info);
                rl.drawTextEx(font_ttf, text, .{ .x = textScaleInfo.x, .y = textScaleInfo.y }, textScaleInfo.font_size, 2, .white);

                if (rl.isKeyPressed(.enter)) {
                    fadeTime = FADE_TIME;
                    if (gameState.dialog < 2) {
                        gameState.dialog += 1;
                    } else {
                        gameState.viewState = .main;
                    }
                }

                if (fadeTime > 0) {
                    const bg = rl.Color{ .a = @as(u8, @intFromFloat(fadeTime)), .b = 0, .g = 0, .r = 0 };
                    rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), bg);
                    fadeTime -= 1.0;
                }

                if (rl.isKeyPressed(.tab)) {
                    if (gameState.viewState == .book) {
                        gameState.viewState = .main;
                    } else gameState.viewState = .book;
                }
            },
        }
    }
}
fn centerWindow() void {
    const monitor_width = rl.getMonitorWidth(0);
    const monitor_height = rl.getMonitorHeight(0);
    const window_width = rl.getScreenWidth();
    const window_height = rl.getScreenHeight();

    const x = (monitor_width - window_width) / 2;
    const y = (monitor_height - window_height) / 2;

    rl.setWindowPosition(x, y);
}

const ScaleInfo = struct { scale: f32, offset_x: f32, offset_y: f32 };

fn drawScaledBackground(image: rl.Texture) ScaleInfo {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const image_width = @as(f32, @floatFromInt(image.width));
    const image_height = @as(f32, @floatFromInt(image.height));

    // Calculate scale to fit entire image on screen
    const scale_x: f32 = screen_width / image_width;
    const scale_y: f32 = screen_height / image_height;
    const scale: f32 = @min(scale_x, scale_y);

    // Calculate new dimensions
    const new_width = image_width * scale;
    const new_height = image_height * scale;

    // Center the image
    const pos_x = (screen_width - new_width) / 2;
    const pos_y = (screen_height - new_height) / 2;

    // Draw background
    rl.drawTexturePro(image, rl.Rectangle{ .x = 0, .y = 0, .width = image_width, .height = image_height }, rl.Rectangle{ .x = pos_x, .y = pos_y, .width = new_width, .height = new_height }, rl.Vector2{ .x = 0, .y = 0 }, 0, rl.Color.white);

    return .{ .scale = scale, .offset_x = pos_x, .offset_y = pos_y };
}

const TextPosInfo = struct {
    x: f32,
    y: f32,
    font_size: f32,
};

fn drawScaledText(original_x: f32, original_y: f32, original_font_size: i32, scale_info: ScaleInfo) TextPosInfo {
    const scaled_x = original_x * scale_info.scale + scale_info.offset_x;
    const scaled_y = original_y * scale_info.scale + scale_info.offset_y;
    const scaled_font_size = @as(f32, @floatFromInt(original_font_size)) * scale_info.scale;

    return TextPosInfo{
        .x = scaled_x,
        .y = scaled_y,
        .font_size = scaled_font_size,
    };
}
