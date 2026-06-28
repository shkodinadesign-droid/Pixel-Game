// ===== ХИНТ "[E] Говорить" при повторном визите =====
if (shop_state == 0) {
    if (variable_global_exists("miley_first_visit_done") && global.miley_first_visit_done
    && instance_exists(obj_max)
    && point_distance(x, y, obj_max.x, obj_max.y) < 160) {
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _vx = camera_get_view_x(view_camera[0]);
        var _vy = camera_get_view_y(view_camera[0]);
        var _vw = camera_get_view_width(view_camera[0]);
        var _vh = camera_get_view_height(view_camera[0]);
        var _sx = (x - _vx) * (_gui_w / _vw);
        var _sy = (y - _vy) * (_gui_h / _vh);

        var _pw = 130; var _ph = 28;
        var _px = _sx - _pw / 2 + 10;
        var _py = _sy - 72;

        draw_set_alpha(0.88);
        draw_set_color(c_black);
        draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 6, 6, false);
        draw_set_alpha(1);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_px + _pw / 2, _py + _ph / 2, "[E]  Говорить");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    exit;
}

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ===== ДИАЛОГ (фазы 1-3) =====
if (shop_state >= 1 && shop_state <= 3) {
    dx = (_gui_w - dw) / 2;

    var _speaker, _col, _l1, _l2;
    switch (shop_state) {
        case 1:
            _speaker = "Майли:";
            _col = make_color_rgb(80, 180, 120);
            _l1  = "Добро пожаловать в магазин!";
            _l2  = "Для новых посетителей у нас будут скидки!";
            break;
        case 2:
            _speaker = "Макс:";
            _col = make_color_rgb(255, 210, 100);
            _l1  = "Добрый день! Рада новому знакомству!";
            _l2  = "Хочу тут прикупить у вас новые товары!";
            break;
        case 3:
            _speaker = "Майли:";
            _col = make_color_rgb(80, 180, 120);
            _l1  = "Посмотрите что у нас есть!";
            _l2  = "У нас большой выбор =)";
            break;
        default: exit;
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_roundrect_ext(dx, dy, dx + dw, dy + dh, 12, 12, false);
    draw_set_color(_col);
    draw_roundrect_ext(dx, dy, dx + dw, dy + dh, 12, 12, true);

    var tx = dx + dpad + 8;
    var ty = dy + dpad;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_col);
    draw_text(tx, ty, _speaker);
    ty += dlh * 1.5;
    draw_set_color(c_white);
    draw_text(tx, ty, _l1); ty += dlh;
    draw_text(tx, ty, _l2);

    var _bx1 = dx + dw - btn_w - dpad;
    var _by1 = dy + dh - btn_h - dpad;
    var _bx2 = _bx1 + btn_w;
    var _by2 = _by1 + btn_h;
    var _hover = (_mx >= _bx1 && _mx <= _bx2 && _my >= _by1 && _my <= _by2);

    draw_set_color(_hover ? c_white : c_black);
    draw_rectangle(_bx1, _by1, _bx2, _by2, false);
    draw_set_color(_col);
    draw_line(_bx1+1,_by1,_bx2-1,_by1); draw_line(_bx1+1,_by2,_bx2-1,_by2);
    draw_line(_bx1+1,_by1,_bx1+1,_by2); draw_line(_bx2-1,_by1,_bx2-1,_by2);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_hover ? c_black : c_white);
    draw_text((_bx1+_bx2)/2, (_by1+_by2)/2, "Далее");
}

