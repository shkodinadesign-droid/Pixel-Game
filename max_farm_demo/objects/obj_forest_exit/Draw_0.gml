// ===== ЛЕС: ВЫХОД ОБРАТНО В ДЕРЕВНЮ (DRAW) =====
if (near_player && !global.control_locked) {
    draw_hint("[E] - в деревню", x + 56, y - 40, true);
}
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
