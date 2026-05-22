// ===== UI HP DRAW GUI =====

// Показываем только после того как Макс выпила кофе
if (!variable_global_exists("coffee_made") || !global.coffee_made) exit;
if (!instance_exists(obj_max)) exit;

// Плавное появление
hp_alpha = min(hp_alpha + 0.03, 1);
draw_set_alpha(hp_alpha);

var _player   = instance_find(obj_max, 0);
var _hp_ratio = clamp(_player.hp / _player.hp_max, 0, 1);

var _x     = 20;
var _y     = 48;   // ниже монет (монеты ~y=18-40)
var _bar_w = 110;
var _bar_h = 10;
var _r     = 5;

// ♥ сердечко слева
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(235, 80, 110));
draw_text(_x, _y + _bar_h / 2, "♥");

// Фон полоски
var _bx = _x + 18;
draw_set_color(make_color_rgb(40, 20, 10));
draw_roundrect_ext(_bx, _y, _bx + _bar_w, _y + _bar_h, _r, _r, false);

// Заливка
if (_hp_ratio > 0) {
    var _fill_w = max(_r * 2, _bar_w * _hp_ratio);
    if (_hp_ratio > 0.60)      draw_set_color(make_color_rgb(80, 200, 80));
    else if (_hp_ratio > 0.30) draw_set_color(make_color_rgb(230, 200, 50));
    else                        draw_set_color(make_color_rgb(220, 60, 60));
    draw_roundrect_ext(_bx, _y, _bx + _fill_w, _y + _bar_h, _r, _r, false);
}

// Обводка
draw_set_color(make_color_rgb(170, 110, 50));
draw_roundrect_ext(_bx, _y, _bx + _bar_w, _y + _bar_h, _r, _r, true);

// Число справа от полоски
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(255, 235, 110));
draw_text(_bx + _bar_w + 5, _y + _bar_h / 2, string(_player.hp));

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
