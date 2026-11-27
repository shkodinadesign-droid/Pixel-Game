// ===== ЗЕЛЁНАЯ ТЕТРАДЬ (DRAW GUI) =====
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
draw_set_alpha(0.55); draw_set_color(c_black); draw_rectangle(0, 0, _gw, _gh, false); draw_set_alpha(1);

// развороты-картинки автора (текст уже на картинке), кнопки под ними
var _pic = spread_pics[spread];
_pic = (_pic != -1 && sprite_exists(_pic)) ? _pic : -1;
btn_y1 = (_pic != -1) ? 506 : by + bh + 12;
if (_pic != -1) {
    draw_sprite(_pic, 0, (_gw - sprite_get_width(_pic)) div 2, 2);
} else {
var _mid = bx + bw / 2;
// зелёная обложка и два листа
draw_set_color(make_color_rgb(58, 96, 60));   draw_roundrect_ext(bx - 10, by - 10, bx + bw + 10, by + bh + 10, 12, 12, false);
draw_set_color(make_color_rgb(238, 228, 200)); draw_rectangle(bx, by, _mid - 3, by + bh, false);
draw_set_color(make_color_rgb(232, 222, 194)); draw_rectangle(_mid + 3, by, bx + bw, by + bh, false);
if (sprite_exists(book_spr)) draw_sprite_stretched(book_spr, 0, bx, by, bw, bh);
// линейки
draw_set_alpha(0.25); draw_set_color(make_color_rgb(120, 140, 170));
for (var _ly = by + 40; _ly < by + bh - 10; _ly += 24) { draw_line(bx + 14, _ly, _mid - 14, _ly); draw_line(_mid + 14, _ly, bx + bw - 14, _ly); }
draw_set_alpha(1);

var _ink  = make_color_rgb(60, 50, 80);
var _lx   = bx + 18, _rx = _mid + 18, _top = by + 22;
draw_set_font(fnt_ui); draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(_ink);

// номера страниц внизу
draw_set_alpha(0.5); draw_set_halign(fa_center);
draw_text(bx + bw / 4, by + bh - 22, string(spread * 2 + 1));
draw_text(_mid + bw / 4, by + bh - 22, string(spread * 2 + 2));
draw_set_alpha(1); draw_set_halign(fa_left);

var _ty = _top;
switch (spread) {
    case 0:
        // левая: рисунок Меча героя
        draw_set_halign(fa_center);
        draw_text(bx + bw / 4, _top, "Меч героя");
        var _cx = bx + bw / 4 + 10, _cy = by + bh / 2 + 20;
        draw_set_color(_ink);
        draw_line_width(_cx - 80, _cy + 40, _cx + 60, _cy - 70, 3);                      // клинок
        draw_line_width(_cx - 60, _cy + 8,  _cx - 38, _cy + 40, 3);                      // гарда
        draw_line_width(_cx - 80, _cy + 40, _cx - 96, _cy + 52, 4);                      // рукоять
        draw_circle(_cx - 99, _cy + 55, 3, false);
        forest_draw_sign(_cx - 49, _cy + 24, 0.9);                                       // знак прежнего хозяина на гарде
        draw_set_color(_ink);
        draw_text(bx + bw / 4, by + bh - 52, "(рисунок по памяти)");
        draw_set_halign(fa_left);
        // правая: начало записи
        _ty = _top;
        draw_text_ext(_rx, _ty, txt_jack_1, line_h, page_w); _ty += string_height_ext(txt_jack_1, line_h, page_w) + 12;
        draw_text_ext(_rx, _ty, txt_jack_2, line_h, page_w);
        break;

    case 1:
        // левая: продолжение
        _ty = _top;
        draw_text_ext(_lx, _ty, txt_jack_3, line_h, page_w); _ty += string_height_ext(txt_jack_3, line_h, page_w) + 12;
        draw_text_ext(_lx, _ty, txt_jack_4, line_h, page_w);
        // правая: конец записи
        _ty = _top;
        draw_text_ext(_rx, _ty, txt_jack_5, line_h, page_w); _ty += string_height_ext(txt_jack_5, line_h, page_w) + 10;
        // неразборчивый набросок скал
        var _sx = _rx + 40, _sy = _ty + 70;
        draw_set_color(_ink);
        draw_line_width(_sx, _sy, _sx + 22, _sy - 52, 2);       draw_line_width(_sx + 22, _sy - 52, _sx + 40, _sy - 30, 2);
        draw_line_width(_sx + 40, _sy - 30, _sx + 52, _sy - 60, 2); draw_line_width(_sx + 52, _sy - 60, _sx + 74, _sy, 2);
        draw_line_width(_sx + 96, _sy, _sx + 118, _sy - 44, 2);   draw_line_width(_sx + 118, _sy - 44, _sx + 150, _sy, 2);
        // расколотый камень: два полукруга с трещиной
        draw_circle(_sx + 172, _sy - 8, 10, true); draw_line(_sx + 172, _sy - 20, _sx + 168, _sy + 2);
        // тропинка-закорючка и крестик
        for (var k = 0; k < 6; k++) draw_line(_sx + 60 + k * 14, _sy + 16 + ((k mod 2) ? 4 : 0), _sx + 67 + k * 14, _sy + 16 + ((k mod 2) ? 0 : 4));
        draw_line(_sx + 80, _sy - 10, _sx + 88, _sy - 2); draw_line(_sx + 88, _sy - 10, _sx + 80, _sy - 2);
        draw_set_alpha(0.6); draw_text(_sx + 150, _sy + 6, "?"); draw_text(_sx - 14, _sy - 40, "?"); draw_set_alpha(1);
        // приписка другим цветом
        draw_set_color(make_color_rgb(140, 60, 40));
        draw_text_ext(_rx, _sy + 34, txt_note, line_h, page_w);
        draw_set_color(_ink);
        break;

    case 2:
        // левая: рецепт пирога с лунной ягодой
        draw_text_ext(_lx, _top, txt_recipe, line_h, page_w);
        // правая: пустая, только засушенный листик
        var _px = _mid + bw / 4, _py = by + bh / 2;
        draw_set_color(make_color_rgb(150, 160, 110));
        draw_ellipse(_px - 10, _py - 24, _px + 10, _py + 20, false);
        draw_set_color(make_color_rgb(110, 120, 80));
        draw_line(_px, _py - 24, _px, _py + 32);
        draw_set_color(_ink);
        break;
}

} // конец ветки "не картинка"

// кнопки
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _last = (spread >= SPREADS - 1);
scr_dialog_draw_button(btn_x1, btn_y1, btn_x1 + btn_w, btn_y1 + btn_h, _last ? "Закрыть" : "Дальше",
                       _mx >= btn_x1 && _mx <= btn_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h);
if (spread > 0)
    scr_dialog_draw_button(back_x1, btn_y1, back_x1 + btn_w, btn_y1 + btn_h, "Назад",
                           _mx >= back_x1 && _mx <= back_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h);
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
