// Тело (цветная заглушка)
draw_set_color(npc_color);
draw_rectangle(x - npc_w/2, y - npc_h, x + npc_w/2, y, false);
draw_set_color(make_color_rgb(220, 180, 140));
draw_circle(x, y - npc_h - 10, 10, false);

// Имя
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(40, 20, 10));
draw_text(x, y - npc_h - 24, npc_name);

// Речевой пузырь
if (say_timer > 0) {
    var _msg = "Мясная лавка\nоткроется позже!";
    var _mw  = string_width(_msg) + 16;
    var _mh  = string_height(_msg) + 10;
    var _mx  = x - _mw / 2;
    var _my  = y - npc_h - 60 - _mh;
    draw_set_color(make_color_rgb(255, 250, 235));
    draw_roundrect_ext(_mx, _my, _mx + _mw, _my + _mh, 4, 4, false);
    draw_set_color(make_color_rgb(139, 90, 43));
    draw_roundrect_ext(_mx, _my, _mx + _mw, _my + _mh, 4, 4, true);
    draw_set_color(make_color_rgb(50, 30, 10));
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext(x, _my + 5, _msg, -1, _mw - 10);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
depth = -y;
