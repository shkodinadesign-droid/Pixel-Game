// ===== ПЕРВОЕ ИСПЫТАНИЕ (DRAW GUI): затемнение при попадании, «Ещё раз!», плашка победы =====
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
hearts_draw();
if (hit_t > 0) {
    var _a = (hit_t < 30) ? hit_t / 30 : (60 - hit_t) / 30;
    draw_set_alpha(_a * 0.75); draw_set_color(c_black); draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(_a * 0.25); draw_set_color(make_color_rgb(180, 40, 40)); draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}
draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_middle);
if (retry_t > 0) {
    draw_set_alpha(min(1, retry_t / 20)); draw_set_color(make_color_rgb(250, 238, 210));
    draw_text(_gw / 2, 70, "Ещё раз!");
    draw_set_alpha(1);
}
if (banner_t > 0) {
    var _a = min(1, banner_t / 30, (240 - banner_t) / 20);
    draw_set_alpha(_a * 0.8); draw_set_color(c_black);
    draw_roundrect_ext(_gw / 2 - 190, 90, _gw / 2 + 190, 168, 12, 12, false);
    draw_set_alpha(_a); draw_set_color(make_color_rgb(255, 224, 140));
    draw_set_font(fnt_dialog_ru_bold);
    draw_text(_gw / 2, 118, "Первое испытание пройдено");
    draw_set_font(fnt_ui); draw_set_color(make_color_rgb(250, 238, 210));
    draw_text(_gw / 2, 146, "Испытания хранителя: 1 из 3");
    draw_set_alpha(1);
}
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
