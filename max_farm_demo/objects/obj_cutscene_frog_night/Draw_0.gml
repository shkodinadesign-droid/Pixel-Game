// ===== НОЧЬ: ЛЯГУШОНОК И КАРТА (DRAW) =====
if (phase < 4) exit;

// Миска на камне — по мере того как лягушонок ест (на рассвете уже пустая)
draw_sprite(spr_pudding_eaten, bowl_fr, bowl_x, bowl_y);

// Крошки
draw_set_color(make_color_rgb(214, 152, 20));
for (var i = 0; i < array_length(crumbs); i++) {
    var _c = crumbs[i];
    draw_rectangle(_c.x, _c.y, _c.x + 1, _c.y + 1, false);
}
draw_set_color(c_white);

if (phase != 4 || f_alpha <= 0) exit;

var _frame = (f_frame_lock >= 0) ? f_frame_lock : (frog_anim div 8) mod 4;
var _h  = (st == "emerge" || st == "peek" || st == "rise") ? floor(f_vis_h) : 32;
if (_h <= 0) exit;
// Видна только верхняя часть _h пикселей — снизу её «прячет» грядка
var _dx = f_flip ? fx + 32 : fx;
draw_sprite_part_ext(f_spr, _frame, 0, 0, 32, _h, _dx, fy + 32 - _h, f_flip ? -1 : 1, 1, c_white, f_alpha);
