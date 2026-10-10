// ===== ОКНО ДОСКИ ОБЪЯВЛЕНИЙ (DRAW GUI) =====

gpu_set_blendmode(bm_normal);

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Кожаная обложка (как у дневника)
var _x1 = win_x, _y1 = win_y, _x2 = win_x + win_w, _y2 = win_y + win_h;
draw_set_color(col_leather_dark);
draw_roundrect_ext(_x1 - 2, _y1 - 2, _x2 + 2, _y2 + 2, 10, 10, false);
draw_set_color(col_leather);
draw_roundrect_ext(_x1, _y1, _x2, _y2, 8, 8, false);
draw_set_color(col_leather_hi);
draw_roundrect_ext(_x1 + 3, _y1 + 3, _x2 - 3, _y2 - 3, 6, 6, true);

// Страница
var _px1 = _x1 + border, _py1 = _y1 + border, _px2 = _x2 - border, _py2 = _y2 - border;
draw_set_color(col_page_edge);
draw_rectangle(_px1, _py1, _px2, _py2, false);
draw_set_color(col_page);
draw_rectangle(_px1 + 6, _py1 + 4, _px2 - 4, _py2 - 4, false);

// Заголовок
var _tx = _px1 + pad;
var _tw = (_px2 - pad) - _tx;
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(col_title);
draw_text(_tx, _py1 + 16, "Доска объявлений");

var _ty = _py1 + 16 + string_height("Д") + 10;
draw_set_color(col_line);
draw_line(_tx, _ty, _tx + _tw, _ty);
_ty += 12;

// Список объявлений
qbtn_x1 = -1;
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(notes); i++) {
    var _n = notes[i];
    var _row_top = _ty;

    // Плашка задания — выделяем строку
    var _text_w = _tw;
    if (_n.quest) _text_w = _tw - qbtn_w - 12;

    // Заголовок объявления + метка "Задание"
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(col_title);
    draw_text(_tx, _ty, _n.title);
    if (_n.quest) {
        var _tag_x = _tx + string_width(_n.title) + 10;
        draw_set_font(fnt_ui);
        var _tag   = "Задание";
        var _tag_w = string_width(_tag) + 12;
        var _tag_h = string_height(_tag) + 2;
        draw_set_color(make_color_rgb(200, 60, 50));
        draw_roundrect_ext(_tag_x, _ty + 2, _tag_x + _tag_w, _ty + 2 + _tag_h, 4, 4, false);
        draw_set_color(c_white);
        draw_text(_tag_x + 6, _ty + 3, _tag);
    }

    // Автор — справа на строке заголовка
    draw_set_font(fnt_ui);
    draw_set_halign(fa_right);
    draw_set_color(col_author);
    draw_text(_tx + _tw, _ty + 2, "- " + _n.author);
    draw_set_halign(fa_left);

    _ty += 26;

    // Текст
    draw_set_color(col_text);
    draw_text_ext(_tx, _ty, _n.text, 18, _text_w);
    var _body_h = string_height_ext(_n.text, 18, _text_w);

    // Кнопка задания справа от текста
    if (_n.quest) {
        qbtn_x1 = _tx + _tw - qbtn_w;
        qbtn_y1 = _ty + max(0, (_body_h - qbtn_h) / 2);
        qbtn_x2 = qbtn_x1 + qbtn_w;
        qbtn_y2 = qbtn_y1 + qbtn_h;

        if (global.ivan_quest_done) {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(70, 150, 70));
            draw_text((qbtn_x1 + qbtn_x2) / 2, (qbtn_y1 + qbtn_y2) / 2, "Выполнено");
        } else if (global.ivan_quest_started) {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(col_author);
            draw_text((qbtn_x1 + qbtn_x2) / 2, (qbtn_y1 + qbtn_y2) / 2, "Задание взято");
        } else {
            var _hover = (mx >= qbtn_x1 && mx <= qbtn_x2 && my >= qbtn_y1 && my <= qbtn_y2);
            scr_dialog_draw_button(qbtn_x1, qbtn_y1, qbtn_x2, qbtn_y2, "Взять задание", _hover);
        }
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        _body_h = max(_body_h, qbtn_h);
    }

    _ty += _body_h + 10;

    // Разделитель между объявлениями
    if (i < array_length(notes) - 1) {
        draw_set_color(col_line);
        draw_set_alpha(0.5);
        draw_line(_tx, _ty, _tx + _tw, _ty);
        draw_set_alpha(1);
        _ty += 12;
    }
}

// Кнопка закрытия — зелёный крестик (как в дневнике)
draw_set_color(make_color_rgb(70, 160, 90));
draw_circle(close_cx, close_cy, close_r, false);
draw_set_color(make_color_rgb(40, 110, 60));
draw_circle(close_cx, close_cy, close_r, true);
draw_set_color(c_white);
var _cr = close_r * 0.45;
draw_line_width(close_cx - _cr, close_cy - _cr, close_cx + _cr, close_cy + _cr, 3);
draw_line_width(close_cx - _cr, close_cy + _cr, close_cx + _cr, close_cy - _cr, 3);

// Сброс
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
