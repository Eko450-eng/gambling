const std = @import("std");
const rl = @import("raylib");
const Player = @import("player.zig").Player;
const Vec2 = rl.Vector2;

const FONT_SIZE: i32 = 50;
const WinColor = rl.Color.gold;
const LooseColor = rl.Color.white;
const NeutralColor = rl.Color.white;

var text_display_timer: f32 = 0.0;
const LINGER_DURATION: f32 = 1.0;

const Symbol = struct {
    id: i32,
    priceList: [5]f32,
    color: rl.Color,
    iconPos: Vec2,
};

const SymbolList = struct {
    symbols: [3][5]Symbol,

    pub fn checkWinStraight(sl: *SymbolList) f32 {
        var winnings: f32 = 0.0;
        for (sl.symbols) |row| {
            var currStreak: i32 = 0;
            var symbol: Symbol = undefined;
            if (row[0].id == row[1].id) {
                currStreak += 1;
                symbol = row[0];
                if (row[1].id == row[2].id) {
                    currStreak += 1;
                    if (row[2].id == row[3].id) {
                        currStreak += 1;
                        if (row[3].id == row[4].id) currStreak += 1;
                    }
                }
            }

            const cs: usize = @intCast(currStreak);
            winnings += symbol.priceList[cs];
        }
        return winnings;
    }

    pub fn init() SymbolList {
        var result: [3][5]Symbol = undefined;
        const ten: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 0, .y = 341 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 2.5, 10.0 } };
        const joker: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 682, .y = 341 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 2.5, 10.0 } };
        const king: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 0, .y = 682 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 4.0, 15.0 } };
        const ace: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 0, .y = 682 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 4.0, 15.0 } };
        const scarab: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 341, .y = 0 }, .priceList = [5]f32{ 0.0, 0.5, 3.0, 10.0, 75.0 } };
        const eye: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 341, .y = 341 }, .priceList = [5]f32{ 0.0, 0.5, 3.0, 10.0, 75.0 } };
        const ra: Symbol = Symbol{ .id = 1, .color = NeutralColor, .iconPos = Vec2{ .x = 682, .y = 682 }, .priceList = [5]f32{ 0.0, 0.5, 4.0, 40.0, 200.0 } };
        const symbols: [7]Symbol = [7]Symbol{ ten, joker, king, ace, scarab, eye, ra };

        var prng = std.Random.DefaultPrng.init(@as(u64, @intCast(std.time.nanoTimestamp())));

        for (0..3) |row_index| {
            for (0..5) |col_index| {
                const idx = prng.random().intRangeLessThan(usize, 0, 6);
                const value = symbols[idx];
                result[row_index][col_index] = value;
            }
        }

        return SymbolList{ .symbols = result };
    }
};

pub const SlotMachine = struct {
    paidOut: bool,
    playInput: u32,
    symbolList: SymbolList,
    screen: [3][5]Symbol,

    pub fn init(input: u32) SlotMachine {
        const sl = SymbolList.init();
        return SlotMachine{
            .paidOut = false,
            .playInput = input,
            .symbolList = sl,
            .screen = sl.symbols,
        };
    }

    pub fn action(machine: *SlotMachine, player: *Player, input: u32) void {
        if (player.coins - input <= 0) return;
        machine.paidOut = false;
        player.coins -= input;

        text_display_timer = LINGER_DURATION;

        machine.playInput = input;
        const sl = SymbolList.init();
        machine.screen = sl.symbols;
        machine.symbolList = sl;
        const wins = machine.symbolList.checkWinStraight();
        if (wins > 0) {
            rl.drawText(rl.textFormat("Won: %02.02f", .{wins}), 0, 0, 50, .white);
        }
    }

    pub fn draw(machine: *SlotMachine, FieldTexture: rl.Texture, IconTextures: rl.Texture) void {
        const widthFloatRaw: f32 = @floatFromInt(rl.getScreenWidth());
        const heightFloatRaw: f32 = @floatFromInt(rl.getScreenHeight());

        const widthFloat: f32 = widthFloatRaw * 0.2;
        const heightFloat: f32 = heightFloatRaw * 0.3;

        const init_pos = Vec2{ .x = widthFloat, .y = heightFloat };
        var pos = init_pos;

        for (machine.screen, 0..) |row, rowIndex| {
            const rowIndexPos = rowIndex + 1;
            const rowIndexFloat: f32 = @floatFromInt(rowIndexPos);
            pos.y = heightFloatRaw * (0.15 * rowIndexFloat);

            for (row, 0..) |out, itemIndex| {
                const itemIndexPos = itemIndex + 1;
                const itemIndexFloat: f32 = @floatFromInt(itemIndexPos);
                pos.x = widthFloatRaw * (0.15 * itemIndexFloat);

                const rec = rl.Rectangle.init(out.iconPos.x, out.iconPos.y, 342, 342);

                const iconSize = 1024 * 0.08;
                const dest = rl.Rectangle.init(pos.x, pos.y, iconSize, iconSize);
                const origin = Vec2{ .x = 0, .y = 0 };

                rl.drawTexturePro(IconTextures, rec, dest, origin, 0, .white);
                rl.drawTextureEx(FieldTexture, pos, 0.0, 0.08, .white);
            }
        }
    }
};
