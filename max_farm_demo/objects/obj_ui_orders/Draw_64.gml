// ===== UI ЗАКАЗЫ DRAW GUI =====

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
draw_text(panel_x + panel_w / 2, panel_y + 10, "ЗАКАЗЫ ДНЯ");

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// ---- Карточки заказов ----
var _count = array_length(global.daily_orders);

for (var i = 0; i < _count; i++) {
    var _order = global.daily_orders[i];
    var _cy    = cards_y + i * (card_h + card_pad);
    var _can   = orders_can_fulfill(i);

    // Цвет карточки
    var _card_col;
    if (_order.fulfilled) {
        _card_col = make_color_rgb(175, 170, 162);
    } else if (_can) {
        _card_col = make_color_rgb(200, 228, 196);
    } else {
        _card_col = make_color_rgb(212, 202, 186);
    }

    // Фон карточки
    draw_set_color(_card_col);
    draw_roundrect_ext(panel_x + 10, _cy, panel_x + panel_w - 10, _cy + card_h, 5, 5, false);
    draw_set_color(make_color_rgb(140, 100, 60));
    draw_roundrect_ext(panel_x + 10, _cy, panel_x + panel_w - 10, _cy + card_h, 5, 5, true);

    var _text_col = _order.fulfilled ? make_color_rgb(120, 110, 100) : make_color_rgb(60, 35, 10);

    // Имя NPC
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_text_col);
    draw_text(panel_x + 20, _cy + 8, _order.npc_name);

    // Товар и наличие
    var _item_info = storage_get_item_info(_order.item_id);
    var _item_name = (_item_info != undefined) ? _item_info.name : _order.item_id;
    var _have      = inventory_get_amount(_order.item_id);

    draw_set_font(fnt_ui);
    draw_set_color(_order.fulfilled ? make_color_rgb(120, 110, 100)
                                    : (_can ? make_color_rgb(40, 110, 40) : make_color_rgb(150, 50, 40)));
    draw_text(panel_x + 20, _cy + 28,
              _item_name + ": " + string(_have) + "/" + string(_order.amount));

    // Награда
    draw_set_color(_order.fulfilled ? make_color_rgb(120, 110, 100) : make_color_rgb(155, 110, 10));
    draw_text(panel_x + 20, _cy + 48, "Награда: " + string(_order.reward) + " монет");

    if (_order.fulfilled) {
        // Зачёркивающая линия
        draw_set_color(make_color_rgb(100, 90, 80));
        draw_set_alpha(0.55);
        draw_line(panel_x + 12, _cy + card_h / 2, panel_x + panel_w - 12, _cy + card_h / 2);
        draw_set_alpha(1);
    } else {
        // Кнопка "Выполнить"
        var _bx = panel_x + panel_w - btn_w - 12;
        var _by = _cy + (card_h - btn_h) / 2;
        var _btn_hover = (mx >= _bx && mx <= _bx + btn_w &&
                          my >= _by && my <= _by + btn_h);

        draw_set_color(_can ? (_btn_hover ? make_color_rgb(55, 130, 55) : make_color_rgb(75, 150, 75))
                            : make_color_rgb(150, 140, 130));
        draw_roundrect_ext(_bx, _by, _bx + btn_w, _by + btn_h, 4, 4, false);
        draw_set_color(make_color_rgb(180, 160, 140));
        draw_roundrect_ext(_bx, _by, _bx + btn_w, _by + btn_h, 4, 4, true);

        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(_can ? make_color_rgb(240, 255, 235) : make_color_rgb(170, 160, 150));
        draw_text(_bx + btn_w / 2, _by + btn_h / 2, "Выполнить");
    }
}

if (_count == 0) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(130, 100, 70));
    draw_text(panel_x + panel_w / 2, panel_y + panel_h / 2, "Нет заказов на сегодня");
}

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
