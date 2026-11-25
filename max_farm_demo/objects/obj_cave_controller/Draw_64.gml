// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (DRAW GUI): сердечки, подсказка управления, пока Макс осваивается =====
hearts_draw();
var _m = max_side;
if (instance_exists(_m) && global.has_lantern && _m.jumps < 3 && !global.control_locked) {
    draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_bottom);
    draw_set_alpha(0.85); draw_set_color(c_black);
    var _t = "Стрелки - идти     Пробел - прыжок";
    var _w = string_width(_t) + 24;
    draw_roundrect_ext(display_get_gui_width() / 2 - _w / 2, display_get_gui_height() - 92, display_get_gui_width() / 2 + _w / 2, display_get_gui_height() - 62, 8, 8, false);
    draw_set_alpha(1); draw_set_color(c_white);
    draw_text(display_get_gui_width() / 2, display_get_gui_height() - 68, _t);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}
