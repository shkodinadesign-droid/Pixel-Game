// ===== ХИНТ "[E] Говорить" при повторном визите =====
if (shop_state == 0) {
    if (variable_global_exists(first_visit_key) && variable_global_get(first_visit_key)
    && instance_exists(obj_max)
    && point_distance(x, y, obj_max.x, obj_max.y) < talk_radius) {
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _vx = camera_get_view_x(view_camera[0]);
        var _vy = camera_get_view_y(view_camera[0]);
        var _vw = camera_get_view_width(view_camera[0]);
        var _vh = camera_get_view_height(view_camera[0]);
        var _sx = (x - _vx) * (_gui_w / _vw);
        var _sy = (y - _vy) * (_gui_h / _vh);

        var _pw = 130; var _ph = 28;
        var _px = _sx - _pw / 2 + 20;
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

    var _ln = intro_lines[clamp(shop_state - 1, 0, array_length(intro_lines) - 1)];
    var _speaker = _ln[0], _l1 = _ln[1], _l2 = _ln[2];

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    // Фон + бирка с именем — общий шаблон, как у остальных персонажей
    scr_dialog_draw_bg(dx, dy, dw, dh);
    scr_dialog_draw_speaker(dx, dy, dw, dh, _speaker);

    var tx = dx + 15 * (dw / 580) + 8;
    var ty = scr_dialog_body_top(dx, dy, dw, dh);
    var _text_max_w = dw - (tx - dx) - 16;

    var _bx1 = dx + dw - btn_w - dpad;
    var _by1 = dy + dh - btn_h - dpad;
    var _bx2 = _bx1 + btn_w;
    var _by2 = _by1 + btn_h;

    // Портрет Майли — только в её репликах
    if (_speaker == npc_speaker) {
        var _portrait_size = 72;
        var _portrait_x1   = dx + 565 * (dw / 580) - 8 - _portrait_size;
        scr_dialog_draw_portrait(dx, dy, dw, dh, _by1, npc_portrait, _portrait_size, ((current_time div 250) mod 2 == 0) ? 0 : 1);   // говорит: улыбка <-> смех
        _text_max_w = _portrait_x1 - tx - 16;
    }

    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_text_ext(tx, ty, _l1, -1, _text_max_w); ty += dlh;
    draw_text_ext(tx, ty, _l2, -1, _text_max_w);

    var _hover = (_mx >= _bx1 && _mx <= _bx2 && _my >= _by1 && _my <= _by2);
    scr_dialog_draw_button(_bx1, _by1, _bx2, _by2, "Далее", _hover);
}

// ===== КОРОТКИЙ ДИАЛОГ (фаза 5) — повторный визит =====
if (shop_state == 5) {
    dx = (_gui_w - dw) / 2;

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    scr_dialog_draw_bg(dx, dy, dw, dh);
    scr_dialog_draw_speaker(dx, dy, dw, dh, npc_speaker);

    var tx5 = dx + 15 * (dw / 580) + 8;
    var ty5 = scr_dialog_body_top(dx, dy, dw, dh);

    var _bx1 = dx + dw - btn_w - dpad;
    var _by1 = dy + dh - btn_h - dpad;
    var _bx2 = _bx1 + btn_w;
    var _by2 = _by1 + btn_h;

    var _portrait_size5 = 72;
    var _portrait_x1_5  = dx + 565 * (dw / 580) - 8 - _portrait_size5;
    scr_dialog_draw_portrait(dx, dy, dw, dh, _by1, npc_portrait, _portrait_size5, ((current_time div 250) mod 2 == 0) ? 0 : 1);
    var _text_max_w5 = _portrait_x1_5 - tx5 - 16;

    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_text_ext(tx5, ty5, repeat_line, -1, _text_max_w5);

    var _hover5 = (device_mouse_x_to_gui(0) >= _bx1 && device_mouse_x_to_gui(0) <= _bx2
               && device_mouse_y_to_gui(0) >= _by1 && device_mouse_y_to_gui(0) <= _by2);
    scr_dialog_draw_button(_bx1, _by1, _bx2, _by2, "Далее", _hover5);
}

// ===== МАГАЗИН (фаза 4) — книга как у ящика хранения: слева товары продавца, справа инвентарь Макс =====
if (shop_state == 4) {
    var _txt_dark = make_color_rgb(70, 40, 15);
    var _txt_mid  = make_color_rgb(130, 100, 70);
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    draw_sprite(spr_storage_bg, 0, shop_panel_x, shop_panel_y);
    var _cl_h = (_mx >= shop_close_x && _mx < shop_close_x + 30 && _my >= shop_close_y && _my < shop_close_y + 30);
    draw_sprite(_cl_h ? spr_ui_close_hover : spr_ui_close_normal, 0, shop_close_x, shop_close_y);

    // Заголовки в табличках и монеты
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_txt_dark);
    ui_font_fit(shop_title, 200);
    draw_text(shop_left_cx, shop_title_y, shop_title);
    ui_font_fit("Инвентарь", 200);
    draw_text(shop_right_cx, shop_title_y, "Инвентарь");
    draw_set_font(fnt_ui);
    draw_set_color(make_color_rgb(140, 100, 20));
    draw_text(shop_left_cx,  shop_title_y + 32, "Монеты: " + string(global.coins));
    draw_set_color(_txt_mid);
    draw_text(shop_right_cx, shop_title_y + 32, "[E] закрыть");

    // Ячейка: спрайт ячейки дневника, иконка 1:1 (32x32), цена или количество
    var _slot = function(_sx, _sy, _def, _qty, _sel, _price, _mx, _my) {
        var _hov = (_mx >= _sx && _mx < _sx + shop_slot_size && _my >= _sy && _my < _sy + shop_slot_size);
        draw_sprite(_sel ? spr_ui_inventory_slot_selected : (_hov ? spr_ui_inventory_slot_hover : spr_ui_inventory_slot_item), 0, _sx, _sy);
        if (sprite_exists(_def.spr)) {
            var _iw = sprite_get_width(_def.spr), _ih = sprite_get_height(_def.spr);
            var _sc = (max(_iw, _ih) <= 40) ? 1 : 36 / max(_iw, _ih);
            draw_sprite_ext(_def.spr, 0, _sx + (shop_slot_size - _iw * _sc) / 2 + sprite_get_xoffset(_def.spr) * _sc,
                            _sy + (shop_slot_size - _ih * _sc) / 2 + sprite_get_yoffset(_def.spr) * _sc, _sc, _sc, 0, c_white, 1);
        } else {
            draw_set_color(_def.col);
            draw_circle(_sx + shop_slot_size / 2, _sy + shop_slot_size / 2, 14, false);
        }
        draw_set_font(fnt_ui);
        if (_price >= 0) {                         // товар продавца — цена в правом верхнем углу
            draw_set_halign(fa_right); draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(140, 100, 20));
            draw_text(_sx + shop_slot_size - 3, _sy + 1, string(_price));
        } else if (_qty > 0) {                     // вещь Макс — бейдж количества
            draw_sprite(spr_ui_count_badge, 0, _sx + shop_slot_size - 12, _sy + shop_slot_size - 12);
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text(_sx + shop_slot_size - 4, _sy + shop_slot_size - 4, string(_qty));
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    };

    for (var _i = 0; _i < shop_grid_rows * shop_grid_cols; _i++) {
        var _sx = shop_grid_x + (_i mod shop_grid_cols) * (shop_slot_size + shop_slot_gap);
        var _sy = shop_grid_y + (_i div shop_grid_cols) * (shop_slot_size + shop_slot_gap);
        if (_i < array_length(shop_items)) _slot(_sx, _sy, shop_items[_i], 0, shop_selected == _i, shop_items[_i].price, _mx, _my);
        else draw_sprite(spr_ui_inventory_slot_empty, 0, _sx, _sy);
        var _px = shop_inv_x + (_i mod shop_grid_cols) * (shop_slot_size + shop_slot_gap);
        if (_i < array_length(sell_items)) _slot(_px, _sy, sell_items[_i], inventory_get_amount(sell_items[_i].id), sell_selected == _i, -1, _mx, _my);
        else draw_sprite(spr_ui_inventory_slot_empty, 0, _px, _sy);
    }

    // Нижняя панель страницы: название, ‹ количество ›, кнопка, сумма (координаты — как в Step)
    var _bar = function(_cx, _name, _qty, _total, _ok, _label, _mx, _my, _txt) {
        var _by = shop_bar_y;
        draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_top);
        draw_set_color(_txt);
        draw_text(_cx, _by, _name);
        draw_sprite((_qty > 1) ? spr_ui_arrow_left_normal : spr_ui_arrow_left_disabled, 0, _cx - 104, _by + 20);
        draw_sprite(spr_ui_arrow_right_normal, 0, _cx - 60, _by + 20);
        draw_set_valign(fa_middle);
        draw_text(_cx - 72, _by + 30, string(_qty));
        var _bx = _cx + 8, _bh = (_mx >= _bx && _mx < _bx + 96 && _my >= _by + 17 && _my < _by + 43);
        draw_sprite_ext(_ok ? spr_ui_recipe_category_active : spr_ui_recipe_category_inactive, 0, _bx, _by + 17, 1, 1, 0, c_white, (_ok && _bh) ? 0.85 : 1);
        draw_set_color(_ok ? make_color_rgb(60, 35, 10) : make_color_rgb(150, 120, 90));
        draw_text(_bx + 48, _by + 30, _label);
        draw_set_valign(fa_top);
        draw_set_color(_ok ? make_color_rgb(140, 100, 20) : make_color_rgb(180, 60, 60));
        draw_text(_cx, _by + 46, string(_qty) + " шт = " + string(_total) + " монет");
        draw_set_halign(fa_left);
    };
    if (shop_selected >= 0) {
        var _it = shop_items[shop_selected];
        _bar(shop_left_cx, _it.name, shop_buy_qty, _it.price * shop_buy_qty, global.coins >= _it.price * shop_buy_qty, "Купить", _mx, _my, _txt_dark);
    } else {
        draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(_txt_mid);
        draw_text(shop_left_cx, shop_bar_y + 30, "Выбери товар");
    }
    if (sell_selected >= 0) {
        var _si = sell_items[sell_selected];
        _bar(shop_right_cx, _si.name, sell_qty, _si.price * sell_qty, inventory_get_amount(_si.id) >= sell_qty, "Продать", _mx, _my, _txt_dark);
    } else {
        draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(_txt_mid);
        draw_text(shop_right_cx, shop_bar_y + 30, "Выбери, что продать");
    }
}

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
