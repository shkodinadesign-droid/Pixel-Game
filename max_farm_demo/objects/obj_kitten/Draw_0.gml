// ===== КОТИК — DRAW =====

if (room != rm_farm && room != rm_house_inside) exit;

// В доме — кот рисуется только если он там логически находится
if (room == rm_house_inside) {
    if (!variable_instance_exists(id, "kitten_room") || kitten_room != rm_house_inside) exit;
    // Рисуем кота в доме
    var _draw_x = x - 16 * image_xscale;
    var _draw_y = y - 30;
    draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y, image_xscale, 1, 0, c_white, 1);
    exit;
}

// === Дальше — только rm_farm ===

var _day2_hide = (instance_exists(obj_day_controller) && obj_day_controller.day_index >= 2
    && variable_global_exists("kitten_arrived") && !global.kitten_arrived
    && state != "follow" && state != "sit_near");

if (_day2_hide) exit;

// --- Спрайт Кекса ---
// origin спрайтов top-left (0,0), размер 32x32
// _draw_x: центрируем по x с учётом flip (image_xscale = ±1)
// _draw_y: bbox_bottom ≈ 30 → нижний край спрайта на y (глубина по ногам)
var _draw_x = x - 16 * image_xscale;
var _draw_y = y - 30;
draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y, image_xscale, 1, 0, c_white, 1);

// --- Сердечко при поглаживании ---
if (heart_alpha > 0) {
    draw_sprite_ext(spr_tab_friends, 0,
        x - 8, y - 36,
        0.5, 0.5, 0, c_white, heart_alpha);
}

// --- Имя "Кексик" когда Макс рядом ---
if (instance_exists(obj_max)) {
    var _nd = point_distance(x, y, obj_max.x, obj_max.y);
    if (_nd < 64) {
        var _na = clamp(1 - (_nd - 30) / 34, 0, 1);
        draw_set_alpha(_na);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(make_color_rgb(255, 220, 80));
        draw_text(x, y - 36, kitten_name);
        draw_set_alpha(1);
    }
}

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
