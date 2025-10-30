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

const WinRow = struct {
    count: i32,
    colors: [5]rl.Color,
};

const WinDia = struct {
    count: [2]i32,
    colors: [3][5]rl.Color,
};

const Symbols = struct {
    symbol: u8,
    hitChance: i32,
    price: i32,
    multiplier: i32,
    icon: Vec2,
    // effect: ?,
};

pub const SlotMachine = struct {
    lines: usize,
    rows: usize,
    symbols: [7]Symbols,
    output: [3][5]u8,
    winningRows: [5][5]i32,
    ready: bool,
    paidOut: bool,
    playInput: u32,
    winSum: i32,

    pub fn init(lines: usize) !SlotMachine {
        const symbols: [7]Symbols = [_]Symbols{
            Symbols{ .symbol = '1', .hitChance = 1, .multiplier = 1, .price = 1, .icon = Vec2{ .x = 0, .y = 341 } },
            Symbols{ .symbol = '2', .hitChance = 1, .multiplier = 1, .price = 1, .icon = Vec2{ .x = 682, .y = 341 } },
            Symbols{ .symbol = '3', .hitChance = 1, .multiplier = 1, .price = 2, .icon = Vec2{ .x = 0, .y = 682 } },
            Symbols{ .symbol = '4', .hitChance = 1, .multiplier = 1, .price = 2, .icon = Vec2{ .x = 341, .y = 682 } },
            Symbols{ .symbol = '5', .hitChance = 1, .multiplier = 1, .price = 2, .icon = Vec2{ .x = 341, .y = 0 } },
            Symbols{ .symbol = '6', .hitChance = 1, .multiplier = 1, .price = 3, .icon = Vec2{ .x = 682, .y = 682 } },
            Symbols{ .symbol = '7', .hitChance = 1, .multiplier = 1, .price = 4, .icon = Vec2{ .x = 341, .y = 341 } },
        };

        return .{
            .lines = lines,
            .rows = 5,
            .symbols = symbols,
            .output = undefined,
            .ready = false,
            .winningRows = undefined,
            .playInput = 0,
            .paidOut = false,
            .winSum = 0,
        };
    }

    pub fn action(machine: *SlotMachine, player: *Player, input: u32) !void {
        if (player.coins - input <= 0) return;
        machine.paidOut = false;
        player.coins -= input;

        text_display_timer = LINGER_DURATION;

        machine.playInput = input;
        var prng = std.Random.DefaultPrng.init(@as(u64, @intCast(std.time.nanoTimestamp())));

        for (0..3) |row_index| {
            for (0..5) |col_index| {
                const idx = prng.random().intRangeLessThan(usize, 0, 6);
                const value = machine.symbols[idx];
                machine.output[row_index][col_index] = value.symbol;
            }
        }
    }

    /// Checks if a row contains a winning count of symbols
    fn checkWinningRow(ma: *SlotMachine, row: [5]u8) WinRow {
        var winRowCount: i32 = 0;

        var winRowColor: [5]rl.Color = [5]rl.Color{ NeutralColor, NeutralColor, NeutralColor, NeutralColor, NeutralColor };

        for (0..row.len) |i| {
            if (i < 4) {
                if (row[i] == row[i + 1]) {
                    const curElement = row[i];
                    for (ma.symbols) |symbol| {
                        if (curElement == symbol.symbol) {
                            winRowCount += ma.getPrice(row[i], 1, ma.playInput);
                        }
                    }
                    if (winRowCount > 0) winRowColor[i + 1] = WinColor;
                    winRowColor[i] = WinColor;
                } else break;
            }
        }
        return WinRow{
            .count = winRowCount,
            .colors = winRowColor,
        };
    }

    fn getPrice(ma: *SlotMachine, item: u8, comboMultiplier: i32, invest: u32) i32 {
        var winSum: i32 = 0;
        const input: i32 = @intCast(invest);

        for (ma.symbols) |symbol| {
            if (item == symbol.symbol) {
                winSum += (symbol.price * input) * (symbol.multiplier * comboMultiplier);
                winSum += symbol.price * symbol.multiplier;
            }
        }

        return winSum;
    }

    fn checkWinningDiag(ma: *SlotMachine, items: [3][5]u8) WinDia {
        var winRowCount: [2]i32 = [2]i32{ 0, 0 };
        var winRowColor: [3][5]rl.Color = [3][5]rl.Color{
            .{ NeutralColor, NeutralColor, NeutralColor, NeutralColor, NeutralColor },
            .{ NeutralColor, NeutralColor, NeutralColor, NeutralColor, NeutralColor },
            .{ NeutralColor, NeutralColor, NeutralColor, NeutralColor, NeutralColor },
        };

        if (items[0][0] == items[1][1]) {
            const winningItem = items[0][0];
            winRowColor[0][0] = WinColor;
            winRowColor[1][1] = WinColor;
            winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
            if (items[1][1] == items[2][2]) {
                winRowCount[0] += 1;
                winRowColor[2][2] = WinColor;
                winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                if (items[2][2] == items[1][3]) {
                    winRowCount[0] += 1;
                    winRowColor[1][3] = WinColor;
                    winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                    if (items[1][3] == items[0][4]) {
                        winRowCount[0] += 1;
                        winRowColor[0][4] = WinColor;
                        winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                    }
                }
            }
        }

        if (items[2][0] == items[1][1]) {
            const winningItem = items[2][0];
            winRowCount[1] += 1;
            winRowColor[2][0] = WinColor;
            winRowColor[1][1] = WinColor;
            winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
            if (items[1][1] == items[0][2]) {
                winRowCount[1] += 1;
                winRowColor[0][2] = WinColor;
                winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                if (items[0][2] == items[1][3]) {
                    winRowCount[1] += 1;
                    winRowColor[1][3] = WinColor;
                    winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                    if (items[1][3] == items[2][4]) {
                        winRowCount[1] += 1;
                        winRowColor[2][4] = WinColor;
                        winRowCount[0] += ma.getPrice(winningItem, 1, ma.playInput);
                    }
                }
            }
        }

        return WinDia{
            .count = winRowCount,
            .colors = winRowColor,
        };
    }

    fn color_eq(a: rl.Color, b: rl.Color) bool {
        return a.r == b.r and
            a.g == b.g and
            a.b == b.b and
            a.a == b.a;
    }

    /// Checks for all winning lines and pays out to the player
    fn checkWinningLines(ma: *SlotMachine, player: *Player) ![3][5]rl.Color {
        var colors: [3][5]rl.Color = undefined;

        const rowTop = ma.output[0];
        const rowMid = ma.output[1];
        const rowBot = ma.output[2];

        const winTop = ma.checkWinningRow(rowTop);
        const winMid = ma.checkWinningRow(rowMid);
        const winBot = ma.checkWinningRow(rowBot);

        colors[0] = winTop.colors;
        colors[1] = winMid.colors;
        colors[2] = winBot.colors;
        const colorsDia: WinDia = ma.checkWinningDiag(ma.output);

        var winSum: i32 = 0;
        for (colorsDia.count) |counts| {
            winSum += counts;
        }

        winSum += winTop.count;
        winSum += winMid.count;
        winSum += winBot.count;

        for (colorsDia.colors, 0..) |row, rowIndex| {
            for (row, 0..) |item, itemIndex| {
                if (color_eq(item, rl.Color.blue) or color_eq(colors[rowIndex][itemIndex], rl.Color.blue)) {
                    colors[rowIndex][itemIndex] = rl.Color.blue;
                }
            }
        }

        if (!ma.paidOut) {
            ma.winSum = winSum;
            player.coins += @intCast(winSum);
        }
        ma.paidOut = true;
        return colors;
    }

    pub fn draw(machine: *SlotMachine, player: *Player, rawWidth: i32, rawHeight: i32, FieldTexture: rl.Texture, IconTextures: rl.Texture) !void {
        var text_buf: [64]u8 = undefined;
        const colorsArray: [3][5]rl.Color = try machine.checkWinningLines(player);

        const widthFloatRaw: f32 = @floatFromInt(rawWidth);
        const heightFloatRaw: f32 = @floatFromInt(rawHeight);

        const widthFloat: f32 = widthFloatRaw * 0.2;
        const heightFloat: f32 = heightFloatRaw * 0.3;

        const init_pos = Vec2{ .x = widthFloat, .y = heightFloat };
        var pos = init_pos;

        for (machine.output, 0..) |row, rowIndex| {
            const rowIndexPos = rowIndex + 1;
            const rowIndexFloat: f32 = @floatFromInt(rowIndexPos);
            pos.y = heightFloatRaw * (0.15 * rowIndexFloat);

            const colors = colorsArray[rowIndex];

            for (row, 0..) |out, itemIndex| {
                const itemIndexPos = itemIndex + 1;
                const itemIndexFloat: f32 = @floatFromInt(itemIndexPos);
                pos.x = widthFloatRaw * (0.15 * itemIndexFloat);
                const text = std.fmt.bufPrintZ(&text_buf, "{c}", .{out}) catch "";

                const iconPos: Vec2 = getIcon(out);
                const rec = rl.Rectangle.init(iconPos.x, iconPos.y, 342, 342);

                const iconSize = 1024 * 0.08;
                const dest = rl.Rectangle.init(pos.x, pos.y, iconSize, iconSize);
                const origin = Vec2{ .x = 0, .y = 0 };

                rl.drawTexturePro(IconTextures, rec, dest, origin, 0, .white);

                if (rl.isKeyDown(.s)) {
                    const font_margin: i32 = @divFloor(FONT_SIZE, 2);
                    const x_int: i32 = @intFromFloat(pos.x);
                    const y_int: i32 = @intFromFloat(pos.y);
                    rl.drawText(text, x_int + font_margin, y_int + font_margin, FONT_SIZE, .white);
                }
                rl.drawTextureEx(FieldTexture, pos, 0.0, 0.08, colors[itemIndex]);
            }
        }

        if (text_display_timer > 0.0 and machine.winSum > 0) {
            player.lastWin = machine.winSum;
            const x = @divFloor(rl.getScreenWidth(), 2) - @divExact(FONT_SIZE, 2);
            const y = @divFloor(rl.getScreenHeight(), 2);
            rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.colorAlpha(.black, 0.7));
            rl.drawText(rl.textFormat("%02i", .{machine.winSum}), x, y, FONT_SIZE, WinColor);
            text_display_timer -= rl.getFrameTime();
        }

        var coinColor = rl.Color.green;

        if (player.coins > 1000) {
            coinColor = rl.Color.gold;
        } else if (player.coins >= 100) {
            coinColor = rl.Color.green;
        } else if (player.coins <= 10) {
            coinColor = rl.Color.red;
        }

        if (player.lastWin > 0) rl.drawText(rl.textFormat("Last win: %02u", .{player.lastWin}), 10, rl.getScreenHeight() - 60, 30, coinColor);
        rl.drawText(rl.textFormat("Coins: %02u", .{player.coins}), 10, rl.getScreenHeight() - 30, 30, coinColor);
    }

    fn getIcon(char: u8) Vec2 {
        var pos: Vec2 = Vec2{ .x = 0, .y = 0 };

        switch (char) {
            '1' => pos = Vec2{ .x = 0, .y = 341 },
            '2' => pos = Vec2{ .x = 682, .y = 341 },
            '3' => pos = Vec2{ .x = 0, .y = 682 },
            '4' => pos = Vec2{ .x = 341, .y = 682 },
            '5' => pos = Vec2{ .x = 341, .y = 0 },
            '6' => pos = Vec2{ .x = 682, .y = 682 },
            '7' => pos = Vec2{ .x = 341, .y = 341 },
            else => pos = Vec2{ .x = 0, .y = 0 },
        }

        return pos;
    }
};
