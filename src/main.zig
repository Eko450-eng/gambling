const std = @import("std");
const gambling = @import("gambling");
const rl = @import("raylib");
const Player = @import("core/player.zig").Player;
const SlotMachineReworked = @import("core/slotMachineReworked.zig").SlotMachine;
const Translations = @import("core/translations/game_text.zig");

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

pub const INTEREST: f32 = 1.6;
pub const INTEREST_DAYS: i32 = 3;

pub const FONT_SIZE: i32 = 50;

pub const WinColor = rl.Color.gold;
pub const LooseColor = rl.Color.white;
pub const NeutralColor = rl.Color.white;

const CONFIG_PATH = std.fs.path.basename("/home/eko/.config/gambling/config.json");

const Views = enum(i8) {
    load = 1,
    gambling = 2,
    main = 3,
};

const GameState = struct {
    viewState: Views,
};

const LanguageState = struct {
    language: []const u8,
};

fn create_config(language: []const u8) !void {
    const file = try std.fs.cwd().createFile(CONFIG_PATH, .{});
    defer file.close();
    _ = try file.write(language);
}

fn setup_game() ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile(CONFIG_PATH, .{});
    defer file.close();

    // Read entire file into allocated memory
    return try file.readToEndAlloc(allocator, 1024 * 100);
}

pub fn main() !void {
    const language = try setup_game();

    var translator = Translations.Translator.init(language);

    rl.initWindow(1280, 720, translator.translate("title"));
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var gameState = GameState{ .viewState = Views.load };

    var slotMachineReworked = SlotMachineReworked.init(10);
    var player = Player.init(100);

    const FieldImage = try rl.loadImage("assets/tile.png");
    const FieldTexture = try rl.loadTextureFromImage(FieldImage);
    rl.unloadImage(FieldImage);

    const IconImages = try rl.loadImage("assets/iconsnew.png");
    const IconTextures = try rl.loadTextureFromImage(IconImages);
    rl.unloadImage(IconImages);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        switch (gameState.viewState) {
            .load => {
                if (rl.isKeyPressed(.e)) {
                    try create_config("en");
                    rl.closeWindow();
                }
                if (rl.isKeyPressed(.d)) {
                    try create_config("de");
                    rl.closeWindow();
                }
                const text = translator.translate("pressSpaceToStart");
                const fontSize = 30;
                const textWidth = rl.measureText(text, fontSize);
                rl.drawText(text, @divTrunc(rl.getScreenWidth() - textWidth, 2), @divFloor(rl.getScreenHeight(), 2), 30, .white);
                if (rl.isKeyPressed(.space)) {
                    gameState.viewState = .gambling;
                }
                if (rl.isKeyPressed(.enter)) gameState.viewState = .main;
            },
            .gambling => {
                if (rl.isKeyPressed(.space)) slotMachineReworked.action(&player, 10);
                slotMachineReworked.draw(FieldTexture, IconTextures);
                player.drawGambling(&translator);
            },
            .main => {
                try player.move();
                try player.draw();
            },
        }
    }
}
