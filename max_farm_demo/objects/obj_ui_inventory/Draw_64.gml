// Инвентарь теперь рисуется в obj_max/Draw_64.gml
// Этот файл оставлен для поповеров (анимации +1/-1)

// Поповер при сборе морковки
if (variable_instance_exists(id, "carrot_pop_timer") && carrot_pop_timer > 0) {
    var a = carrot_pop_timer / carrot_pop_max;
    draw_set_alpha(a);
    draw_set_color(c_lime);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    var pop_x = display_get_gui_width() / 2;
    var pop_y = display_get_gui_height() - 70 + carrot_pop_dy;
    draw_text(pop_x, pop_y, carrot_pop_text);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// Универсальный попап: иконка + "+1"
if (variable_instance_exists(id, "item_pop_timer") && item_pop_timer > 0) {
    var _a  = item_pop_timer / item_pop_max;
    var _px = display_get_gui_width()  / 2;
    var _py = display_get_gui_height() - 80 + item_pop_dy;

    // Иконка
    if (sprite_exists(item_pop_sprite)) {
        draw_sprite_ext(item_pop_sprite, 0, _px - 24, _py - 16, 0.8, 0.8, 0, c_white, _a);
    }
    // Текст "+1"
    draw_set_alpha(_a);
    draw_set_color(c_lime);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(_px - 4, _py - 8, item_pop_text);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
