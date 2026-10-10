// === КОЛОДЕЦ (DRAW) ===
draw_self();

// Подсказка "[E] Набрать воду", пока Макс рядом
if (instance_exists(obj_max)
&&  point_distance(x, y, obj_max.x, obj_max.y) < 48
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    var yy = y - (sprite_exists(sprite_index) ? sprite_height : 16) - 6;

    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(0.35);
    draw_set_color(c_black);
    draw_rectangle(x - 60, yy - 14, x + 60, yy + 2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(x, yy, "[E] Набрать воду");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
