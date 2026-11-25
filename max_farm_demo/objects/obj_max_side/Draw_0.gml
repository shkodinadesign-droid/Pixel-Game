// ===== МАКС В ПЕЩЕРЕ (DRAW) — спрайты ходьбы влево/вправо, в прыжке — один кадр шага =====
var _walk = (facing > 0) ? spr_max_walk_right : spr_max_walk_left;
var _idle = (facing > 0) ? spr_max_idle_right : spr_max_idle_left;
var _spr = _idle, _fr = 0;
if (!on_ground)    { _spr = _walk; _fr = 1; }
else if (hsp != 0) { _spr = _walk; _fr = anim_t; }
var _a = (hurt_t > 0 && (hurt_t div 4) mod 2 == 0) ? 0.35 : 1;
// фонарь на поясе сзади — маленький, руки свободны (рисуем до Макс, чтобы он был за ней)
if (global.has_lantern) {
    var _lx = cave_lantern_x(id), _ly = cave_lantern_y(id);
    draw_set_color(make_color_rgb(60, 44, 30)); draw_rectangle(_lx - 2, _ly - 3, _lx + 2, _ly + 3, false);
    draw_set_color(make_color_rgb(255, 214 + irandom(20), 130)); draw_rectangle(_lx - 1, _ly - 2, _lx + 1, _ly + 2, false);
    draw_set_color(c_white);
}
draw_sprite_ext(_spr, _fr, x - 9, y - 7, 1, 1, 0, c_white, _a);
