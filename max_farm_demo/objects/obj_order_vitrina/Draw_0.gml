// === СТОЛ ЗАКАЗОВ / ВИТРИНА (DRAW) ===
draw_self();

if (!variable_global_exists("justin_bakery_intro_done")) exit;
if (global.justin_bakery_intro_done) exit;

var _cx = bbox_right - 80;

// "!" над прилавком
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_yellow);
draw_text(_cx, bbox_top - 6, "!");

// подсказка "E" когда Макс рядом
if (!global.control_locked && instance_exists(obj_max)) {
    var _dist = point_distance(obj_max.x, obj_max.y, bbox_right - 80, bbox_bottom);
    if (_dist < 128) {
        draw_set_color(c_white);
        draw_text(_cx, bbox_top - 24, "E");
    }
}

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
