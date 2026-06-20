// spr_Miley: 32×48, origin top-left → рисуем с центром по x, низ на y
var _sw = sprite_get_width(spr_Miley);
var _sh = sprite_get_height(spr_Miley);
draw_sprite(spr_Miley, 0, x - _sw / 2, y - _sh);

// Имя
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(40, 20, 10));
draw_text(x, y - _sh - 6, npc_name);

// Речевой пузырь
if (say_timer > 0) {
    var _msg = "Come back later!";
    var _mw  = string_width(_msg) + 16;
    var _mh  = string_height(_msg) + 10;
    var _mx  = x - _mw / 2;
    var _my  = y - _sh - 28 - _mh;
    draw_set_color(make_color_rgb(255, 250, 235));
    draw_roundrect_ext(_mx, _my, _mx + _mw, _my + _mh, 4, 4, false);
    draw_set_color(make_color_rgb(200, 160, 210));
    draw_roundrect_ext(_mx, _my, _mx + _mw, _my + _mh, 4, 4, true);
    draw_set_color(make_color_rgb(80, 40, 90));
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext(x, _my + 5, _msg, -1, _mw - 10);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
depth = -y;
