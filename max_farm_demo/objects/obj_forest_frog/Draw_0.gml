// ===== ЛЕС: ЛЯГУШОНОК У БОЛЬШОГО КАМНЯ (DRAW) =====
draw_self();

// "!" над лягушонком, пока Макс с ним не поговорила
if (!global.frog_talk_done && (current_time mod 900) < 600) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_yellow);
    draw_text(x + 16, y - 2, "!");
}

if (near_player && !global.control_locked) {
    draw_hint("[E] Поговорить", x + 16, y - 8, true);
}

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
