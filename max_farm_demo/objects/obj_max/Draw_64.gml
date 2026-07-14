// ========== ИНВЕНТАРЬ - ПАНЕЛЬ ВНИЗУ ЭКРАНА ==========

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var panel_h   = 48;
var slot_w    = 72;
var arrow_w   = 24;  // ширина зоны стрелки
var has_diary = variable_global_exists("has_diary") && global.has_diary;
var diary_off = has_diary ? slot_w : 0;

var total_items   = array_length(hotbar_items);
var eff_visible   = min(hotbar_visible, total_items - hotbar_scroll);
var can_left      = hotbar_scroll > 0;
var can_right     = hotbar_scroll + hotbar_visible < total_items;

// Панель чуть шире если есть стрелки (слева/справа от слотов)
var left_pad  = can_left  ? arrow_w : 0;
var right_pad = can_right ? arrow_w : 0;
var panel_w   = diary_off + left_pad + slot_w * eff_visible + right_pad;
var panel_x   = (gui_w - panel_w) / 2;
var panel_y   = gui_h - panel_h - 10;
var cy        = panel_y + panel_h / 2;

// Начало слотов предметов
var ix = panel_x + diary_off + left_pad;

// --- Серая подложка ---
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(40, 40, 40));
draw_roundrect(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_alpha(1);

// --- Рамка ---
draw_set_color(make_color_rgb(80, 80, 80));
draw_roundrect(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// --- Слот дневника ---
if (has_diary) {
    draw_set_alpha(0.35);
    draw_set_color(make_color_rgb(120, 90, 40));
    draw_roundrect_ext(panel_x + 2, panel_y + 2, panel_x + slot_w - 2, panel_y + panel_h - 2, 4, 4, false);
    draw_set_alpha(1);

    var _dx = panel_x + 16;
    if (!variable_global_exists("diary_appear_alpha")) global.diary_appear_alpha = 1;
    if (global.diary_appear_alpha < 1) {
        global.diary_appear_alpha += 0.02;
        if (global.diary_appear_alpha > 1) global.diary_appear_alpha = 1;
    }
    var _has_new  = variable_global_exists("diary_has_new")  && global.diary_has_new;
    var _was_read = variable_global_exists("diary_was_read") && global.diary_was_read;
    var bounce_offset = (_has_new && !_was_read) ? sin(current_time / 200) * 3 : 0;
    draw_sprite_ext(spr_diary_tools, 0, _dx, cy - 13 + bounce_offset, 0.8, 0.8, 0, c_white, global.diary_appear_alpha);
    if (_has_new) {
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(make_color_rgb(255, 70, 30));
        draw_text(_dx + 12, cy - 13 + bounce_offset - 10, "!");
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
    }
}

// --- Предметы ---
draw_set_color(c_white);
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

for (var _i = 0; _i < eff_visible; _i++) {
    var _idx = hotbar_scroll + _i;
    if (_idx >= total_items) break;
    var _e  = hotbar_items[_idx];
    var _sx = ix + slot_w * _i;

    // Подсветка выбранного семени или лопаты
    var _highlight = (_e.is_seed && selected_seed == _e.item)
                  || (_e.item == "shovel"       && selected_shovel)
                  || (_e.item == "watering_can" && selected_watering_can);
    if (_highlight) {
        draw_set_color(make_color_rgb(255, 220, 50));
        draw_set_alpha(0.9);
        draw_roundrect_ext(_sx + 3, panel_y + 3, _sx + slot_w - 3, panel_y + panel_h - 3, 4, 4, true);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    // Туториал-подсветка: пульсирующая зелёная рамка
    var _tut_step = variable_global_exists("tutorial_farm_step") ? global.tutorial_farm_step : 8;
    var _tut_glow = ((_tut_step == 1 || _tut_step == 2) && _e.item == "shovel")
                 || ((_tut_step == 3 || _tut_step == 4) && _e.is_seed)
                 || ((_tut_step == 5 || _tut_step == 6) && _e.item == "watering_can");
    if (_tut_glow) {
        var _pulse = 0.5 + sin(current_time / 200) * 0.5;
        draw_set_color(make_color_rgb(80, 255, 120));
        draw_set_alpha(_pulse);
        draw_roundrect_ext(_sx + 2, panel_y + 2, _sx + slot_w - 2, panel_y + panel_h - 2, 5, 5, true);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    // Иконка
    if (sprite_exists(_e.spr)) {
        draw_sprite_ext(_e.spr, 0, _sx + 8, cy - 12, 0.8, 0.8, 0, c_white, 1);
    }

    // Количество
    if (_e.has_count) {
        draw_set_color(c_white);
        draw_text(_sx + 30, cy, string(inventory_get_amount(_e.item)));
    }
}

// --- Стрелки листания ---
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (can_left) {
    var _ax = panel_x + diary_off + arrow_w / 2;
    // Фон стрелки
    draw_set_alpha(0.4);
    draw_set_color(c_black);
    draw_roundrect_ext(_ax - 10, panel_y + 8, _ax + 10, panel_y + panel_h - 8, 3, 3, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_ax, cy, "◄");
}
if (can_right) {
    var _ax = ix + slot_w * hotbar_visible + arrow_w / 2;
    draw_set_alpha(0.4);
    draw_set_color(c_black);
    draw_roundrect_ext(_ax - 10, panel_y + 8, _ax + 10, panel_y + panel_h - 8, 3, 3, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_ax, cy, "►");
}

// --- Разделители между слотами ---
draw_set_color(make_color_rgb(80, 80, 80));
for (var _i = 1; _i < eff_visible; _i++) {
    var _lx = ix + slot_w * _i;
    draw_line(_lx, panel_y + 8, _lx, panel_y + panel_h - 8);
}

// --- Золотой разделитель дневника ---
if (has_diary) {
    draw_set_color(make_color_rgb(160, 120, 60));
    draw_line_width(panel_x + slot_w, panel_y + 4, panel_x + slot_w, panel_y + panel_h - 4, 2);
}

// --- Сброс ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
