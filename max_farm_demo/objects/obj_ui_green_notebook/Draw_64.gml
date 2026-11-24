// ===== ЗЕЛЁНАЯ ТЕТРАДЬ (DRAW GUI) =====
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
draw_set_alpha(0.55); draw_set_color(c_black); draw_rectangle(0, 0, _gw, _gh, false); draw_set_alpha(1);

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

var _ink = make_color_rgb(60, 50, 80);
draw_set_font(fnt_ui); draw_set_halign(fa_left); draw_set_valign(fa_bottom); draw_set_color(_ink);

// левая страница: обрывок рецепта и рисунок меча
var _ty = by + 40;
for (var i = 0; i < array_length(left_lines); i++) { draw_text(bx + 18, _ty, left_lines[i]); _ty += 24; }
var _cx = bx + bw / 4, _cy = by + bh - 70;
draw_set_color(_ink);
draw_line_width(_cx - 70, _cy + 30, _cx + 50, _cy - 50, 3);                          // клинок
draw_line_width(_cx - 52, _cy + 2,  _cx - 34, _cy + 30, 3);                          // гарда
draw_line_width(_cx - 70, _cy + 30, _cx - 84, _cy + 40, 4);                          // рукоять
draw_circle(_cx - 87, _cy + 42, 3, false);
forest_draw_sign(_cx - 43, _cy + 16, 0.9);                                           // знак прежнего хозяина на гарде
draw_set_color(_ink); draw_set_halign(fa_center);
draw_text(_cx, by + bh - 12, "(рисунок по памяти)");
draw_set_halign(fa_left);

// правая страница: незаконченная запись
_ty = by + 40;
for (var j = 0; j < array_length(right_lines); j++) { draw_text(_mid + 18, _ty, right_lines[j]); _ty += 24; }
// клякса — дальше не прочитать
var _kx = _mid + 18 + string_width("Он лежит там, где") + 30, _ky = _ty - 24 - 8;
draw_set_color(make_color_rgb(40, 36, 70));
draw_circle(_kx, _ky, 13, false); draw_circle(_kx + 14, _ky + 4, 9, false); draw_circle(_kx - 8, _ky + 9, 6, false);
draw_circle(_kx + 24, _ky - 6, 3, false);

// кнопка
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
scr_dialog_draw_button(btn_x1, btn_y1, btn_x1 + btn_w, btn_y1 + btn_h, "Закрыть",
                       _mx >= btn_x1 && _mx <= btn_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h);
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
