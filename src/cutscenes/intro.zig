const std = @import("std");
const doctorsandman = @import("doctorsandman");
const rl = @import("raylib");
const Player = @import("../core/player.zig").Player;
const SlotMachineReworked = @import("../core/slotMachineReworked.zig").SlotMachine;
const Translations = @import("../core/translations/game_text.zig");
const GameState = @import("../main.zig").GameState;
const DrawUtils = @import("../core/drawUtils.zig");

const FONT_SIZE: i32 = 26;
const DarkenBackgroundColor = rl.Color{ .a = 200, .b = 0, .g = 0, .r = 0 };
const FADE_TIME: f32 = 255.0;
const MAX_DIALOG: i32 = 6;

pub const IntroCS = struct {
    allocator: std.mem.Allocator,
    bookTexture: rl.Texture,
    SleepingDetectiveTexture: rl.Texture,
    SittingDetectiveTexture: rl.Texture,

    fadeTimeBg: f32,
    fadeTimeText: f32,
    transitionTime: f32,
    pause: bool,

    pub fn init() !IntroCS {
        const BookTexture = try DrawUtils.loadTextures("assets/BookOpened.png");
        const SittingDetectiveTexture = try DrawUtils.loadTextures("assets/SittingDetective.png");
        const SleepingDetectiveTexture = try DrawUtils.loadTextures("assets/SleepingDetective.png");
        const allocator = std.heap.page_allocator;

        return IntroCS{
            .allocator = allocator,
            .bookTexture = BookTexture,
            .SleepingDetectiveTexture = SleepingDetectiveTexture,
            .SittingDetectiveTexture = SittingDetectiveTexture,
            .fadeTimeBg = FADE_TIME,
            .fadeTimeText = 0,
            .transitionTime = 0,
            .pause = false,
        };
    }

    pub fn draw(self: *IntroCS, gameState: *GameState, detectiveFont: rl.Font, doctorFont: rl.Font, normalFont: rl.Font) !void {
        const language = "en";
        var translator = Translations.Translator.init(language);

        const currentScreenWidth = rl.getScreenWidth();
        const scaleFactor = @as(f32, @floatFromInt(currentScreenWidth)) / 1147.0;
        var scaledFontSize = FONT_SIZE * scaleFactor;

        if (scaledFontSize < 16) {
            scaledFontSize = 16;
        }

        var scale_info: DrawUtils.ScaleInfo = undefined;
        scale_info = DrawUtils.drawScaledBackground(self.bookTexture);

        switch (gameState.viewState) {
            .load => {
                _ = DrawUtils.drawScaledBackground(self.SleepingDetectiveTexture);
                rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), DarkenBackgroundColor);
                const textScaleInfo = DrawUtils.drawScaledText(138.0, 66.0, FONT_SIZE, scale_info);
                const startText = "Good morning Detective\nHit enter to wake up";
                const text_size = rl.measureTextEx(detectiveFont, startText, textScaleInfo.font_size, 2);
                const x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2 - text_size.x / 2;
                const y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2 - text_size.y / 2;
                if (gameState.dialog == 6) {
                    rl.drawTextEx(doctorFont, startText, .{ .x = x, .y = y }, textScaleInfo.font_size, 2, .white);
                }
                // TODO: Replace with another font
                rl.drawTextEx(normalFont, startText, .{ .x = x, .y = y }, textScaleInfo.font_size, 2, .white);

                if (rl.isKeyPressed(.enter)) {
                    gameState.viewState = .book;
                    self.transitionTime = 255;
                }
            },
            .book => {
                _ = DrawUtils.drawScaledBackground(self.SittingDetectiveTexture);
                rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), DarkenBackgroundColor);
                var dialogTextList: std.ArrayListUnmanaged(u8) = .{};
                defer dialogTextList.deinit(self.allocator);

                for ("cutSceneIntro") |c| {
                    try dialogTextList.append(self.allocator, c);
                }
                const currentDialogCount: u8 = @intCast(gameState.dialog);
                try dialogTextList.append(self.allocator, '0' + currentDialogCount);

                const dialogText = dialogTextList.items;
                const text: [:0]const u8 = translator.translate(dialogText);

                const textScaleInfo = DrawUtils.drawScaledText(138.0, 66.0, FONT_SIZE, scale_info);
                const textColor = rl.Color{ .a = @as(u8, @intFromFloat(self.fadeTimeText)), .b = 255, .g = 255, .r = 255 };
                rl.drawTextEx(detectiveFont, text, .{ .x = textScaleInfo.x, .y = textScaleInfo.y }, textScaleInfo.font_size, 2, textColor);
                if (self.fadeTimeText < 253) {
                    self.fadeTimeText += 1.0;
                }

                if (rl.isKeyPressed(.enter)) {
                    self.fadeTimeBg = FADE_TIME;
                    self.fadeTimeText = 255;
                    if (gameState.dialog < MAX_DIALOG) {
                        gameState.dialog += 1;
                    } else {
                        gameState.viewState = .main;
                    }
                }

                if (self.fadeTimeBg > 0) {
                    const bg = rl.Color{ .a = @as(u8, @intFromFloat(self.fadeTimeBg)), .b = 0, .g = 0, .r = 0 };
                    rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), bg);
                    self.fadeTimeBg -= 1.0;
                }

                if (rl.isKeyPressed(.tab)) {
                    if (gameState.viewState == .book) {
                        gameState.viewState = .main;
                    } else gameState.viewState = .book;
                }
            },
            else => {},
        }
    }
};