// ===== КОРОТКИЙ ДИАЛОГ (фаза 5) — повторный визит =====
if (shop_state == 5) {
    dx = (_gui_w - dw) / 2;
    var _col5 = make_color_rgb(80, 180, 120);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_roundrect_ext(dx, dy, dx + dw, dy + dh, 12, 12, false);
    draw_set_color(_col5);
    draw_roundrect_ext(dx, dy, dx + dw, dy + dh, 12, 12, true);

    var tx5 = dx + dpad + 8;
    var ty5 = dy + dpad;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_col5);
    draw_text(tx5, ty5, "Майли:");
    ty5 += dlh * 1.5;
    draw_set_color(c_white);
    draw_text(tx5, ty5, "Добрый день! Что желаете купить?");

    var _bx1 = dx + dw - btn_w - dpad;
    var _by1 = dy + dh - btn_h - dpad;
    var _bx2 = _bx1 + btn_w;
    var _by2 = _by1 + btn_h;
    var _hover5 = (device_mouse_x_to_gui(0) >= _bx1 && device_mouse_x_to_gui(0) <= _bx2
               && device_mouse_y_to_gui(0) >= _by1 && device_mouse_y_to_gui(0) <= _by2);
    draw_set_color(_hover5 ? c_white : c_black);
    draw_rectangle(_bx1, _by1, _bx2, _by2, false);
    draw_set_color(_col5);
    draw_line(_bx1+1,_by1,_bx2-1,_by1); draw_line(_bx1+1,_by2,_bx2-1,_by2);
    draw_line(_bx1+1,_by1,_bx1+1,_by2); draw_line(_bx2-1,_by1,_bx2-1,_by2);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_hover5 ? c_black : c_white);
    draw_text((_bx1+_bx2)/2, (_by1+_by2)/2, "Далее");
}

