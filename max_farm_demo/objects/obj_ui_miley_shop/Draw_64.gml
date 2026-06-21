// ===== UI МАГАЗИН МАЙЛИ (DRAW GUI) =====

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Панель
draw_set_color(make_color_rgb(240, 225, 190));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, false);
draw_set_color(make_color_rgb(80, 180, 120));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, true);

// Заголовок
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(40, 100, 60));
draw_text(panel_x + panel_w / 2, panel_y + 12, "МАГАЗИН МАЙЛИ");

// Монеты игрока
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(160, 120, 20));
draw_text(panel_x + panel_w - pad, panel_y + 12, "Монеты: " + string(global.coins));

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Разделитель
draw_set_color(make_color_rgb(80, 180, 120));
draw_line(panel_x + pad, panel_y + 38, panel_x + panel_w - pad, panel_y + 38);

// Список товаров
for (var i = 0; i < array_length(shop_items); i++) {
    var _item    = shop_items[i];
    var _iy      = panel_y + 60 + i * item_h;
    var _can_buy = (global.coins >= _item.price);
    var _hover   = (hover_item == i);

    draw_set_color(_hover ? make_color_rgb(220, 200, 165) : make_color_rgb(210, 190, 150));
    draw_roundrect_ext(panel_x + pad, _iy, panel_x + panel_w - pad, _iy + item_h - 4, 4, 4, false);
    draw_set_color(make_color_rgb(160, 120, 70));
    draw_roundrect_ext(panel_x + pad, _iy, panel_x + panel_w - pad, _iy + item_h - 4, 4, 4, true);

    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(_can_buy ? make_color_rgb(50, 30, 10) : make_color_rgb(150, 120, 100));
    draw_text(panel_x + pad + 10, _iy + (item_h - 4) / 2, _item.name);

    draw_set_halign(fa_right);
    draw_set_color(_can_buy ? make_color_rgb(140, 100, 20) : make_color_rgb(160, 100, 100));
    draw_text(panel_x + panel_w - pad - 10, _iy + (item_h - 4) / 2,
              string(_item.price) + " монет");
}

// Подсказка закрытия
draw_set_font(fnt_ui);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(panel_x + panel_w - 12, panel_y + panel_h - 26, "[E] закрыть");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
