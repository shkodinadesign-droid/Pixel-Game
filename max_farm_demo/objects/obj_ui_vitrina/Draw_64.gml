// ===== UI ВИТРИНА DRAW GUI =====

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Панель
draw_set_color(make_color_rgb(240, 225, 190));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, false);
draw_set_color(make_color_rgb(160, 120, 70));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, true);

// Заголовок
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(80, 50, 20));
draw_text(panel_x + panel_w / 2, panel_y + 10, "ВИТРИНА");

// Разделитель по центру
draw_set_color(make_color_rgb(160, 120, 70));
draw_line(panel_x + panel_w / 2, panel_y + 38, panel_x + panel_w / 2, panel_y + panel_h - 10);

// Заголовки колонок
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(100, 65, 25));
draw_text(inv_list_x, panel_y + 38, "Инвентарь [E]");
draw_text(vit_col_x, panel_y + 38, "На витрине");

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var _half_w = panel_w / 2 - 24;

// ---- Левая колонка: инвентарь ----
var _key = ds_map_find_first(global.player_inventory);
var _idx = 0;
while (_key != undefined) {
    var _amt = ds_map_find_value(global.player_inventory, _key);
    if (_amt > 0) {
        var _iy = inv_list_y + _idx * item_h;
        if (_iy + item_h > panel_y + panel_h - 50) break;

        var _hover = (mx >= inv_list_x && mx <= inv_list_x + _half_w &&
                      my >= _iy && my <= _iy + item_h - 2);

        draw_set_color(_hover ? make_color_rgb(220, 200, 165) : make_color_rgb(210, 190, 150));
        draw_roundrect_ext(inv_list_x, _iy, inv_list_x + _half_w, _iy + item_h - 2, 3, 3, false);
        draw_set_color(make_color_rgb(170, 130, 90));
        draw_roundrect_ext(inv_list_x, _iy, inv_list_x + _half_w, _iy + item_h - 2, 3, 3, true);

        var _info = storage_get_item_info(_key);
        var _name = (_info != undefined) ? _info.name : _key;
        draw_set_font(fnt_ui);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(_hover ? make_color_rgb(60, 130, 60) : make_color_rgb(50, 30, 10));
        draw_text(inv_list_x + 6, _iy + (item_h - 2) / 2, _name + " x" + string(_amt));

        _idx++;
    }
    _key = ds_map_find_next(global.player_inventory, _key);
}

if (_idx == 0) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(130, 100, 70));
    draw_text(inv_list_x + 4, inv_list_y + 8, "Инвентарь пуст");
}

// ---- Правая колонка: витрина ----
var _vkey = ds_map_find_first(global.vitrina_items);
var _vidx = 0;
while (_vkey != undefined) {
    var _entry = ds_map_find_value(global.vitrina_items, _vkey);
    var _vy = vit_col_y + _vidx * item_h;
    if (_vy + item_h > panel_y + panel_h - 60) break;

    var _info = storage_get_item_info(_vkey);
    var _name = (_info != undefined) ? _info.name : _vkey;

    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(40, 100, 40));
    draw_text(vit_col_x + 4, _vy + 6, _name + " x" + string(_entry.amount));
    draw_set_color(make_color_rgb(120, 100, 60));
    draw_text(vit_col_x + 4, _vy + 20, string(_entry.price) + " мон./шт.");

    _vidx++;
    _vkey = ds_map_find_next(global.vitrina_items, _vkey);
}

if (_vidx == 0) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(130, 100, 70));
    draw_text(vit_col_x + 4, vit_col_y + 8, "Витрина пуста");
}

// Ожидают монеты
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(160, 120, 20));
draw_text(vit_col_x + 4, panel_y + panel_h - 56, "Ожидает: " + string(global.coins_pending) + " монет");

// Кнопка "Забрать монеты"
var _can_collect = (global.coins_pending > 0);
var _btn_hover   = _can_collect && (mx >= btn_x && mx <= btn_x + btn_w &&
                                    my >= btn_y && my <= btn_y + btn_h);

draw_set_color(_can_collect ? (_btn_hover ? make_color_rgb(100, 60, 15) : make_color_rgb(139, 90, 43))
                            : make_color_rgb(160, 145, 130));
draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 4, 4, false);
draw_set_color(make_color_rgb(200, 170, 130));
draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 4, 4, true);

draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_can_collect ? make_color_rgb(255, 245, 220) : make_color_rgb(180, 165, 145));
draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2,
          "Забрать " + string(global.coins_pending) + " монет");

// Подсказка закрытия
draw_set_font(fnt_ui);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(panel_x + panel_w - 12, panel_y + 10, "[E] закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