// ===== МАГАЗИН (фаза 4) — идентично chest =====
if (shop_state == 4) {
    // Затемнение фона
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // Панель
    draw_set_color(make_color_rgb(240, 225, 190));
    draw_roundrect_ext(shop_panel_x, shop_panel_y,
                       shop_panel_x + shop_panel_w, shop_panel_y + shop_panel_h, 8, 8, false);
    draw_set_color(make_color_rgb(160, 120, 70));
    draw_roundrect_ext(shop_panel_x, shop_panel_y,
                       shop_panel_x + shop_panel_w, shop_panel_y + shop_panel_h, 8, 8, true);

    // Разделитель по центру
    draw_set_color(make_color_rgb(160, 120, 70));
    draw_line(shop_panel_x + shop_panel_w / 2, shop_panel_y + 10,
              shop_panel_x + shop_panel_w / 2, shop_panel_y + shop_panel_h - 10);

    // Заголовки
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(80, 50, 20));
    draw_text(shop_panel_x + shop_panel_w / 4,     shop_panel_y + 16, "МАГАЗИН МАЙЛИ");
    draw_text(shop_panel_x + shop_panel_w * 3 / 4, shop_panel_y + 16, "ИНВЕНТАРЬ");

    // Монеты
    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(140, 100, 20));
    draw_text(shop_panel_x + shop_panel_w / 2 - 6, shop_panel_y + 36,
              "Монеты: " + string(global.coins));

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    // Вспомогательная функция отрисовки слота
    var _draw_slot = function(_sx, _sy, _def, _qty, _selected, _price_label, _mx, _my) {
        var _hover = (_mx >= _sx && _mx <= _sx + shop_slot_size &&
                      _my >= _sy && _my <= _sy + shop_slot_size);
        var _sel   = _selected;

        draw_set_color(_sel ? make_color_rgb(255,230,150) : (_hover ? make_color_rgb(230,210,170) : make_color_rgb(210,190,150)));
        draw_roundrect_ext(_sx, _sy, _sx+shop_slot_size, _sy+shop_slot_size, 4,4, false);
        draw_set_color(_sel ? make_color_rgb(200,140,30) : make_color_rgb(160,120,80));
        draw_roundrect_ext(_sx, _sy, _sx+shop_slot_size, _sy+shop_slot_size, 4,4, true);

        if (_qty > 0 || _price_label != "") {
            if (sprite_exists(_def.spr)) {
                var _iw = sprite_get_width(_def.spr);
                var _ih = sprite_get_height(_def.spr);
                var _ox = sprite_get_xoffset(_def.spr);
                var _oy = sprite_get_yoffset(_def.spr);
                var _sc = min((shop_slot_size-8)/_iw, (shop_slot_size-8)/_ih);
                draw_sprite_ext(_def.spr, 0,
                    _sx+shop_slot_size/2-(_iw/2-_ox)*_sc,
                    _sy+shop_slot_size/2-(_ih/2-_oy)*_sc,
                    _sc, _sc, 0, c_white, 1);
            } else {
                draw_set_color(_def.col);
                draw_circle(_sx+shop_slot_size/2, _sy+shop_slot_size/2, 14, false);
            }

            // Цена или количество
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_bottom);
            if (_price_label != "") {
                draw_set_color(make_color_rgb(100,60,10));
                draw_text(_sx+shop_slot_size/2, _sy+shop_slot_size-1, _price_label);
            }
            if (_qty > 0 && _price_label == "") {
                var _bx = _sx+shop_slot_size; var _by = _sy+shop_slot_size;
                draw_set_color(make_color_rgb(70,40,10));
                draw_circle(_bx, _by, 7, false);
                draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_bx, _by, string(_qty));
            }
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    };

    // Левая сторона — товары магазина (покупка)
    for (var _r = 0; _r < shop_grid_rows; _r++) {
        for (var _c = 0; _c < shop_grid_cols; _c++) {
            var _idx = _r * shop_grid_cols + _c;
            var _sx  = shop_grid_x + _c * (shop_slot_size + shop_slot_gap);
            var _sy  = shop_grid_y + _r * (shop_slot_size + shop_slot_gap);
            if (_idx < array_length(shop_items)) {
                var _def  = shop_items[_idx];
                _draw_slot(_sx, _sy, _def, 0,
                           (shop_selected == _idx),
                           " ", mx, my);
            }
        }
    }

    // Правая сторона — товары игрока (продажа)
    for (var _r = 0; _r < shop_grid_rows; _r++) {
        for (var _c = 0; _c < shop_grid_cols; _c++) {
            var _idx = _r * shop_grid_cols + _c;
            var _sx  = shop_inv_x + _c * (shop_slot_size + shop_slot_gap);
            var _sy  = shop_grid_y + _r * (shop_slot_size + shop_slot_gap);
            if (_idx < array_length(sell_items)) {
                var _def = sell_items[_idx];
                var _qty = inventory_get_amount(_def.id);
                _draw_slot(_sx, _sy, _def, _qty,
                           (sell_selected == _idx), "", mx, my);
            }
        }
    }

    // ── Товары Майли (под левой сеткой магазина, слоты с кружками) ──
    if (variable_global_exists("miley_inventory") && ds_map_size(global.miley_inventory) > 0) {
        var _ml_top = shop_grid_y + shop_grid_rows * (shop_slot_size + shop_slot_gap) + 6;
        var _ml_sy  = _ml_top;
        var _ml_col = 0;
        var _mkey   = ds_map_find_first(global.miley_inventory);
        repeat(ds_map_size(global.miley_inventory)) {
            if (_ml_sy + shop_slot_size > shop_panel_y + shop_panel_h - 66) break;
            var _mamt = ds_map_find_value(global.miley_inventory, _mkey);
            var _mdef = ds_map_find_value(global.item_database, _mkey);
            var _mspr = (_mdef != undefined && variable_struct_exists(_mdef, "icon")) ? _mdef.icon : -1;
            var _mcol = (_mdef != undefined && variable_struct_exists(_mdef, "col"))  ? _mdef.col  : make_color_rgb(180,160,120);
            var _mslot = { spr: _mspr, col: _mcol };
            var _msx = shop_grid_x + _ml_col * (shop_slot_size + shop_slot_gap);
            _draw_slot(_msx, _ml_sy, _mslot, _mamt, false, "", mx, my);
            _ml_col++;
            if (_ml_col >= shop_grid_cols) { _ml_col = 0; _ml_sy += shop_slot_size + shop_slot_gap; }
            _mkey = ds_map_find_next(global.miley_inventory, _mkey);
        }
    }

    // ── Панель покупки снизу ──
    var _bar_y = shop_panel_y + shop_panel_h - 62;
    draw_set_color(make_color_rgb(200, 175, 130));
    draw_line(shop_panel_x + 10, _bar_y - 4, shop_panel_x + shop_panel_w - 10, _bar_y - 4);

    if (shop_selected >= 0) {
        var _item   = shop_items[shop_selected];
        var _total  = _item.price * shop_buy_qty;
        var _can    = (global.coins >= _total);
        var _bar_cx = shop_panel_x + shop_panel_w / 4;

        // Название выбранного товара
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(_bar_cx, _bar_y, _item.name);

        // ◄  количество  ►
        var _arr_w = 24; var _arr_h = 24;
        var _left_x  = _bar_cx - 50;
        var _right_x = _bar_cx + 26;
        var _qty_y   = _bar_y + 16;

        draw_set_color(make_color_rgb(160, 120, 70));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_left_x  + _arr_w / 2, _qty_y + _arr_h / 2, "◄");
        draw_text(_right_x + _arr_w / 2, _qty_y + _arr_h / 2, "►");

        draw_set_color(make_color_rgb(50, 30, 10));
        draw_text(_bar_cx, _qty_y + _arr_h / 2, string(shop_buy_qty));

        // Цена: N = X монет
        draw_set_color(_can ? make_color_rgb(120, 80, 20) : make_color_rgb(180, 60, 60));
        draw_set_valign(fa_top);
        draw_text(_bar_cx, _qty_y + _arr_h + 2,
                  string(shop_buy_qty) + " = " + string(_total) + " монет");

        // Кнопка КУПИТЬ
        var _btn_x = shop_panel_x + shop_panel_w / 2 - 60;
        var _btn_w = 120; var _btn_h = 32;
        var _btn_y = _bar_y + 4;
        draw_set_color(_can ? make_color_rgb(80, 140, 60) : make_color_rgb(160, 130, 110));
        draw_roundrect_ext(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, 5, 5, false);
        draw_set_color(_can ? make_color_rgb(50, 100, 30) : make_color_rgb(130, 100, 80));
        draw_roundrect_ext(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, 5, 5, true);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_btn_x + _btn_w / 2, _btn_y + _btn_h / 2, "КУПИТЬ");
    } else {
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(160, 130, 90));
        draw_text(shop_panel_x + shop_panel_w / 4, _bar_y + 28, "Выбери товар слева");
    }

    // ── Панель продажи (правая сторона) ──
    var _bar_cx_r = shop_panel_x + shop_panel_w * 3 / 4;
    if (sell_selected >= 0) {
        var _sitem   = sell_items[sell_selected];
        var _s_price = _sitem.price;
        var _have    = inventory_get_amount(_sitem.id);
        var _s_total = _s_price * sell_qty;

        // Название
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(_bar_cx_r, _bar_y, _sitem.name);

        // ◄ количество ►
        var _arr_w = 24; var _arr_h = 24;
        var _left_x  = _bar_cx_r - 50;
        var _right_x = _bar_cx_r + 26;
        var _qty_y   = _bar_y + 16;

        draw_set_color(make_color_rgb(160, 120, 70));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_left_x  + _arr_w / 2, _qty_y + _arr_h / 2, "◄");
        draw_text(_right_x + _arr_w / 2, _qty_y + _arr_h / 2, "►");
        draw_set_color(make_color_rgb(50, 30, 10));
        draw_text(_bar_cx_r, _qty_y + _arr_h / 2, string(sell_qty));

        // Цена: N = X монет
        draw_set_color(make_color_rgb(80, 130, 50));
        draw_set_valign(fa_top);
        draw_text(_bar_cx_r, _qty_y + _arr_h + 2,
                  string(sell_qty) + " = " + string(_s_total) + " монет");

        // Кнопка ПРОДАТЬ
        var _btn_x = shop_panel_x + shop_panel_w - 140;
        var _btn_w = 120; var _btn_h = 32;
        var _btn_y = _bar_y + 4;
        var _can_sell = (_have >= sell_qty);
        draw_set_color(_can_sell ? make_color_rgb(60, 120, 180) : make_color_rgb(160, 130, 110));
        draw_roundrect_ext(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, 5, 5, false);
        draw_set_color(_can_sell ? make_color_rgb(30, 80, 140) : make_color_rgb(130, 100, 80));
        draw_roundrect_ext(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, 5, 5, true);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_btn_x + _btn_w / 2, _btn_y + _btn_h / 2, "ПРОДАТЬ");
    } else {
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(160, 130, 90));
        draw_text(_bar_cx_r, _bar_y + 28, "Выбери товар справа");
    }

    // Монеты (всегда видны)
    draw_set_font(fnt_ui);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(140, 100, 20));
    draw_text(shop_panel_x + shop_panel_w / 2 - 6, shop_panel_y + 36,
              "Монеты: " + string(global.coins));

    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(160, 120, 70));
    draw_text(shop_panel_x + shop_panel_w - 12, shop_panel_y + 10, "[E] закрыть");
}

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
