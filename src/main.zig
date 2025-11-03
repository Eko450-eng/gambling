const std = @import("std");
const doctorsandman = @import("doctorsandman");
const rl = @import("raylib");
const Player = @import("core/player.zig").Player;
const SlotMachineReworked = @import("core/slotMachineReworked.zig").SlotMachine;
const Translations = @import("core/translations/game_text.zig");
const IntroCutScene = @import("cutscenes/intro.zig").IntroCS;

const Views = enum(i8) {
    load = 1,
    gambling = 2,
    main = 3,
    book = 4,
};

pub const GameState = struct {
    viewState: Views,
    dialog: i32,
};

const LanguageState = struct {
    language: []const u8,
};

pub fn main() !void {
    const language = "en";
    var translator = Translations.Translator.init(language);

    rl.initWindow(1147, 777, translator.translate("title"));
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var introCutScene: IntroCutScene = try IntroCutScene.init();
    var gameState = GameState{ .viewState = Views.load, .dialog = 1 };

    const font_detective = try rl.loadFontEx("assets/detective.ttf", 26, null);
    defer rl.unloadFont(font_detective);

    const font_doctor = try rl.loadFontEx("assets/doctor.ttf", 26, null);
    defer rl.unloadFont(font_doctor);

    const font_normal = try rl.loadFontEx("assets/Ignotum-Regular.ttf", 26, null);
    defer rl.unloadFont(font_doctor);

    rl.initAudioDevice(); // Initialize audio device
    defer rl.closeAudioDevice(); // Close audio device (music streaming is automatically stopped)

    const music: rl.Music = try rl.loadMusicStream("assets/intro_melancholy_melody.mp3");
    defer rl.unloadMusicStream(music); // Unload music stream buffers from RAM

    rl.playMusicStream(music);

    var timePlayed: f32 = 0; // Time played normalized [0.0f..1.0f]
    var pause: bool = false; // Music playing paused

    while (!rl.windowShouldClose()) {
        rl.updateMusicStream(music); // Update music buffer with new stream data

        // Restart music playing (stop and play)
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

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        try introCutScene.draw(&gameState, font_detective, font_doctor, font_normal);
    }
}
